import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/consent_manager.dart';
import '../utils/privacy_policy_content.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.currentLanguage});

  final String currentLanguage;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _privacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyOptions();
  }

  Future<void> _checkPrivacyOptions() async {
    final required = await ConsentManager.instance.isPrivacyOptionsRequired();
    if (mounted) setState(() => _privacyOptionsRequired = required);
  }

  Future<void> _openUrl(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.currentLanguage;
    final sections = PrivacyPolicyContent.sections(lang);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          PrivacyPolicyContent.title(lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_privacyOptionsRequired) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.tune),
                label: Text(PrivacyPolicyContent.adPrivacySettings(lang)),
                onPressed: () async {
                  await ConsentManager.instance.showPrivacyOptionsForm();
                  await _checkPrivacyOptions();
                },
              ),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < sections.length; i++) ...[
              Text(
                sections[i].heading,
                style: TextStyle(
                  fontSize: i == 0 ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                sections[i].body,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
            ],
            InkWell(
              onTap: () => _openUrl(
                Uri(
                  scheme: 'mailto',
                  path: PrivacyPolicyContent.contactEmail,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    PrivacyPolicyContent.contactEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () =>
                  _openUrl(Uri.parse(PrivacyPolicyContent.onlinePolicyUrl)),
              child: Row(
                children: [
                  const Icon(Icons.open_in_new, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      PrivacyPolicyContent.viewOnline(lang),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              PrivacyPolicyContent.effective(lang),
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
