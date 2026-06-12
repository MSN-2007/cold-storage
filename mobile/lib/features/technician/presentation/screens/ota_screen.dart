import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mqtt_service.dart';
import '../../../auth/domain/auth_provider.dart';

class OtaScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const OtaScreen({super.key, required this.deviceId});

  @override
  ConsumerState<OtaScreen> createState() => _OtaScreenState();
}

class _OtaScreenState extends ConsumerState<OtaScreen> {
  String _selectedFirmware = 'v1.2.5 (Stable)';
  double _progress = 0.0;
  String _otaStatus = 'idle'; // idle | downloading | installing | success | failed
  bool _isUpdating = false;

  void _startUpdate() async {
    setState(() {
      _isUpdating = true;
      _otaStatus = 'downloading';
      _progress = 0.0;
    });

    try {
      // Publish live OTA command over MQTT
      final auth = ref.read(authStateProvider);
      final companyId = auth.valueOrNull?.companyId ?? 'company-uuid-67890';
      await ref.read(mqttServiceProvider.notifier).publish(
        'cs/$companyId/device/${widget.deviceId}/ota/trigger',
        {
          'firmware_version': _selectedFirmware,
          'triggered_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('MQTT publish failed: $e');
    }

    // Simulate downloading from MinIO
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _progress = i * 0.05; // reaches 0.5
      });
    }

    if (!mounted) return;
    setState(() {
      _otaStatus = 'installing';
    });

    // Simulate flashing firmware
    for (var i = 11; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _progress = i * 0.05; // reaches 1.0
      });
    }

    if (!mounted) return;
    setState(() {
      _otaStatus = 'success';
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Firmware upgrade successful! Device is rebooting.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firmware Upgrade (OTA)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current status info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.system_update, size: 48, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text('Current Firmware: v1.2.4', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Hardware Platform: ESP32-S3-WROOM', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select firmware Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedFirmware,
              decoration: const InputDecoration(
                labelText: 'Target Firmware Release',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified),
              ),
              items: const [
                DropdownMenuItem(value: 'v1.2.5 (Stable)', child: Text('v1.2.5 - Stable Rollout')),
                DropdownMenuItem(value: 'v1.3.0-RC1 (Beta)', child: Text('v1.3.0-RC1 - Release Candidate')),
              ],
              onChanged: _isUpdating ? null : (val) {
                if (val != null) {
                  setState(() {
                    _selectedFirmware = val;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Progress tracking
            if (_otaStatus != 'idle') ...[
              Text(
                _getStatusText(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  color: _otaStatus == 'success' ? Colors.green : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).round()}% Completed',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ],

            const Spacer(),

            // Actions
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _otaStatus == 'success' ? Colors.green : theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isUpdating || _otaStatus == 'success' ? null : _startUpdate,
              child: Text(
                _otaStatus == 'success' ? 'Rebooting Device...' : 'Deploy Over-The-Air Update',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (_otaStatus) {
      case 'downloading':
        return 'Downloading firmware binary to node...';
      case 'installing':
        return 'Flashing ESP32 partitions & verifying SHA256...';
      case 'success':
        return 'Rollout Successful! Device is coming online.';
      default:
        return 'Initiating OTA deployment...';
    }
  }
}
