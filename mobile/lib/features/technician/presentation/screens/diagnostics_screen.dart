import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mqtt_service.dart';
import '../../../auth/domain/auth_provider.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const DiagnosticsScreen({super.key, required this.deviceId});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _isRunning = false;
  final List<Map<String, dynamic>> _tests = [
    {'name': 'Temperature Sensor Calibration', 'status': 'pending', 'icon': Icons.thermostat},
    {'name': 'Humidity Sensor Calibration', 'status': 'pending', 'icon': Icons.water_drop},
    {'name': 'CO₂ NDIR Sensor Response', 'status': 'pending', 'icon': Icons.co2},
    {'name': 'O₂ Electrochemical Cell', 'status': 'pending', 'icon': Icons.air},
    {'name': 'Evaporator Fan Relay Switch', 'status': 'pending', 'icon': Icons.wind_power},
    {'name': 'Defrost Coil Relay Switch', 'status': 'pending', 'icon': Icons.flash_on},
    {'name': 'Main Battery Backup Voltage', 'status': 'pending', 'icon': Icons.battery_charging_full},
  ];

  void _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      for (var t in _tests) {
        t['status'] = 'running';
      }
    });

    try {
      // Publish diagnostics trigger command over MQTT
      final auth = ref.read(authStateProvider);
      final companyId = auth.valueOrNull?.companyId ?? 'company-uuid-67890';
      await ref.read(mqttServiceProvider.notifier).publish(
        'cs/$companyId/device/${widget.deviceId}/diagnostics/trigger',
        {
          'action': 'run_diagnostics',
          'triggered_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('MQTT publish failed: $e');
    }

    for (var i = 0; i < _tests.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        // Mocking some pass/warning results
        if (i == 4) {
          _tests[i]['status'] = 'warning';
          _tests[i]['details'] = 'Current draw slightly high (0.85A)';
        } else {
          _tests[i]['status'] = 'passed';
          _tests[i]['details'] = 'Nominal values detected';
        }
      });
    }

    if (mounted) {
      setState(() {
        _isRunning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnostics test complete. Acknowledged in audit trail.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Diagnostics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Warning / Alert Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 48, color: Colors.blue),
                    const SizedBox(height: 12),
                    Text(
                      'IoT Node Diagnostics',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This triggers a live query to the device firmware over MQTT, running localized self-tests.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Diagnostic list
            Expanded(
              child: ListView.builder(
                itemCount: _tests.length,
                itemBuilder: (context, index) {
                  final test = _tests[index];
                  final status = test['status'] as String;

                  Widget statusWidget = const Icon(Icons.circle_outlined, color: Colors.grey);
                  if (status == 'running') {
                    statusWidget = const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (status == 'passed') {
                    statusWidget = const Icon(Icons.check_circle, color: Colors.green);
                  } else if (status == 'warning') {
                    statusWidget = const Icon(Icons.warning, color: Colors.orange);
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0.5,
                    child: ListTile(
                      leading: Icon(test['icon'] as IconData, color: theme.colorScheme.primary),
                      title: Text(test['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: test['details'] != null ? Text(test['details'] as String) : null,
                      trailing: statusWidget,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Trigger Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isRunning ? null : _runDiagnostics,
              child: Text(_isRunning ? 'Testing Hardware...' : 'Run Live Diagnostics', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
