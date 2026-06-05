import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'billing_calculator.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> billData;
  const DetailScreen({super.key, required this.billData});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitsController;
  late String _currentMonth;
  late double _currentRebate;


  late double _calculatedCharges;
  late double _calculatedFinal;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.billData['month'];
    _currentRebate = widget.billData['rebate'];
    _unitsController = TextEditingController(text: widget.billData['units'].toString());
    _calculatedCharges = widget.billData['total_charges'];
    _calculatedFinal = widget.billData['final_cost'];
  }

  void _recalculateMetrics() {
    final double? parsedUnits = double.tryParse(_unitsController.text);
    if (parsedUnits != null && parsedUnits >= 1 && parsedUnits <= 1000) {
      final res = BillingCalculator.calculate(parsedUnits, _currentRebate);
      setState(() {
        _calculatedCharges = res.totalCharges;
        _calculatedFinal = res.finalCost;
      });
    }
  }

  Future<void> _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> updatedRow = {
        'id': widget.billData['id'],
        'month': _currentMonth,
        'units': double.parse(_unitsController.text),
        'rebate': _currentRebate,
        'total_charges': _calculatedCharges,
        'final_cost': _calculatedFinal,
      };

      await DatabaseHelper.instance.updateBill(updatedRow);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database entry updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteRecord() async {

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete this billing log from historical registers?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await DatabaseHelper.instance.deleteBill(widget.billData['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log item removed from storage.'), backgroundColor: Colors.redAccent),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Log Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Database Record Modifiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),


              DropdownButtonFormField<String>(
                value: _currentMonth,
                decoration: const InputDecoration(labelText: 'Billing Month', border: OutlineInputBorder()),
                items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  setState(() => _currentMonth = val!);
                  _recalculateMetrics();
                },
              ),
              const SizedBox(height: 16),


              TextFormField(
                controller: _unitsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Consumption Volume (kWh)', border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Value missing';
                  final num = double.tryParse(val);
                  if (num == null || num < 1 || num > 1000) return 'Must stay between 1 and 1000';
                  return null;
                },
                onChanged: (val) => _recalculateMetrics(),
              ),
              const SizedBox(height: 16),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adjust Rebate: ${_currentRebate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: _currentRebate,
                    min: 0.0,
                    max: 5.0,
                    divisions: 50,
                    onChanged: (val) {
                      setState(() => _currentRebate = val);
                      _recalculateMetrics();
                    },
                  ),
                ],
              ),
              const Divider(height: 32),

              // Detailed Metric Breakdown Calculations Displays
              const Text('Calculated Metric Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Raw Base Charges:'), Text('RM ${_calculatedCharges.toStringAsFixed(2)}')],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Adjusted Final Cost:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        Text('RM ${_calculatedFinal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),


              ElevatedButton.icon(
                onPressed: _updateRecord,
                icon: const Icon(Icons.check),
                label: const Text('Save Modifications'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _deleteRecord,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Delete Record', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}