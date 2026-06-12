import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'Temperature Compliance';
  String _selectedFormat = 'PDF';
  bool _isGenerating = false;

  final reports = [
    {
      'title': 'May 2026 Temperature Compliance Report',
      'type': 'Temperature Compliance',
      'format': 'PDF',
      'date': '2026-06-01',
      'size': '1.2 MB',
    },
    {
      'title': 'Audit Log Export Q2',
      'type': 'Audit Report',
      'format': 'CSV',
      'date': '2026-05-15',
      'size': '450 KB',
    },
    {
      'title': 'Potato Storage Lot 4 Spoilage Risk Sheet',
      'type': 'Inventory Report',
      'format': 'Excel',
      'date': '2026-05-02',
      'size': '850 KB',
    },
  ];

  void _triggerReport() async {
    setState(() {
      _isGenerating = true;
    });
    // Simulate background Celery task
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        reports.insert(0, {
          'title': 'June 2026 $_selectedReportType',
          'type': _selectedReportType,
          'format': _selectedFormat,
          'date': '2026-06-09',
          'size': '620 KB',
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated and uploaded to MinIO storage successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance & Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Generator Panel
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Request New Report',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReportType,
                      decoration: const InputDecoration(
                        labelText: 'Report Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Temperature Compliance', child: Text('Temperature Compliance')),
                        DropdownMenuItem(value: 'Humidity Compliance', child: Text('Humidity Compliance')),
                        DropdownMenuItem(value: 'Inventory Report', child: Text('Inventory Report')),
                        DropdownMenuItem(value: 'Audit Report', child: Text('System Audit Report')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedReportType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFormat,
                      decoration: const InputDecoration(
                        labelText: 'Export Format',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PDF', child: Text('PDF Document (.pdf)')),
                        DropdownMenuItem(value: 'Excel', child: Text('Excel Spreadsheet (.xlsx)')),
                        DropdownMenuItem(value: 'CSV', child: Text('CSV Flat Table (.csv)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedFormat = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isGenerating ? 'Generating...' : 'Request Export'),
                      onPressed: _isGenerating ? null : _triggerReport,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // History List
            Text(
              'Generated Reports',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final r = reports[index];
                IconData formatIcon = Icons.picture_as_pdf;
                Color iconColor = Colors.red;

                if (r['format'] == 'Excel') {
                  formatIcon = Icons.table_chart;
                  iconColor = Colors.green;
                } else if (r['format'] == 'CSV') {
                  formatIcon = Icons.text_snippet;
                  iconColor = Colors.blue;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withValues(alpha: 0.1),
                      child: Icon(formatIcon, color: iconColor),
                    ),
                    title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Type: ${r['type']} • Created: ${r['date']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.download, size: 20),
                        Text(
                          r['size'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading ${r['title']}...')),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
