import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/supply_report.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';

class AIReportScreen extends StatefulWidget {
  final Map<String, dynamic> supplyData;

  const AIReportScreen({
    super.key,
    required this.supplyData,
  });

  @override
  State<AIReportScreen> createState() => _AIReportScreenState();
}

class _AIReportScreenState extends State<AIReportScreen> {
  bool _isLoading = true;
  bool _isGeneratingPDF = false;
  Map<String, dynamic>? _insights;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final report = SupplyReport(
        timestamp: DateTime.now(),
        numberOfPeople: widget.supplyData['numberOfPeople'],
        supplies: Map<String, Map<String, dynamic>>.from(widget.supplyData['supplies']),
        nextShipmentDue: widget.supplyData['nextShipmentDue'],
        mostUrgent: widget.supplyData['mostUrgent'],
        mostUrgentStatus: widget.supplyData['mostUrgentStatus'],
      );

      final insights = await GeminiService.generateSupplyInsights(report);
      setState(() {
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadReport() async {
    if (_insights == null) return;

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final report = SupplyReport(
        timestamp: DateTime.now(),
        numberOfPeople: widget.supplyData['numberOfPeople'],
        supplies: Map<String, Map<String, dynamic>>.from(widget.supplyData['supplies']),
        nextShipmentDue: widget.supplyData['nextShipmentDue'],
        mostUrgent: widget.supplyData['mostUrgent'],
        mostUrgentStatus: widget.supplyData['mostUrgentStatus'],
      );

      final file = await PDFService.generateSupplyReport(report, _insights!);
      await PDFService.openPDF(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'AI Supply Analysis',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading && _insights != null)
            IconButton(
              onPressed: _isGeneratingPDF ? null : _downloadReport,
              icon: _isGeneratingPDF
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.download,
                      color: Color(0xFF4CAF50),
                    ),
              tooltip: 'Download PDF Report',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Generating AI insights...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSupplyDistributionChart(),
                  const SizedBox(height: 24),
                  _buildSupplyStatusChart(),
                  const SizedBox(height: 24),
                  _buildAIInsights(),
                  const SizedBox(height: 24),
                  _buildRecommendationsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply Analysis Report',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Number of People: ${widget.supplyData['numberOfPeople']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Text(
            'Most Urgent Need: ${widget.supplyData['mostUrgent']} (${widget.supplyData['mostUrgentStatus']})',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyDistributionChart() {
    final supplies = widget.supplyData['supplies'] as Map<String, dynamic>;
    final data = supplies.entries.map((e) {
      final supply = e.value as Map<String, dynamic>;
      return MapEntry(
        supply['name'] as String,
        double.parse(supply['remaining'].toString().split(' ')[0]),
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(data.length, (index) {
                  final colors = [
                    const Color(0xFF4CAF50),
                    const Color(0xFFFFA726),
                    const Color(0xFF42A5F5),
                    const Color(0xFFEF5350),
                    const Color(0xFF9C27B0),
                  ];
                  return PieChartSectionData(
                    value: data[index].value,
                    title: '${((data[index].value / data.map((e) => e.value).reduce((a, b) => a + b)) * 100).toStringAsFixed(1)}%',
                    color: colors[index % colors.length],
                    radius: 100,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(data.length, (index) {
              final colors = [
                const Color(0xFF4CAF50),
                const Color(0xFFFFA726),
                const Color(0xFF42A5F5),
                const Color(0xFFEF5350),
                const Color(0xFF9C27B0),
              ];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[index % colors.length],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data[index].key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyStatusChart() {
    final supplies = widget.supplyData['supplies'] as Map<String, dynamic>;
    final data = supplies.entries.map((e) {
      final supply = e.value as Map<String, dynamic>;
      return MapEntry(
        supply['name'] as String,
        double.parse(supply['days'].toString()),
      );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Days Until Depletion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: List.generate(
                  data.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index].value,
                        color: data[index].value < 7
                            ? Colors.red
                            : data[index].value < 14
                                ? Colors.orange
                                : const Color(0xFF4CAF50),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[value.toInt()].key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    if (_insights == null) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightSection('Key Insights', _insights!['insights'], Icons.lightbulb_outline),
          _buildInsightSection('Risk Assessment', _insights!['risks'], Icons.warning_amber),
          _buildInsightSection('Supply Chain Efficiency', _insights!['efficiency'], Icons.analytics),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    if (_insights == null) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.recommend,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _insights!['recommendations'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Suggested Actions:',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _insights!['actions'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 