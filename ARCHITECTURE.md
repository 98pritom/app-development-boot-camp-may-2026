# MExpense App - Architecture Documentation

## Overview

This project follows a **Feature-Based Architecture** with clear separation of concerns between **Core**, **Features**, and **Shared** layers.

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Core functionality & shared utilities
│   ├── constants/
│   │   └── app_constants.dart   # App-wide constants
│   ├── models/
│   │   └── expense.dart         # Expense model & Hive adapter
│   └── theme/
│       └── app_theme.dart       # Theme configuration
├── features/                    # Feature modules
│   ├── home/                    # Home tab - View expenses
│   │   ├── view/
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart           # Main home tab
│   │   │   │   └── expense_detail_screen.dart # Expense details
│   │   │   └── widgets/
│   │   │       ├── expense_list_view.dart     # Expenses list widget
│   │   │       └── expense_summary.dart       # Total & monthly summary
│   │   └── view_model/
│   │       └── home_view_model.dart           # Home state management
│   ├── add_expense/             # Add/Edit expense feature
│   │   ├── view/
│   │   │   └── screens/
│   │   │       ├── add_expense_screen.dart    # Container screen
│   │   │       └── add_expense_form.dart      # Form implementation
│   │   └── view_model/
│   │       └── add_expense_view_model.dart    # Form state management
│   └── insights/                # Insights/Analytics tab
│       └── view/
│           └── screens/
│               └── insights_screen.dart       # Analytics & summary
└── shared/                      # Shared components & utilities
    ├── components/
    │   └── expense_card.dart    # Reusable expense card widget
    └── providers/
        └── expense_repository_provider.dart   # Shared providers
```

## Architecture Principles

### 1. **Feature-Based Folders**
Each feature (home, add_expense, insights) is self-contained with its own view and view_model.

### 2. **View / ViewModel Separation**
- **View**: UI widgets and screens - handles presentation only
- **ViewModel**: State management using Riverpod Notifier providers

### 3. **Core Layer**
Contains app-wide utilities:
- Models and domain objects
- Theme configuration
- Application constants
- Services and utilities

### 4. **Shared Layer**
Contains reusable components and utilities:
- Shared widgets (ExpenseCard)
- Shared providers and repositories
- Common utilities

## State Management

Uses **Riverpod 3.x** with `Notifier` pattern:

```dart
// View Model Example
final addExpenseProvider = NotifierProvider<AddExpenseNotifier, AddExpenseState>(
  AddExpenseNotifier.new,
);

class AddExpenseNotifier extends Notifier<AddExpenseState> {
  @override
  AddExpenseState build() => const AddExpenseState();
  
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }
}
```

## Features

### Home Feature (`features/home/`)
- Display list of expenses
- Show total amount and monthly summary
- Edit/delete expenses
- Navigate to expense details

### Add Expense Feature (`features/add_expense/`)
- Add new expenses
- Edit existing expenses
- Select category from predefined list
- Pick date (within last 7 days)
- Add optional notes

### Insights Feature (`features/insights/`)
- Monthly expense comparison
- Category breakdown
- Spending trends analysis
- Month-over-month changes

## Key Components

### Models
- `Expense`: Core model with Hive adapter for persistence

### State Classes
- `HomeState`: Current tab index
- `AddExpenseState`: Form state (category, date selection)

### Providers
- `homeProvider`: Home tab navigation state
- `addExpenseProvider`: Add expense form state

## Data Persistence

Uses **Hive** for local storage:
- Expenses stored in Hive box: `'expenses'`
- Automatic persistence with Hive adapters
- ValueListenableBuilder for reactive UI updates

## Constants

All app constants are centralized in `core/constants/app_constants.dart`:
- Expense categories
- Hive box name
- Date range constraints

## Naming Conventions

- **Screens**: `{feature_name}_screen.dart` or `{action}_screen.dart`
- **Widgets**: `{descriptive_name}.dart`
- **ViewModels**: `{feature_name}_view_model.dart`
- **State Classes**: `{Feature}State` and `{Feature}Notifier`
- **Providers**: `{feature}Provider`

## Adding New Features

1. Create folder: `features/{feature_name}/`
2. Add subfolders: `view/screens/`, `view/widgets/`, `view_model/`
3. Create view model: `{feature_name}_view_model.dart`
4. Create screens and widgets
5. Update main imports

Example:
```
features/new_feature/
├── view/
│   ├── screens/
│   │   └── new_feature_screen.dart
│   └── widgets/
│       └── custom_widget.dart
└── view_model/
    └── new_feature_view_model.dart
```

## Testing

- Unit tests for ViewModels
- Widget tests for UI components
- Integration tests for feature workflows

## Best Practices

1. **Keep Views Simple**: Only UI logic, no business logic
2. **Centralize State**: Use ViewModel for all state changes
3. **Reuse Components**: Use shared folder for common widgets
4. **Type Safety**: Use proper typing and avoid dynamic
5. **Error Handling**: Validate inputs in forms and handle errors gracefully
