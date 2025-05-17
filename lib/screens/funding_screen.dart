import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/supabase.dart';
import 'supplier_layout.dart';

class FundingScreen extends StatefulWidget {
  const FundingScreen({super.key});

  @override
  State<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen> {
  String _sortBy = 'critical';
  final List<String> _sortOptions = ['critical', 'closing_date', 'amount'];

  @override
  Widget build(BuildContext context) {
    return SupplierLayout(
      currentRoute: '/funding',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Disaster Funding'),
          actions: [
            DropdownButton<String>(
              value: _sortBy,
              items: _sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortBy = newValue;
                  });
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<List<dynamic>>(
          stream: _fundingStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final requests = snapshot.data ?? [];

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final data = requests[index];
                final isCritical = data['critical'] ?? false;
                final closingDate = DateTime.tryParse(data['closing_date'] ?? '');
                final amount = data['amount']?.toString() ?? 'N/A';
                final title = data['title']?.toString() ?? 'Untitled';
                final description = data['description']?.toString() ?? 'No description';

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                      isCritical ? Icons.warning : Icons.info,
                      color: isCritical ? Colors.red : Colors.blue,
                    ),
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(description),
                        const SizedBox(height: 4),
                        Text(
                          'Amount: \$${NumberFormat('#,##0.00').format(double.tryParse(amount) ?? 0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (closingDate != null)
                          Text(
                            'Closing Date: ${DateFormat('MMM dd, yyyy').format(closingDate)}',
                            style: TextStyle(
                              color: closingDate.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Implement detailed view
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add new funding request
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Stream<List<dynamic>> _fundingStream() {
    return SupabaseConfig.client
        .from('funding_requests')
        .stream(primaryKey: ['id'])
        .order(_sortBy)
        .map((data) => data);
  }
} 