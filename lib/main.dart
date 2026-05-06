import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/models/expense.dart';
import 'core/constants/app_constants.dart';
import 'features/home/view/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(ExpenseAdapter.typeIdValue)) {
    Hive.registerAdapter(ExpenseAdapter());
  }
  await Hive.openBox<Expense>(AppConstants.expenseBoxName);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MExpense',
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
