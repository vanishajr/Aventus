import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'supplier_layout.dart';

class ProvideAssistanceScreen extends StatefulWidget {
  const ProvideAssistanceScreen({super.key});

  @override
  State<ProvideAssistanceScreen> createState() => _ProvideAssistanceScreenState();
}

class _ProvideAssistanceScreenState extends State<ProvideAssistanceScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _allowLocation = false;
  bool _allowSMS = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SupplierLayout(
      currentRoute: '/provide_assistance',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provide Assistance'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Phone Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  hintText: '+1 (234) 567-8901',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PhoneNumberFormatter(),
                ],
              ),
              const SizedBox(height: 32),
              CheckboxListTile(
                value: _allowLocation,
                onChanged: (value) {
                  setState(() {
                    _allowLocation = value ?? false;
                  });
                },
                title: const Text(
                  'Allow Location Access',
                  style: TextStyle(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _allowSMS,
                onChanged: (value) {
                  setState(() {
                    _allowSMS = value ?? false;
                  });
                },
                title: const Text(
                  'Allow SMS Access',
                  style: TextStyle(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement continue functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    String formatted = '+1 ';
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length > 0) {
      formatted += '(${digits.substring(0, digits.length.clamp(0, 3))}';
    }
    if (digits.length > 3) {
      formatted += ') ${digits.substring(3, digits.length.clamp(3, 6))}';
    }
    if (digits.length > 6) {
      formatted += '-${digits.substring(6, digits.length.clamp(6, 10))}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
} 