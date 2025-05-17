import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/supply_report.dart';
import '../services/gemini_service.dart';

class SupplyReportScreen extends StatefulWidget {
  final SupplyReport report;

  const SupplyReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<SupplyReportScreen> createState() => _SupplyReportScreenState();
}

class _SupplyReportScreenState extends State<SupplyReportScreen> {
  Map<String, dynamic>? _insights;
  bool _isLoadingInsights = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final insights = await GeminiService.generateSupplyInsights(widget.report);
      setState(() {
        _insights = insights;
        _isLoadingInsights = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInsights = false;
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
          'Supply Report',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF4CAF50)),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF4CAF50)),
            onPressed: () {
              // TODO: Implement print functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 24),
            _buildAIInsights(),
            const SizedBox(height: 24),
            _buildSupplyStatusChart(),
            const SizedBox(height: 24),
            _buildSupplyTable(),
            const SizedBox(height: 24),
            _buildNextShipmentInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
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
            'Supply Status Report',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated on: ${widget.report.timestamp.toString().split('.')[0]}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            'Number of people: ${widget.report.numberOfPeople}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    if (_isLoadingInsights) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161A1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
              SizedBox(height: 16),
              Text(
                'Generating AI insights...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                'AI Analysis',
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
          _buildInsightSection('Recommendations', _insights!['recommendations'], Icons.recommend),
          _buildInsightSection('Risk Assessment', _insights!['risks'], Icons.warning_amber),
          _buildInsightSection('Suggested Actions', _insights!['actions'], Icons.checklist),
          _buildInsightSection('Supply Chain Efficiency', _insights!['efficiency'], Icons.analytics),
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

  Widget _buildSupplyStatusChart() {
    final supplyData = widget.report.supplies.entries.map((entry) {
      final supply = entry.value;
      return MapEntry(
        supply['name'] as String,
        (supply['remaining'] as num).toDouble() / (supply['required'] as num).toDouble() * 100,
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
            'Supply Status Overview',
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
                maxY: 100,
                barGroups: List.generate(
                  supplyData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: supplyData[index].value,
                        color: _getStatusColor(supplyData[index].value),
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
                            supplyData[value.toInt()].key,
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
                          '${value.toInt()}%',
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

  Widget _buildSupplyTable() {
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
            'Detailed Supply Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: const TextStyle(color: Colors.white),
              columns: const [
                DataColumn(label: Text('Supply')),
                DataColumn(label: Text('Remaining')),
                DataColumn(label: Text('Required')),
                DataColumn(label: Text('Days Left')),
                DataColumn(label: Text('Status')),
              ],
              rows: widget.report.supplies.entries.map((entry) {
                final supply = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(supply['name'] as String)),
                    DataCell(Text(supply['remaining'].toString())),
                    DataCell(Text(supply['required'].toString())),
                    DataCell(Text(supply['days'].toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            (supply['remaining'] as num).toDouble() /
                                (supply['required'] as num).toDouble() *
                                100,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          supply['status'] as String,
                          style: TextStyle(
                            color: _getStatusColor(
                              (supply['remaining'] as num).toDouble() /
                                  (supply['required'] as num).toDouble() *
                                  100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextShipmentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Shipment Due',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'In ${widget.report.nextShipmentDue} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage <= 25) {
      return Colors.red;
    } else if (percentage <= 50) {
      return Colors.orange;
    } else {
      return const Color(0xFF4CAF50);
    }
  }
} 