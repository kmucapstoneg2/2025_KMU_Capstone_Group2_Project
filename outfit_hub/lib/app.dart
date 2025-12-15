import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'providers/providers.dart';
import 'main_tab_view.dart';
import 'main.dart';
import 'features/auth/pages/login_page.dart';

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
          create: (_) => AuthProvider()..init(),
        ),
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
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// ============================================
/// 인증 래퍼 - 로그인 상태에 따라 화면 전환
/// ============================================

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasLoadedInitialData = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 인증된 사용자 (로그인 또는 게스트)
        if (authProvider.isAuthenticated) {
          // 최초 1회만 데이터 로드
          if (!_hasLoadedInitialData) {
            _hasLoadedInitialData = true;
            final token = authProvider.accessToken ?? '';
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final closet = context.read<ClosetProvider>();
              print('[AuthWrapper] Loading code tables...');
              await closet.loadCodeTables(token: token);
              print('[AuthWrapper] Code tables loaded');
              if (token.isNotEmpty) {
                print('[AuthWrapper] Loading clothes...');
                await closet.loadClothes(token);
                print('[AuthWrapper] Clothes loaded');
              }
            });
          }
          return MainTabView(key: mainTabKey);
        }
        
        // 미인증 상태 - 로그인 페이지
        return const LoginPage();
      },
    );
  }
}
