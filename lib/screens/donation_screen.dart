import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/supabase.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import 'package:intl/intl.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  List<Donation> _donations = [];

  @override
  void initState() {
    super.initState();
    _loadSampleDonations();
  }

  void _loadSampleDonations() {
    // Sample donation data
    _donations = [
      Donation(
        id: '1',
        disasterName: 'Flood Relief - Kerala',
        amount: 5000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        donorName: 'John Doe',
        status: 'Completed',
      ),
      Donation(
        id: '2',
        disasterName: 'Earthquake Response - Nepal',
        amount: 10000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        donorName: 'Jane Smith',
        status: 'Processing',
      ),
      Donation(
        id: '3',
        disasterName: 'Cyclone Relief - Tamil Nadu',
        amount: 7500,
        date: DateTime.now().subtract(const Duration(days: 1)),
        donorName: 'Robert Johnson',
        status: 'Completed',
      ),
      Donation(
        id: '4',
        disasterName: 'Drought Relief - Maharashtra',
        amount: 15000,
        date: DateTime.now().subtract(const Duration(days: 3)),
        donorName: 'Sarah Williams',
        status: 'Completed',
      ),
      Donation(
        id: '5',
        disasterName: 'Landslide Response - Himachal',
        amount: 12000,
        date: DateTime.now().subtract(const Duration(days: 4)),
        donorName: 'Michael Brown',
        status: 'Processing',
      ),
    ];
  }

  Future<void> _showDonationDialog(Map<String, dynamic> disaster) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _amountController.clear();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          languageProvider.translate('donate_now'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: languageProvider.translate('enter_amount'),
              prefixText: languageProvider.translate('currency_symbol'),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.translate('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Add new donation to the list
                  setState(() {
                    _donations.add(
                      Donation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        disasterName: disaster['name'],
                        amount: double.parse(_amountController.text),
                        date: DateTime.now(),
                        donorName: 'Anonymous',
                        status: 'Processing',
                      ),
                    );
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(languageProvider.translate('donation_success')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(
              languageProvider.translate('donate'),
              style: const TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisasterCard(Map<String, dynamic> disaster, LanguageProvider languageProvider) {
    final targetAmount = disaster['target_amount'] ?? 0;
    final raisedAmount = disaster['raised_amount'] ?? 0;
    final progress = targetAmount > 0 ? (raisedAmount / targetAmount) : 0.0;

    return Card(
      color: Colors.black,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disaster['name'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disaster['description'] ?? '',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${languageProvider.translate('target_amount')}${languageProvider.translate('currency_symbol')}$targetAmount',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${languageProvider.translate('raised_amount')}${languageProvider.translate('currency_symbol')}$raisedAmount',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showDonationDialog(disaster),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(languageProvider.translate('donate')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)),
        columns: const [
          DataColumn(
            label: Text(
              'Disaster',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Amount',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Donor',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: _donations.map((donation) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  donation.disasterName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  '₹${NumberFormat('#,##,###').format(donation.amount)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  DateFormat('dd MMM yyyy').format(donation.date),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  donation.donorName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: donation.status == 'Completed'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donation.status,
                    style: TextStyle(
                      color: donation.status == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(languageProvider.translate('donations')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Donations',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: _buildDonationsTable(),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Active Disaster Relief Campaigns',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: SupabaseConfig.client
                  .from('disasters')
                  .select('*, donations(amount)')
                  .eq('status', 'active')
                  .then((data) {
                    final List<Map<String, dynamic>> disasters = List<Map<String, dynamic>>.from(data);
                    return disasters.map((disaster) {
                      final donations = List<Map<String, dynamic>>.from(disaster['donations'] ?? []);
                      final raisedAmount = donations.fold<int>(0, (sum, donation) => sum + (donation['amount'] as int));
                      return {
                        ...disaster,
                        'raised_amount': raisedAmount,
                      };
                    }).toList();
                  }).catchError((error) {
                    return <Map<String, dynamic>>[];
                  }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final disasters = snapshot.data ?? [];

                if (disasters.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      languageProvider.translate('no_active_disasters'),
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: disasters.length,
                  itemBuilder: (context, index) => _buildDisasterCard(
                    disasters[index],
                    languageProvider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 