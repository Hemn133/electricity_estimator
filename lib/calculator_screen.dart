import 'package:flutter/material.dart';
import 'billing_calculator.dart';
import 'database_helper.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _unitsController = TextEditingController();

  String _selectedMonth = 'January';
  double _rebatePercentage = 0.0;

  double? _totalChargesResult;
  double? _finalCostResult;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _performCalculation() {
    if (_formKey.currentState!.validate()) {
      final double inputUnits = double.parse(_unitsController.text);

      final result = BillingCalculator.calculate(inputUnits, _rebatePercentage);

      setState(() {
        _totalChargesResult = result.totalCharges;
        _finalCostResult = result.finalCost;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculation generated successfully!'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToDatabase() async {
    if (_totalChargesResult == null || _finalCostResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please compute calculations before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final Map<String, dynamic> row = {
      'month': _selectedMonth,
      'units': double.parse(_unitsController.text),
      'rebate': _rebatePercentage,
      'total_charges': _totalChargesResult,
      'final_cost': _finalCostResult,
    };

    await DatabaseHelper.instance.insertBill(row);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill record for $_selectedMonth saved to local storage!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Electricity Bill Estimator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Helpful Guidance Banner
              Card(
                color: Colors.teal.withOpacity(0.1),
                elevation: 0,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Input your metrics below. Rates scale dynamically across multi-tiered blocks (1 to 1000 kWh).',
                          style: TextStyle(fontSize: 13, color: Colors.teal, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Selection for Month
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Select Billing Cycle Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                items: _months.map((String month) {
                  return DropdownMenuItem<String>(value: month, child: Text(month));
                }).toList(),
                onChanged: (value) => setState(() => _selectedMonth = value!),
              ),
              const SizedBox(height: 16),

              // Number Input Fields for Units
              TextFormField(
                controller: _unitsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Electricity Unit Usage (kWh)',
                  hintText: 'Enter value between 1 and 1000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bolt),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter unit consumption metrics';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return 'Please present valid numerical parameters';
                  }
                  if (parsed < 1 || parsed > 1000) {
                    return 'Constraint violation: Values must range from 1 to 1000 kWh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Slider Component for Rebate
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rebate Allocation Percentage', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_rebatePercentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  Slider(
                    value: _rebatePercentage,
                    min: 0.0,
                    max: 5.0,
                    divisions: 50,
                    label: '${_rebatePercentage.toStringAsFixed(1)}%',
                    onChanged: (value) => setState(() => _rebatePercentage = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _performCalculation,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveToDatabase,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save Record'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        foregroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Display Area for Output calculations
              if (_totalChargesResult != null && _finalCostResult != null) ...[
                const Text('Billing Output Estimations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.teal, width: 0.5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Base Tier Charges:', style: TextStyle(fontSize: 15)),
                            Text('RM ${_totalChargesResult!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Final Cost (After Rebate):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                            Text('RM ${_finalCostResult!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}