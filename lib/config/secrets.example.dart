// Copy this file to secrets.dart and fill in your own values.
// secrets.dart is git-ignored so your keys never get committed.
class Secrets {
  /// Free key from https://console.picovoice.ai/
  static const String picovoiceAccessKey = 'YOUR_PICOVOICE_ACCESS_KEY';

  /// Gmail account that sends the SOS email
  static const String senderGmail = 'your.sender@gmail.com';

  /// Gmail App Password (Google Account > Security > App passwords)
  static const String senderGmailAppPassword = 'YOUR_GMAIL_APP_PASSWORD';

  /// Default emergency contacts that receive the SOS email
  static const List<String> sosRecipients = ['emergency.contact@example.com'];
}
