import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/language_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'qr_scanner_screen.dart';
import '../utils/purchase_manager.dart';
import 'presets_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// 設定画面の状態を管理するクラス
class _SettingsScreenState extends State<SettingsScreen> {
  final List<TextEditingController> titleControllers = [];
  final List<TextEditingController> multiChoiceControllers = [];
  int cardCount = 4; // カードの数を管理
  bool isSaved = false; // 保存状態を管理

  @override
  void initState() {
    super.initState();
    _ensureControllers(4);
    _loadSettings();
    PurchaseManager().loadPurchases();
    // Re-check IAP status when entering settings
    PurchaseManager().purchaseUpdates.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final pm = PurchaseManager();
            final isTier2Purchased = pm.isTier2Purchased();

            return AlertDialog(
              title: const Text('Upgrade Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Tier 1 (Max +3 Sets)'),
                    subtitle: const Text('¥100'),
                    onTap: () {
                      pm.buyProduct(PurchaseManager.productTier1);
                      Navigator.pop(context);
                    },
                  ),
                  if (!isTier2Purchased)
                    ListTile(
                      title: const Text('Tier 2 (Max 10 Sets + Ad Free)'),
                      subtitle: const Text('¥200'),
                      onTap: () {
                        pm.buyProduct(PurchaseManager.productTier2);
                        Navigator.pop(context);
                      },
                    ),
                  ListTile(
                    title: const Text('Restore Purchases'),
                    onTap: () {
                      pm.restorePurchases();
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

  void _ensureControllers(int count) {
    while (titleControllers.length < count) {
      titleControllers.add(TextEditingController());
      multiChoiceControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in titleControllers) {
      controller.dispose();
    }
    for (var controller in multiChoiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getDefaultTitle(int index) {
    return LanguageUtils.getCardTitle(index, widget.currentLanguage);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardCount = prefs.getInt('card_count') ?? 4;

    if (savedCardCount != cardCount) {
      setState(() {
        cardCount = savedCardCount;
        _ensureControllers(cardCount);
      });
    } else {
      _ensureControllers(cardCount);
    }

    for (int i = 0; i < cardCount; i++) {
      final savedTitle = prefs.getString('card_title_$i');
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      if (savedTitle == null ||
          savedTitle.isEmpty ||
          savedTitle == _getDefaultTitle(i)) {
        titleControllers[i].text = '';
      } else {
        titleControllers[i].text = savedTitle;
      }
      multiChoiceControllers[i].text = multiChoice;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('card_count', cardCount);

    for (int i = 0; i < cardCount; i++) {
      final title = titleControllers[i].text.trim().isEmpty
          ? _getDefaultTitle(i)
          : titleControllers[i].text;
      final multiChoice = multiChoiceControllers[i].text.trim();

      await prefs.setString('card_title_$i', title);
      await prefs.setString('card_multichoice_$i', multiChoice);
    }

    setState(() {
      isSaved = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isSaved = false;
        });
      }
    });
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LanguageUtils.getSettingsText(
            'resetToDefaults',
            widget.currentLanguage,
          ),
        ),
        content: Text(
          widget.currentLanguage == 'ja'
              ? '現在入力されているものをリセットしますか？' // Custom JP message
              : 'Are you sure you want to reset current settings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (int i = 0; i < cardCount; i++) {
                titleControllers[i].text = _getDefaultTitle(i);
                multiChoiceControllers[i].text = '';
              }
              _saveSettings();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addCard() async {
    setState(() {
      cardCount++;
      _ensureControllers(cardCount);
      titleControllers[cardCount - 1].text = _getDefaultTitle(cardCount - 1);
      multiChoiceControllers[cardCount - 1].text = '';
    });
    await _saveSettings();
  }

  void _removeCard(int index) async {
    if (cardCount > 1) {
      setState(() {
        cardCount--;
        for (int i = index; i < cardCount; i++) {
          titleControllers[i].text = titleControllers[i + 1].text;
          multiChoiceControllers[i].text = multiChoiceControllers[i + 1].text;
        }
      });
      await _saveSettings();
    }
  }

  void _showQRCode() {
    final Map<String, dynamic> data = {
      'cardCount': cardCount,
      'cards': List.generate(
        cardCount,
        (index) => {
          'title': titleControllers[index].text,
          'multiChoice': multiChoiceControllers[index].text,
        },
      ),
    };
    final jsonString = jsonEncode(data);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Settings'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(
            data: jsonString,
            version: QrVersions.auto,
            backgroundColor: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(result);
        if (data.containsKey('cardCount') && data.containsKey('cards')) {
          setState(() {
            cardCount = data['cardCount'];
            _ensureControllers(cardCount);
            final List<dynamic> cards = data['cards'];
            for (int i = 0; i < cardCount; i++) {
              if (i < cards.length) {
                titleControllers[i].text = cards[i]['title'] ?? '';
                multiChoiceControllers[i].text = cards[i]['multiChoice'] ?? '';
              }
            }
          });
          await _saveSettings();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings imported successfully!')),
            );
          }
        }
      } catch (e) {
        debugPrint('Error parsing QR: $e');
        // ignore
      }
    }
  }

  void _openPresetManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PresetsScreen(
          currentLanguage: widget.currentLanguage,
          currentSettings: {
            'cardCount': cardCount,
            'cards': List.generate(
              cardCount,
              (index) => {
                'title': titleControllers[index].text,
                'multiChoice': multiChoiceControllers[index].text,
              },
            ),
          },
          onLoadPreset: (data) {
            // Load callback
            if (data != null) {
              setState(() {
                cardCount = data['cardCount'];
                _ensureControllers(cardCount);
                final List<dynamic> cards = data['cards'];
                for (int i = 0; i < cardCount; i++) {
                  if (i < cards.length) {
                    titleControllers[i].text = cards[i]['title'] ?? '';
                    multiChoiceControllers[i].text =
                        cards[i]['multiChoice'] ?? '';
                  }
                }
              });
              _saveSettings();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Preset Loaded')));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageUtils.getSettingsText('settings', widget.currentLanguage),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 言語切り替えボタン
          GestureDetector(
            onTap: () {
              final newLanguage = widget.currentLanguage == 'ja'
                  ? 'en'
                  : widget.currentLanguage == 'en'
                  ? 'hi'
                  : 'ja';
              widget.onLanguageChanged(newLanguage);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                LanguageUtils.getFlag(widget.currentLanguage),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore, color: Colors.black87, size: 28),
            tooltip: LanguageUtils.getSettingsText(
              'resetToDefaults',
              widget.currentLanguage,
            ),
          ),
          IconButton(
            onPressed: _addCard,
            icon: const Icon(Icons.add, color: Colors.black87, size: 28),
            tooltip: LanguageUtils.getSettingsText(
              'addCard',
              widget.currentLanguage,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.qr_code, color: Colors.black87, size: 28),
            onSelected: (value) {
              if (value == 'share') {
                _showQRCode();
              } else if (value == 'scan') {
                _scanQRCode();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share via QR'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'scan',
                child: ListTile(
                  leading: Icon(Icons.qr_code_scanner),
                  title: Text('Scan QR'),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Preset Manager Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openPresetManager,
                  icon: const Icon(Icons.list),
                  label: const Text('Manage Presets'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: cardCount,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${LanguageUtils.getSettingsText('card', widget.currentLanguage)} ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (cardCount > 1)
                                  IconButton(
                                    onPressed: () => _removeCard(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: LanguageUtils.getSettingsText(
                                      'deleteCard',
                                      widget.currentLanguage,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: titleControllers[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                hintText: _getDefaultTitle(index),
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: multiChoiceControllers[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                hintText: LanguageUtils.getSettingsText(
                                  'example',
                                  widget.currentLanguage,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                helperText: LanguageUtils.getSettingsText(
                                  'multipleChoices',
                                  widget.currentLanguage,
                                ),
                                helperStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isSaved
                        ? Colors.orange[400]
                        : Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isSaved
                        ? LanguageUtils.getSettingsText(
                            'saved',
                            widget.currentLanguage,
                          )
                        : LanguageUtils.getSettingsText(
                            'save',
                            widget.currentLanguage,
                          ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Upgrade Button if not ad-free or just reachable via presets
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showPurchaseDialog,
                child: const Text('Upgrade Plan / Restore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
