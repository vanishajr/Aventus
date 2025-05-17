package com.example.disaster

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity(), OnInitListener {
    private val CHANNEL = "com.example.disaster/voice_assistant"
    private val PERMISSIONS_REQUEST_CODE = 123
    private val TIMEOUT_DURATION = 120000L // 2 minutes in milliseconds
    private var tts: TextToSpeech? = null
    private lateinit var speechRecognizer: SpeechRecognizer
    private lateinit var recognizerIntent: Intent
    private val TAG = "VoiceAssistant"
    private var hasPermissions = false
    private var isListening = false
    private val client = OkHttpClient()
    private val BACKEND_URL = "http://10.0.2.2:5000" // Android emulator localhost
    private var lastActivityTime = System.currentTimeMillis()
    private val timeoutHandler = Handler(Looper.getMainLooper())
    private val timeoutRunnable = Runnable {
        if (System.currentTimeMillis() - lastActivityTime >= TIMEOUT_DURATION) {
            speak("No emergency keyword detected for 2 minutes. Stopping voice assistant.")
            stopVoiceRecognition()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    requestPermissionsAndStart()
                    result.success(null)
                }
                "stopListening" -> {
                    stopVoiceRecognition()
                    result.success(null)
                }
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    speak(text)
                    result.success(null)
                }
                "makePhoneCall" -> {
                    val number = call.argument<String>("number") ?: ""
                    makePhoneCall(number)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this, this)
        initializeSpeechRecognizer()
        requestPermissionsAndStart()
    }

    private fun requestPermissionsAndStart() {
        val permissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.MODIFY_AUDIO_SETTINGS,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )

        val permissionsToRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }.toTypedArray()

        if (permissionsToRequest.isEmpty()) {
            hasPermissions = true
            startVoiceRecognition()
        } else {
            ActivityCompat.requestPermissions(this, permissionsToRequest, PERMISSIONS_REQUEST_CODE)
        }
    }

    private fun initializeSpeechRecognizer() {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            Log.e(TAG, "Speech recognition is not available on this device")
            speak("Speech recognition is not available on this device")
            return
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
        }

        speechRecognizer.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "Ready for speech")
                runOnUiThread {
                    speak("Voice assistant is ready")
                }
                updateLastActivityTime()
            }
            
            override fun onBeginningOfSpeech() {
                Log.d(TAG, "Speech beginning")
                updateLastActivityTime()
            }
            
            override fun onRmsChanged(rmsdB: Float) {}
            
            override fun onBufferReceived(buffer: ByteArray?) {}
            
            override fun onEndOfSpeech() {
                Log.d(TAG, "Speech ended")
            }
            
            override fun onError(error: Int) {
                Log.e(TAG, "Error in speech recognition: $error")
                when (error) {
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> {
                        requestPermissionsAndStart()
                    }
                    SpeechRecognizer.ERROR_NO_MATCH -> {
                        restartListening()
                    }
                    else -> {
                        speak("Error in speech recognition. Restarting...")
                        restartListening()
                    }
                }
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val spokenText = matches?.get(0)?.toLowerCase() ?: ""
                Log.d(TAG, "Speech result: $spokenText")

                if (spokenText.contains("disaster help")) {
                    Log.d(TAG, "Disaster help detected, making emergency call")
                    speak("Making emergency call")
                    makePhoneCall("9993423717")
                    updateLastActivityTime()
                }

                if (System.currentTimeMillis() - lastActivityTime >= TIMEOUT_DURATION) {
                    speak("No emergency keyword detected for 2 minutes. Stopping voice assistant.")
                    stopVoiceRecognition()
                } else {
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        restartListening()
                    }, 1000)
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                updateLastActivityTime()
            }
            
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
    }

    private fun restartListening() {
        if (isListening && hasPermissions) {
            try {
                speechRecognizer.startListening(recognizerIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Error restarting speech recognition: ${e.message}")
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    startVoiceRecognition()
                }, 1000)
            }
        }
    }

    private fun startVoiceRecognition() {
        if (!isListening && hasPermissions) {
            isListening = true
            lastActivityTime = System.currentTimeMillis()
            try {
                speechRecognizer.startListening(recognizerIntent)
                Log.d(TAG, "Voice recognition started")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting speech recognition: ${e.message}")
                isListening = false
                speak("Error starting voice recognition. Please try again.")
            }
        }
    }

    private fun stopVoiceRecognition() {
        if (isListening) {
            isListening = false
            speechRecognizer.stopListening()
            Log.d(TAG, "Voice recognition stopped")
        }
    }

    private fun updateLastActivityTime() {
        lastActivityTime = System.currentTimeMillis()
    }

    private fun speak(text: String) {
        Log.d(TAG, "Speaking: $text")
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    private fun makePhoneCall(number: String) {
        Log.d(TAG, "Attempting to call: $number")
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "No permission to make calls")
            speak("Requesting permission to make calls")
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CALL_PHONE),
                PERMISSIONS_REQUEST_CODE
            )
            return
        }

        try {
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$number")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                Log.d(TAG, "Call initiated successfully")
                speak("Emergency call initiated")
            } else {
                Log.e(TAG, "No app can handle phone calls")
                speak("Sorry, no app can handle phone calls on this device")
                
                val dialIntent = Intent(Intent.ACTION_DIAL).apply {
                    data = Uri.parse("tel:$number")
                }
                if (dialIntent.resolveActivity(packageManager) != null) {
                    startActivity(dialIntent)
                    speak("Opening dialer with emergency number")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error making call: ${e.message}")
            speak("Sorry, I couldn't make the call. Please try manually dialing $number")
            
            try {
                val dialIntent = Intent(Intent.ACTION_DIAL).apply {
                    data = Uri.parse("tel:$number")
                }
                startActivity(dialIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Error opening dialer: ${e.message}")
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSIONS_REQUEST_CODE) {
            hasPermissions = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (hasPermissions) {
                startVoiceRecognition()
                speak("Permissions granted. Voice assistant is starting.")
            } else {
                speak("I need microphone, phone, and location permissions to help you with emergency calls")
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale.US
            requestPermissionsAndStart()
        } else {
            Log.e(TAG, "TTS initialization failed")
        }
    }

    override fun onDestroy() {
        stopVoiceRecognition()
        tts?.stop()
        tts?.shutdown()
        speechRecognizer.destroy()
        super.onDestroy()
    }
}
