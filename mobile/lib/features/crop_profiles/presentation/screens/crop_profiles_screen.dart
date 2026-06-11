import 'package:flutter/material.dart';

class CropProfilesScreen extends StatefulWidget {
  const CropProfilesScreen({super.key});

  @override
  State<CropProfilesScreen> createState() => _CropProfilesScreenState();
}

class _CropProfilesScreenState extends State<CropProfilesScreen> {
  String _searchQuery = '';
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Royal Delicious Apple',
      'category': 'Fruit',
      'temp': '0.0°C to 2.0°C',
      'humidity': '90% to 95%',
      'days': 150,
      'notes': 'Highly sensitive to ethylene. Keep CO₂ below 2.0% to prevent internal browning.',
      'icon': Icons.apple,
    },
    {
      'name': 'Russet Potato',
      'category': 'Vegetable',
      'temp': '3.0°C to 5.0°C',
      'humidity': '90% to 95%',
      'days': 180,
      'notes': 'Requires proper curing phase at 15°C for 10 days before cooling down to storage setpoints.',
      'icon': Icons.brightness_high_outlined,
    },
    {
      'name': 'Hybrid Tomato',
      'category': 'Fruit',
      'temp': '10.0°C to 12.0°C',
      'humidity': '85% to 90%',
      'days': 14,
      'notes': 'Subject to chilling injury if stored below 10°C. High respiration rate.',
      'icon': Icons.circle,
    },
    {
      'name': 'Alphonso Mango',
      'category': 'Fruit',
      'temp': '12.0°C to 13.0°C',
      'humidity': '85% to 90%',
      'days': 28,
      'notes': 'Pre-cool quickly after harvest. Sensitive to cold temperatures.',
      'icon': Icons.eco,
    },
    {
      'name': 'Red Onion',
      'category': 'Vegetable',
      'temp': '0.0°C to 1.0°C',
      'humidity': '65% to 70%',
      'days': 240,
      'notes': 'Requires dry storage. High humidity causes mold and root growth.',
      'icon': Icons.grain,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _profiles
        .where((p) => p['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Intelligence Profiles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Crop Profiles',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Profiles list
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No crop profiles found.'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(p['icon'] as IconData, color: theme.colorScheme.primary),
                            ),
                            title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Category: ${p['category']} • Max Life: ${p['days']} Days'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildTargetParam(context, 'Optimal Temp', p['temp'] as String),
                                        _buildTargetParam(context, 'Optimal Humidity', p['humidity'] as String),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Preservation Guidelines:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p['notes'] as String,
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, height: 1.3),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      icon: const Icon(Icons.copy, size: 16),
                                      label: const Text('Apply as Preset Defaults'),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Preset values for ${p['name']} copied to clipboard.')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetParam(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
