import 'package:call4help/config/secrets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../services/sos_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  PorcupineManager? _porcupineManager;

  bool _isInitialized = false;
  bool _sosTriggered = false;
  bool _sendingSOS = false;
  bool _sosSent = false;

  int _countdown = 5;

  Timer? _countdownTimer;

  String _statusMessage = "Initializing...";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startApp();
  }

  Future<void> _startApp() async {

    await [
      Permission.microphone,
      Permission.location,
    ].request();

    final service = FlutterBackgroundService();

    if (!await service.isRunning()) {
      service.startService();
    }

    await _initPorcupine();

    if (_isInitialized) {
      await _porcupineManager?.start();
      setState(() {
        _statusMessage = "Listening for 'help'...";
      });
    }
  }

  Future<void> _initPorcupine() async {

    const String accessKey = Secrets.picovoiceAccessKey;

    const String keywordPath = "assets/help.ppn";

    const double sensitivity = 0.5;

    try {

      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        accessKey,
        [keywordPath],
        _wakeWordCallback,
        sensitivities: [sensitivity],
      );

      setState(() {
        _isInitialized = true;
        _statusMessage = "Ready to listen";
      });

    } on PorcupineException catch (e) {

      setState(() {
        _statusMessage = "Error: ${e.message}";
      });

    } catch (e) {

      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  void _wakeWordCallback(int keywordIndex) {

    if (_sendingSOS) return;

    setState(() {
      _sosTriggered = true;
      _sendingSOS = true;
      _countdown = 5;
      _sosSent = false;
    });

    _startCountdown();
  }

  void _startCountdown() {

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {

      if (_countdown == 0) {

        timer.cancel();

        await SosService.sendSOS();

        setState(() {
          _sosSent = true;
          _sendingSOS = false;
        });

        await Future.delayed(const Duration(seconds: 4));

        if (mounted) {
          setState(() {
            _sosTriggered = false;
            _sosSent = false;
          });
        }

      } else {

        setState(() {
          _countdown--;
        });

      }

    });

  }

  void _cancelSOS() {

    _countdownTimer?.cancel();

    setState(() {
      _sosTriggered = false;
      _sendingSOS = false;
      _countdown = 5;
    });

  }

  @override
  void dispose() {

    _pulseController.dispose();

    _porcupineManager?.stop();
    _porcupineManager?.delete();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(


        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade100,
              Colors.pink.shade400,
            ],
          ),
        ),

        child: Stack(

          children: [

            /// MAIN SCREEN

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ScaleTransition(
                    scale: _pulseController.drive(
                      CurveTween(curve: Curves.easeInOut),
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                ],
              ),
            ),

            /// SOS SCREEN

            if (_sosTriggered)
              Container(
                color: Colors.red.shade700,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _sosSent
                        ? Column(
                            key: const ValueKey("sent"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [

                              Icon(
                                Icons.check_circle,
                                size: 120,
                                color: Colors.white,
                              ),

                              SizedBox(height: 20),

                              Text(
                                "SOS SENT",
                                style: TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Emergency contacts notified",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),

                            ],
                          )

                        : Column(
                            key: const ValueKey("countdown"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 120,
                                color: Colors.white,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "SOS ACTIVATED",
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                "$_countdown",
                                style: const TextStyle(
                                  fontSize: 80,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Sending alert...",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 40),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: _cancelSOS,
                                child: const Text(
                                  "CANCEL",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),

                            ],
                          ),
                  ),
                ),
              )

          ],
        ),
      ),
    );
  }
}
