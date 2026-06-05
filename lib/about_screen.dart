import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});


  Future<void> _launchGitHubUrl(BuildContext context) async {
    // TODO: Replace this placeholder string with your actual repository link
    final Uri gitHubUri = Uri.parse('https://github.com/yourusername/electricity_estimator');

    try {
      if (await canLaunchUrl(gitHubUri)) {
        await launchUrl(gitHubUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch repository path';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open hyperlink: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Profile & Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Profile Identity Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Image Box Holder
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 60, color: Colors.teal),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Hemn Amin Abdullah',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student ID: 12345678', // TODO: Update with your Student ID
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Divider(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Course Code:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('MTC3012', style: TextStyle(fontWeight: FontWeight.w600)), // TODO: Update code
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Course Name:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Mobile Technology', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),


            ElevatedButton.icon(
              onPressed: () => _launchGitHubUrl(context),
              icon: const Icon(Icons.code),
              label: const Text('View Source Code on GitHub'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),


            const Text('Application Operational Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepRow('1', 'Navigate to the Calculator panel.'),
                    _buildStepRow('2', 'Select the target billing cycle Month via the calendar dropdown indicator.'),
                    _buildStepRow('3', 'Type your exact power usage data into the kWh consumption text area (Values must fall inside the 1 to 1000 range).'),
                    _buildStepRow('4', 'Adjust the percentage slide bar handler to accurately distribute rebate value limits (0% to 5%).'),
                    _buildStepRow('5', 'Click Calculate to evaluate real-time costs, then tap Save Record to save metrics to offline SQLite database repositories.'),
                    _buildStepRow('6', 'Visit the History tab to manage metrics. Tap an entry to enter the management portal where you can update or delete logged fields.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),


            Center(
              child: Text(
                '© 2026 VoltCalc Pro. All Rights Reserved.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String stepsNumber, String descriptionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.teal,
            child: Text(stepsNumber, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descriptionText,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}