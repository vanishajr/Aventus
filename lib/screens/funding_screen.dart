import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class FundingScreen extends StatefulWidget {
  const FundingScreen({super.key});

  @override
  State<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedDisaster;
  String? _selectedPaymentMethod;
  bool _isAnonymous = false;

  final List<Map<String, String>> _disasters = [
    {'id': '1', 'name': 'Kerala Flood Relief'},
    {'id': '2', 'name': 'Tamil Nadu Cyclone Response'},
    {'id': '3', 'name': 'Maharashtra Drought Relief'},
    {'id': '4', 'name': 'Himachal Landslide Recovery'},
    {'id': '5', 'name': 'Gujarat Earthquake Aid'},
  ];

  final List<String> _paymentMethods = [
    'Credit/Debit Card',
    'UPI',
    'Net Banking',
    'Mobile Wallet',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Funding'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make a Difference',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your contribution can help save lives and rebuild communities.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Disaster Selection
                const Text(
                  'Select Disaster Relief Campaign',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDisaster,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: _disasters.map((disaster) {
                      return DropdownMenuItem(
                        value: disaster['id'],
                        child: Text(disaster['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDisaster = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a disaster relief campaign';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Input
                const Text(
                  'Donation Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (int.parse(value) < 100) {
                      return 'Minimum donation amount is ₹100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Quick Amount Buttons
                Wrap(
                  spacing: 8,
                  children: [
                    _buildQuickAmountButton('₹500'),
                    _buildQuickAmountButton('₹1,000'),
                    _buildQuickAmountButton('₹2,000'),
                    _buildQuickAmountButton('₹5,000'),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment Method Selection
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a payment method';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Anonymous Donation Option
                SwitchListTile(
                  title: const Text(
                    'Make Anonymous Donation',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Your name will not be displayed publicly',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 32),

                // Donate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle donation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Processing donation...'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Donate Now',
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
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () {
        _amountController.text = amount.replaceAll('₹', '').replaceAll(',', '');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF4CAF50)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(amount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 