import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/local_db/drift_database.dart';
import '../../../../core/services/sync_engine.dart';

class AddGoodsScreen extends ConsumerStatefulWidget {
  final String? chamberId;

  const AddGoodsScreen({super.key, this.chamberId});

  @override
  ConsumerState<AddGoodsScreen> createState() => _AddGoodsScreenState();
}

class _AddGoodsScreenState extends ConsumerState<AddGoodsScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCrop = 'Apple';
  String _selectedChamber = 'Chamber 1 (Apples)';
  int _estimatedDays = 150;
  bool _isSaving = false;

  final Map<String, int> _cropShelfLife = {
    'Apple': 150,
    'Potato': 180,
    'Tomato': 14,
    'Onion': 240,
    'Banana': 21,
    'Mango': 28,
  };

  @override
  void initState() {
    super.initState();
    if (widget.chamberId != null) {
      _selectedChamber = 'Chamber ${widget.chamberId!.split('-').last.toUpperCase()}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onCropChanged(String? crop) {
    if (crop != null) {
      setState(() {
        _selectedCrop = crop;
        _estimatedDays = _cropShelfLife[crop] ?? 30;
      });
    }
  }

  void _saveBatch() async {
    if (_nameController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter batch name and weight.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = ref.read(coldSmartDbProvider);
      final batchId = UniqueKey().toString();

      // Write to Drift Local DB
      final batchCompanion = GoodsBatchesTableCompanion.insert(
        id: batchId,
        chamberId: widget.chamberId ?? 'chamber-uuid-1',
        name: _nameController.text,
        category: _selectedCrop,
        quantityKg: drift.Value(double.tryParse(_weightController.text)),
        stage: 'storage',
        remainingShelfLifeDays: drift.Value(_estimatedDays),
        spoilageRiskScore: const drift.Value(10.0),
        createdAt: DateTime.now().toIso8601String(),
      );

      await db.upsertGoods(batchCompanion);

      // Queue in Sync Engine
      await ref.read(syncEngineProvider.notifier).queueOfflineAction(
        entityType: 'goods_batch',
        entityId: batchId,
        action: 'create',
        payload: {
          'name': _nameController.text,
          'category': _selectedCrop,
          'quantity_kg': double.tryParse(_weightController.text) ?? 0.0,
          'unit_price': double.tryParse(_priceController.text) ?? 0.0,
          'chamber_id': widget.chamberId ?? 'chamber-uuid-1',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch saved & remaining shelf life activated!')),
        );
        context.go('/goods');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save batch: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Storage Batch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: theme.colorScheme.tertiaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.spa, size: 40, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Shelf Life',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_estimatedDays Days in Storage',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          Text(
                            'Calculated using USDA/FAO standard parameters.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Batch Name / Lot Label',
                hintText: 'e.g. Kashmiri Apples Lot 3',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Produce Category (Crop Profile)',
                prefixIcon: Icon(Icons.grass),
                border: OutlineInputBorder(),
              ),
              items: _cropShelfLife.keys.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: _onCropChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedChamber,
              decoration: const InputDecoration(
                labelText: 'Target Cold Room / Chamber',
                prefixIcon: Icon(Icons.room),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Chamber 1 (Apples)', child: Text('Chamber 1 (Apples)')),
                DropdownMenuItem(value: 'Chamber 2 (Potatoes)', child: Text('Chamber 2 (Potatoes)')),
                DropdownMenuItem(value: 'Chamber 3 (Grains)', child: Text('Chamber 3 (Grains)')),
                DropdownMenuItem(value: 'Chamber 4 (Empty)', child: Text('Chamber 4 (Empty)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedChamber = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Quantity (kg)',
                      prefixIcon: Icon(Icons.scale),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price per kg (INR)',
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isSaving ? null : _saveBatch,
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Store Batch & Set Targets', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
