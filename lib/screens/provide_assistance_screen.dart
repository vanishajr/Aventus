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
      ),
    );
  }
} 