import 'package:flutter/material.dart';
import '../utils/preset_manager.dart';
import '../utils/purchase_manager.dart';

class PresetsScreen extends StatefulWidget {
  final String currentLanguage;
  final Map<String, dynamic> currentSettings;
  final Function(Map<String, dynamic>?) onLoadPreset;

  const PresetsScreen({
    super.key,
    required this.currentLanguage,
    required this.currentSettings,
    required this.onLoadPreset,
  });

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _refreshPresets();
  }

  Future<void> _refreshPresets() async {
    final presets = await PresetManager.getPresets();
    setState(() {
      _presets = presets;
    });
  }

  Future<void> _savePreset() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: Text(
            widget.currentLanguage == 'ja'
                ? '現在の入力内容でプリセットを保存'
                : 'Save Current Input as Preset',
          ),
          content: TextField(
            autofocus: true,
            onChanged: (v) => input = v,
            decoration: InputDecoration(
              hintText: widget.currentLanguage == 'ja'
                  ? 'プリセット名'
                  : 'Preset Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name != null && name.trim().isNotEmpty) {
      final success = await PresetManager.savePreset(
        name,
        widget.currentSettings,
      );
      if (success) {
        _refreshPresets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.currentLanguage == 'ja' ? '保存しました' : 'Preset saved',
              ),
            ),
          );
        }
      } else {
        if (mounted) _showUpgradeDialog();
      }
    }
  }

  void _confirmDelete(int index, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.currentLanguage == 'ja' ? '削除の確認' : 'Confirm Delete',
        ),
        content: Text(
          widget.currentLanguage == 'ja' ? '$name を削除しますか？' : 'Delete "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePreset(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePreset(int index) async {
    await PresetManager.deletePreset(index);
    _refreshPresets();
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: const Text(
          'You have reached the limit of saved presets.\nUpgrade to save more.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger purchase from here? Or just tell user to go back.
              // For simplicity, just close or maybe navigate back to settings?
              // Purchase logic is singleton so we can call it.
              _showPurchaseOptions();
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final pm = PurchaseManager();
            final isTier2 = pm.isTier2Purchased();
            return AlertDialog(
              title: const Text('Upgrade Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Tier 1 (Max +3 Sets)'),
                    subtitle: const Text('¥100'),
                    onTap: () {
                      PurchaseManager().buyProduct(
                        PurchaseManager.productTier1,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  if (!isTier2)
                    ListTile(
                      title: const Text('Tier 2 (Max 10 Sets + Ad Free)'),
                      subtitle: const Text('¥200'),
                      onTap: () {
                        PurchaseManager().buyProduct(
                          PurchaseManager.productTier2,
                        );
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current Usage
    final limit = PurchaseManager().getPresetLimit();
    final count = _presets.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentLanguage == 'ja' ? 'プリセット管理' : 'Manage Presets',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '$count / $limit',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePreset,
        child: const Icon(Icons.add),
      ),
      body: _presets.isEmpty
          ? Center(
              child: Text(
                widget.currentLanguage == 'ja'
                    ? '保存されたプリセットはありません'
                    : 'No presets saved',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final name = preset['name'] ?? 'No Name';
                final data = preset['data'] as Map<String, dynamic>;
                final cardCount = data['cardCount'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Cards: $cardCount'),
                    onTap: () {
                      widget.onLoadPreset(data);
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _confirmDelete(index, name),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
