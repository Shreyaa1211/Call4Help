import 'package:call4help/config/secrets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SosService {

  static Future<void> sendSOS() async {

    try {

      /// Get GPS location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String locationLink =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";

      String message =
          "🚨 SOS! I need help.\n\nMy Location:\n$locationLink";


      /// Receiver email
      List<String> emails = [
        ...Secrets.sosRecipients,
      ];

      /// Sender Gmail
      const String gmailUser = Secrets.senderGmail;

      /// Gmail App Password
      const String gmailPassword = Secrets.senderGmailAppPassword;

      final smtpServer = gmail(gmailUser, gmailPassword);

      final emailMessage = Message()
        ..from = const Address(Secrets.senderGmail, 'Call4Help')
        ..recipients.addAll(emails)
        ..subject = "🚨 SOS Alert - Call4Help"
        ..text = message
        ..html = "<h2>SOS Alert</h2><p>$message</p>";

      await send(emailMessage, smtpServer);

      print("📧 SOS Email sent successfully");

    } catch (e) {

      print("❌ SOS Email error: $e");

    }
  }
}
