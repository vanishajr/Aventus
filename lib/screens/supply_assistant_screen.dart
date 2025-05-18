import 'package:flutter/material.dart';
import '../services/supply_assistant_service.dart';
import '../services/pdf_service.dart';
import '../models/supply_report.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SupplyAssistantScreen extends StatefulWidget {
  final Function(String)? onReportGenerated;

  const SupplyAssistantScreen({super.key, this.onReportGenerated});

  @override
  State<SupplyAssistantScreen> createState() => _SupplyAssistantScreenState();
}

class _SupplyAssistantScreenState extends State<SupplyAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peopleController = TextEditingController();
  final _waterController = TextEditingController();
  final _foodController = TextEditingController();
  final _medicalController = TextEditingController();
  final _clothingController = TextEditingController();
  final _othersController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  Map<String, dynamic>? _lastCalculation;
  bool _isCalculating = false;
  bool _isGeneratingPDF = false;

  void _addMessage(String message, bool isAI) {
    setState(() {
      _messages.add({
        'message': message,
        'isAI': isAI.toString(),
      });
    });
  }

  Future<void> _generateReport() async {
    if (_lastCalculation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please calculate supplies first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final report = SupplyReport(
        timestamp: DateTime.now(),
        numberOfPeople: int.parse(_peopleController.text),
        supplies: Map<String, Map<String, dynamic>>.from(_lastCalculation!['supplies']),
        nextShipmentDue: _lastCalculation!['nextShipmentDue'],
        mostUrgent: _lastCalculation!['mostUrgent'],
        mostUrgentStatus: _lastCalculation!['mostUrgentStatus'],
      );

      final reportMessage = '''Supply Report Summary:
      
Number of People: ${report.numberOfPeople}

Supply Status:
${report.supplies.entries.map((e) => '${e.key}: ${e.value['status']} (${e.value['remaining']} remaining)').join('\n')}

Most Urgent Need: ${report.mostUrgent} (${report.mostUrgentStatus})
Next Shipment Due: ${report.nextShipmentDue}

This report has been generated using AI analysis to provide comprehensive insights and recommendations for optimal supply management.''';

      final file = await PDFService.generateSupplyReport(report, reportMessage);
      
      widget.onReportGenerated?.call(reportMessage);

      setState(() {
        _isGeneratingPDF = false;
        _addMessage('Supply report generated and sent to dashboard', false);
        _addMessage(reportMessage, true);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  void _calculateSupplies() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });

      try {
        final supplies = await SupplyAssistantService.calculateSupplies(
          numberOfPeople: int.parse(_peopleController.text),
          supplies: {
            'water': double.parse(_waterController.text),
            'food': double.parse(_foodController.text),
            'medical': double.parse(_medicalController.text),
            'clothing': double.parse(_clothingController.text),
            if (_othersController.text.isNotEmpty)
              'others': double.parse(_othersController.text),
          },
        );

        _lastCalculation = supplies;  // Store the calculation

        String priorityMessage = '';
        for (var supply in supplies['priorityList']) {
          String statusEmoji = supply['status'] == 'Critical' 
              ? '🔴' 
              : supply['status'] == 'Low' 
                  ? '🟡' 
                  : '🟢';
                  
          priorityMessage += '''
$statusEmoji ${supply['name']}:
• Remaining: ${supply['remaining']}
• Required: ${supply['required']}
• Will last: ${supply['days']} days (${supply['status']})

''';
        }

        final response = '''Supply Status Analysis:

${supplies['mostUrgent']} needs immediate attention (${supplies['mostUrgentStatus']})

$priorityMessage
Next shipment recommended in: ${supplies['nextShipmentDue']} days

AI Insights:
${supplies['aiInsights']}
''';

        setState(() {
          _isCalculating = false;
          _addMessage('Supply calculation completed', false);
          _addMessage(response, true);
        });

      } catch (e) {
        setState(() {
          _isCalculating = false;
          _addMessage('Error calculating supplies: $e', true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(languageProvider.translate('ai_supply_assistant')),
        actions: [
          if (_lastCalculation != null)
            IconButton(
              icon: _isGeneratingPDF
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.picture_as_pdf),
              onPressed: _isGeneratingPDF ? null : _generateReport,
              tooltip: languageProvider.translate('generate_report'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isAI = message['isAI'] == 'true';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAI ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAI ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAI ? Icons.smart_toy : Icons.person,
                            color: isAI ? Colors.green : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAI ? 'AI Assistant' : 'You',
                            style: TextStyle(
                              color: isAI ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message['message'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _peopleController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('number_of_people'),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return languageProvider.translate('please_enter_value');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _waterController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: languageProvider.translate('water_gallons'),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.translate('please_enter_value');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _foodController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: languageProvider.translate('meal_kits'),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.translate('please_enter_value');
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _medicalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: languageProvider.translate('medical_kits'),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.translate('please_enter_value');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _clothingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: languageProvider.translate('clothing_sets'),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.translate('please_enter_value');
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _othersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('other_supplies'),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCalculating ? null : _calculateSupplies,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isCalculating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              languageProvider.translate('calculate'),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _peopleController.dispose();
    _waterController.dispose();
    _foodController.dispose();
    _medicalController.dispose();
    _clothingController.dispose();
    _othersController.dispose();
    super.dispose();
  }
} 