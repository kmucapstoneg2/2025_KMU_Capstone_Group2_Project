import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'providers/providers.dart';
import 'main_tab_view.dart';
import 'main.dart';

/// ============================================
/// 앱 설정
/// ============================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ClosetProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => OutfitProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: CupertinoApp(
        title: 'Outfit Hub',
        theme: AppTheme.theme,
        home: MainTabView(key: mainTabKey),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
