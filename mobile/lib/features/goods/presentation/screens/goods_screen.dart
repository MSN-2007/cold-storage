import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_db/drift_database.dart';

class GoodsScreen extends ConsumerWidget {
  const GoodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(coldSmartDbProvider);

    return StreamBuilder<List<GoodsBatchesTableData>>(
      stream: db.watchAllGoods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inventory & Batches')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inventory & Batches')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final batches = snapshot.data ?? [];
        
        double totalWeightKg = 0.0;
        double totalValueINR = 0.0;
        double atRiskValueINR = 0.0;

        for (final item in batches) {
          final qty = item.quantityKg ?? 0.0;
          totalWeightKg += qty;
          
          // Estimate average market value of 60 INR per kg for produce
          final value = qty * 60.0;
          totalValueINR += value;

          // If remaining shelf life is less than 15 days or spoilage score is high, it is at risk
          if ((item.remainingShelfLifeDays ?? 100) < 15 || (item.spoilageRiskScore ?? 0.0) > 30.0) {
            atRiskValueINR += value;
          }
        }

        final totalTons = totalWeightKg / 1000.0;
        final totalLakhs = totalValueINR / 100000.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Inventory & Batches'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {},
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Batch'),
            onPressed: () => context.go('/goods/add'),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerLowest,
                ],
              ),
            ),
            child: Column(
              children: [
                // Dashboard Summary
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat(
                            context,
                            'Total Stock',
                            '${totalTons.toStringAsFixed(1)} Tons',
                            theme.colorScheme.onPrimaryContainer,
                          ),
                          _buildSummaryStat(
                            context,
                            'Total Value',
                            '₹${totalLakhs.toStringAsFixed(2)}L',
                            theme.colorScheme.onPrimaryContainer,
                          ),
                          _buildSummaryStat(
                            context,
                            'At Risk',
                            atRiskValueINR > 0
                                ? '₹${(atRiskValueINR / 1000).toStringAsFixed(0)}k'
                                : '₹0',
                            atRiskValueINR > 0 ? Colors.redAccent : theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Stock list title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Active Storage Batches',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // List of inventory
                Expanded(
                  child: batches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No inventory batches in storage.',
                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: batches.length,
                          itemBuilder: (context, index) {
                            final item = batches[index];
                            final days = item.remainingShelfLifeDays ?? 30;
                            
                            // Estimate original life based on crop category
                            int orig = 150;
                            if (item.category == 'Potato') orig = 180;
                            if (item.category == 'Tomato') orig = 14;
                            if (item.category == 'Onion') orig = 240;
                            if (item.category == 'Banana') orig = 21;
                            if (item.category == 'Mango') orig = 28;

                            final ratio = (days / orig).clamp(0.0, 1.0);

                            Color statusColor = Colors.green;
                            if (days < 15) {
                              statusColor = Colors.red;
                            } else if (days < 45) {
                              statusColor = Colors.orange;
                            }

                            final itemValue = (item.quantityKg ?? 0.0) * 60.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${item.category} • Chamber: ${item.chamberId}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₹${(itemValue / 1000).toStringAsFixed(0)}k',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          'Shelf Life:',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: ratio,
                                              minHeight: 8,
                                              color: statusColor,
                                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$days / $orig days left',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Qty: ${(item.quantityKg ?? 0).toStringAsFixed(0)} kg',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Stored: ${item.createdAt.split("T").first}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
