import 'package:flutter/cupertino.dart';
import 'data/storage.dart';
import 'app.dart';
import 'main_tab_view.dart';

/// GlobalKey for MainTabView
final GlobalKey<MainTabViewState> mainTabKey = GlobalKey<MainTabViewState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage 초기화 (코드 테이블 및 위시리스트용 - 향후 백엔드 API로 전환 예정)
  await Storage.init();

  runApp(const MyApp());
}
