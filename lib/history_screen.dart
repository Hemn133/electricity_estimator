import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _savedBills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBillLogs();
  }

  // Fetch or refresh data from SQLite local database
  Future<void> _refreshBillLogs() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.queryAllBills();
    setState(() {
      _savedBills = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Estimation Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBillLogs,
            tooltip: 'Refresh Database',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedBills.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No records saved in database yet.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: _savedBills.length,
        itemBuilder: (context, index) {
          final bill = _savedBills[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                child: Icon(Icons.receipt_long),
              ),
              // Rubric requirement: Display Month only
              title: Text(
                bill['month'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // Rubric requirement: Display Final Cost only
              trailing: Text(
                'RM ${bill['final_cost'].toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Tap to manage record details',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              onTap: () async {
                // Open detail view and wait for a return value to check if database changed
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(billData: bill),
                  ),
                );
                if (result == true) {
                  _refreshBillLogs(); // Refresh list if edit or delete happened
                }
              },
            ),
          );
        },
      ),
    );
  }
}