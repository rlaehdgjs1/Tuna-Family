import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/notice_provider.dart';
import 'providers/music_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('ko_KR', null);
  } catch (_) {}

  // Initialize System Push Notification Service
  try {
    await NotificationService().init();
  } catch (_) {}

  runApp(const TunaFamilyApp());
}

class TunaFamilyApp extends StatelessWidget {
  const TunaFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: MaterialApp(
        title: '참치패밀리 공지방',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
