import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class WhatsAppHelper {
  /// Opens WhatsApp with a pre-filled message
  static Future<void> openWhatsApp({
    required String phone,
    required String message,
    required BuildContext context,
  }) async {
    // 1. Clean the phone number (remove spaces, dashes, etc.)
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 2. Ensure it has a country code (if not already present, we assume a default or the user provides it)
    // Most users in this app context might use local formats, but WhatsApp needs international.
    // For now, we assume the user has entered it correctly or we prepend '+' if missing in the cleaned string.
    if (!phone.startsWith('+')) {
      // Logic for adding default country code can be added here if needed
    }

    // 3. Construct the URL
    // Format: https://wa.me/number?text=urlencodedtext
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}"
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open WhatsApp. Please make sure it's installed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
