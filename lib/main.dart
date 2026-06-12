import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/products/presentation/screens/products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConstants.productsCacheBox);
  await Hive.openBox<dynamic>(AppConstants.wishlistBox);
  await Hive.openBox<dynamic>(AppConstants.recentSearchesBox);
  await Hive.openBox<dynamic>(AppConstants.cartBox);

  runApp(const ProviderScope(child: FetchMartApp()));
}

class FetchMartApp extends StatelessWidget {
  const FetchMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ProductsScreen(),
    );
  }
}
