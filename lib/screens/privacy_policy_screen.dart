import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/language_utils.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.currentLanguage});

  final String currentLanguage;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LanguageUtils.getPrivacyPolicyText(
            'privacyPolicy',
            widget.currentLanguage,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'privacyPolicyTitle',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'privacyPolicyDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'informationCollected',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'informationCollectedDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'dataTransmission',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'dataTransmissionDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'advertising',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'advertisingDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'contact',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'contactDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'inter0370@gmail.com',
                      query: 'subject=',
                    );
                    await launchUrl(emailLaunchUri);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.email, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'inter0370@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse('https://github.com/FinleyCox');
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.link, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'GitHub : https://github.com/FinleyCox',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'revision',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageUtils.getPrivacyPolicyText(
                    'revisionDescription',
                    widget.currentLanguage,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
