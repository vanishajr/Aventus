import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/voice_assistant_service.dart';
import '../services/translation_service.dart';
import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceAssistantService _voiceAssistant = VoiceAssistantService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startVoiceAssistant();
  }

  Future<void> _startVoiceAssistant() async {
    await _voiceAssistant.startListening();
    setState(() {
      _isListening = true;
    });
  }

  @override
  void dispose() {
    _voiceAssistant.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            languageProvider.translate('app_name'),
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // Language Selection
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: Color(0xFF4CAF50)),
              color: const Color(0xFF161A1C),
              itemBuilder: (context) => TranslationService.supportedLanguages.entries
                  .map(
                    (e) => PopupMenuItem<String>(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onSelected: (String langCode) {
                languageProvider.setLanguage(langCode);
              },
            ),
          ),
          // Voice Assistant Status
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isListening ? const Color(0xFF4CAF50).withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_off,
                  color: _isListening ? const Color(0xFF4CAF50) : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _isListening ? languageProvider.translate('listening') : languageProvider.translate('off'),
                  style: TextStyle(
                    color: _isListening ? const Color(0xFF4CAF50) : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black,
                isScrollControlled: true,
                builder: (context) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Text(
                          languageProvider.translate('menu'),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _MenuListItem(
                        title: languageProvider.translate('dashboard'),
                        onTap: () => Navigator.pushNamed(context, '/dashboard'),
                      ),
                      _MenuListItem(
                        title: languageProvider.translate('funding'),
                        onTap: () => Navigator.pushNamed(context, '/funding'),
                      ),
                      _MenuListItem(
                        title: languageProvider.translate('citizen_portal'),
                        onTap: () => Navigator.pushNamed(context, '/citizen'),
                      ),
                      _MenuListItem(
                        title: languageProvider.translate('supplier_portal'),
                        onTap: () => Navigator.pushNamed(context, '/supplier'),
                      ),
                      _MenuListItem(
                        title: languageProvider.translate('disaster_education'),
                        onTap: () => Navigator.pushNamed(context, '/disaster-education'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Colors.white,
                  ),
                  text: languageProvider.translate('main_title'),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  languageProvider.translate('sub_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _ActionButton(
                title: languageProvider.translate('citizen'),
                filled: true,
                onTap: () => Navigator.pushNamed(context, '/citizen'),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                title: languageProvider.translate('supplier'),
                filled: false,
                onTap: () => Navigator.pushNamed(context, '/supplier'),
              ),
              const SizedBox(height: 24),
              // Voice Assistant Hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic,
                      color: Colors.white.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      languageProvider.translate('voice_assistance'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuListItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: filled ? Colors.white : const Color(0xFF4CAF50),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
} 