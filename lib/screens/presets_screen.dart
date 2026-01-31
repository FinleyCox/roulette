import 'package:flutter/material.dart';
import '../utils/preset_manager.dart';
import '../utils/purchase_manager.dart';
import '../utils/language_utils.dart';

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
            LanguageUtils.getSettingsText(
              'savePresetTitle',
              widget.currentLanguage,
            ),
          ),
          content: TextField(
            autofocus: true,
            onChanged: (v) => input = v,
            decoration: InputDecoration(
              hintText: LanguageUtils.getSettingsText(
                'presetNameHint',
                widget.currentLanguage,
              ),
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
                LanguageUtils.getSettingsText(
                  'presetSaved',
                  widget.currentLanguage,
                ),
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
          LanguageUtils.getSettingsText(
            'confirmDeleteTitle',
            widget.currentLanguage,
          ),
        ),
        content: Text(
          widget.currentLanguage == 'en' ? 'Delete "$name"?' : '$name を削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageUtils.getSettingsText('cancel', widget.currentLanguage),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePreset(index);
            },
            child: Text(
              LanguageUtils.getSettingsText('delete', widget.currentLanguage),
              style: const TextStyle(color: Colors.red),
            ),
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
        title: Text(
          LanguageUtils.getSettingsText('limitReached', widget.currentLanguage),
        ),
        content: Text(
          LanguageUtils.getSettingsText(
            'limitReachedDesc',
            widget.currentLanguage,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LanguageUtils.getSettingsText('close', widget.currentLanguage),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger purchase from here? Or just tell user to go back.
              // For simplicity, just close or maybe navigate back to settings?
              // Purchase logic is singleton so we can call it.
              _showPurchaseOptions();
            },
            child: Text(
              LanguageUtils.getSettingsText('upgrade', widget.currentLanguage),
            ),
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
              title: Text(
                LanguageUtils.getSettingsText(
                  'upgradePlan',
                  widget.currentLanguage,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      LanguageUtils.getSettingsText(
                        'tier1Title',
                        widget.currentLanguage,
                      ),
                    ),
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
                      title: Text(
                        LanguageUtils.getSettingsText(
                          'tier2Title',
                          widget.currentLanguage,
                        ),
                      ),
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
                  child: Text(
                    LanguageUtils.getSettingsText(
                      'close',
                      widget.currentLanguage,
                    ),
                  ),
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
                LanguageUtils.getSettingsText(
                  'noPresets',
                  widget.currentLanguage,
                ),
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
