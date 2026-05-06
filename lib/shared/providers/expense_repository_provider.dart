import 'package:riverpod/riverpod.dart';

// Provider for accessing expenses from Hive storage
final expenseRepositoryProvider = Provider((ref) {
  return ExpenseRepository();
});

class ExpenseRepository {
  // Placeholder for future database/repository logic
  // This can be extended for API calls or other data sources
}
