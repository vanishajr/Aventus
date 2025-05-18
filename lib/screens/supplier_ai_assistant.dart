import 'package:flutter/material.dart';
import '../config/supabase.dart';
import '../services/supply_assistant_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SupplierAIAssistant extends StatefulWidget {
  const SupplierAIAssistant({super.key});

  @override
  State<SupplierAIAssistant> createState() => _SupplierAIAssistantState();
}

class _SupplierAIAssistantState extends State<SupplierAIAssistant> {
  final List<Map<String, String>> _messages = [];
  bool _isAnalyzing = false;
  Map<String, dynamic>? _selectedCluster;

  @override
  void initState() {
    super.initState();
    _addMessage('Select a cluster to analyze supply requirements.', true);
  }

  void _addMessage(String message, bool isAI) {
    setState(() {
      _messages.add({
        'message': message,
        'isAI': isAI.toString(),
      });
    });
  }

  Future<void> _analyzeCluster(Map<String, dynamic> cluster) async {
    setState(() {
      _isAnalyzing = true;
      _selectedCluster = cluster;
    });

    try {
      // Get the number of people in the cluster
      final peopleCount = cluster['size'] as int;
      
      // Calculate supply requirements
      final supplies = await SupplyAssistantService.calculateSupplies(
        numberOfPeople: peopleCount,
        supplies: {
          'water': 0, // Start with 0 to get requirements
          'food': 0,
          'medical': 0,
          'clothing': 0,
        },
      );

      String analysisMessage = '''
📍 Cluster Analysis for "${cluster['name']}"
Location: (${cluster['latitude']}, ${cluster['longitude']})
Population: ${cluster['size']} people
Priority Level: ${cluster['priority']}

Required Supplies (3-day estimate):
${supplies['priorityList'].map((supply) => '''
${supply['name']}:
• Required: ${supply['required']}
''').join('\n')}
''';

      _addMessage(analysisMessage, true);
    } catch (e) {
      _addMessage('Error analyzing cluster: $e', true);
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadClusters() async {
    final response = await SupabaseConfig.client
        .from('clusters')
        .select()
        .order('priority', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(languageProvider.translate('ai_supply_assistant')),
      ),
      body: Column(
        children: [
          // Cluster Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Cluster',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadClusters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final clusters = snapshot.data ?? [];
                    
                    return SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: clusters.length,
                        itemBuilder: (context, index) {
                          final cluster = clusters[index];
                          final isSelected = _selectedCluster != null && 
                                          _selectedCluster!['id'] == cluster['id'];
                          
                          return GestureDetector(
                            onTap: () => _analyzeCluster(cluster),
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppTheme.greenGradient : null,
                                color: isSelected ? null : AppTheme.surfaceGrey,
                                border: Border.all(
                                  color: isSelected ? Colors.green : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cluster['name'] ?? 'Unnamed Cluster',
                                    style: const TextStyle(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${cluster['size']} people',
                                    style: TextStyle(
                                      color: AppTheme.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    'Priority: ${cluster['priority']}',
                                    style: TextStyle(
                                      color: AppTheme.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Chat Messages
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
                        style: const TextStyle(color: AppTheme.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.green),
              ),
            ),
        ],
      ),
    );
  }
} 