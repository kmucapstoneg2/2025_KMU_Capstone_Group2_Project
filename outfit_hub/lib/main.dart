import 'package:flutter/cupertino.dart';
import 'data/storage.dart';
import 'data/dummy/dummy_data_loader.dart';
import 'app.dart';
import 'main_tab_view.dart';

/// GlobalKey for MainTabView
final GlobalKey<MainTabViewState> mainTabKey = GlobalKey<MainTabViewState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage 초기화
  await Storage.init();

  // 더미 데이터 로드 (개발용)
  // await DummyDataLoader.load();

  runApp(const MyApp());
}
