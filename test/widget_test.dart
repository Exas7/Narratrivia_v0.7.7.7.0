import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:narratrivia/main.dart';
import 'package:narratrivia/providers/settings_provider.dart';
import 'package:narratrivia/providers/game_provider.dart';
import 'package:narratrivia/screens/main_menu_screen.dart';
import 'package:narratrivia/widgets/image_button.dart';
import 'package:narratrivia/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MyApp shows SplashScreen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('MainMenuScreen has four ImageButtons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainMenuScreen(),
      ),
    );

    expect(find.byType(ImageButton), findsNWidgets(4));
  });

  testWidgets('ImageButton calls onPressed when tapped', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ImageButton(
          imagePath: 'assets/images/buttons/pulsante_generico.png',
          text: 'Test',
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.byType(ImageButton));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
