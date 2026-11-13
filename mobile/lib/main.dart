import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/session_store.dart';
import 'game/level_catalog.dart';
import 'ui/dispatch_screen.dart';
import 'ui/campaign_screen.dart';
import 'ui/main_menu.dart';
import 'ui/academy_screen.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const VaganymesterApp());
}

class VaganymesterApp extends StatelessWidget {
  const VaganymesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF35DDC3);
    return MaterialApp(
      title: 'VÁGÁNYMESTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081721),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF122637),
        ),
      ),
      home: const HomeGate(),
    );
  }
}

class HomeGate extends StatefulWidget {
  const HomeGate({super.key});
  @override
  State<HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<HomeGate> {
  final SessionStore store = SessionStore();
  late final GameAudio audio = GameAudio(store);
  bool academyShowing = false;
  bool loaded = false;
  bool playing = false;
  bool selecting = false;
  GameLevel? currentLevel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await store.load();
    audio.showMenu();
    if (mounted) setState(() => loaded = true);
  }

  @override
  void dispose() {
    audio.dispose();
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        if (playing && currentLevel != null) {
          return DispatchScreen(
            key: ValueKey(currentLevel!.id),
            level: currentLevel!,
            store: store,
            audio: audio,
            onExit: () {
              audio.showMenu();
              setState(() {
              playing = false;
              selecting = true;
              });
            },
            onNext: (level) {
              audio.showGame();
              setState(() {
              currentLevel = level;
              playing = true;
              selecting = false;
              });
            },
          );
        }
        if (academyShowing) {
          return AcademyScreen(
            store: store,
            audio: audio,
            onBack: () {
              audio.showMenu();
              setState(() => academyShowing = false);
            },
            onCampaign: () {
              audio.showMenu();
              setState(() {
                academyShowing = false;
                selecting = true;
              });
            },
          );
        }
        if (selecting) {
          return CampaignScreen(
            store: store,
            onBack: () => setState(() => selecting = false),
            onPlay: (level) {
              if (!store.campaign.isUnlocked(level)) return;
              setState(() {
                currentLevel = level;
                playing = true;
                selecting = false;
              });
            },
          );
        }
        return MainMenu(
          store: store,
          onStart: () => setState(() {
            if (store.academy.campaignUnlocked) {
              selecting = true;
            } else {
              academyShowing = true;
            }
          }),
          onTutorial: () => setState(() => academyShowing = true),
        );
      },
    );
  }
}
