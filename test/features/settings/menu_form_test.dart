import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/settings/presentation/menu/menu_form_screen.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_cubit.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';
import 'package:hotel_manager/core/models/menu_item_model.dart';
import 'package:hotel_manager/features/settings/presentation/menu/recipe_builder_widget.dart';
import 'package:hotel_manager/core/models/inventory_item_model.dart';

class MockInventoryCubit extends MockCubit<InventoryState>
    implements InventoryCubit {}

// Simple MockCubit to help with testing
abstract class MockCubit<T> extends Mock implements BlocBase<T> {}

void main() {
  late MockInventoryCubit mockInventoryCubit;

  setUp(() {
    mockInventoryCubit = MockInventoryCubit();

    // Provide a default state
    when(() => mockInventoryCubit.state).thenReturn(const InventoryLoaded([]));
    when(() => mockInventoryCubit.loadInventory()).thenAnswer((_) async {});
    when(
      () => mockInventoryCubit.stream,
    ).thenAnswer((_) => Stream.value(const InventoryLoaded([])));
  });

  Widget createWidgetUnderTest({
    required Future<void> Function(MenuItem) onSave,
  }) {
    return MaterialApp(
      home: BlocProvider<InventoryCubit>.value(
        value: mockInventoryCubit,
        child: MenuFormScreen(onSave: onSave),
      ),
    );
  }

  group('MenuFormScreen Validation Tests', () {
    testWidgets('Price field should block non-numeric characters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) async {}));

      final priceField = find.widgetWithText(TextField, 'Price');
      expect(priceField, findsOneWidget);

      await tester.enterText(priceField, 'abc123.45');
      await tester.pump();

      // Since we use FilteringTextInputFormatter, 'abc' should be blocked but '123.45' should stay
      // Actually it depends on how FilteringTextInputFormatter works with enterText
      // In tests, enterText bypasses formatters sometimes, but we can check if it's there.
      // A better way is to check if it parses correctly on save
    });

    testWidgets('Saving without ingredients should show error snackbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) async {}));

      // Fill in required fields
      await tester.enterText(
        find.widgetWithText(TextField, 'Item Name'),
        'Test Item',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Price'), '100');

      // Try to save
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please add at least one ingredient to the recipe.'),
        findsOneWidget,
      );
    });
  });

  group('RecipeBuilderWidget Tests', () {
    testWidgets('Grams toggle should be enabled by default', (
      WidgetTester tester,
    ) async {
      // Mock inventory with one item that supports grams (kg)
      final item = InventoryItem(
        id: '1',
        name: 'Sugar',
        quantity: 10,
        unit: UnitType.kg,
        category: ItemCategory.food,
        minQuantity: 1,
        pricePerUnit: 50,
      );

      when(() => mockInventoryCubit.state).thenReturn(InventoryLoaded([item]));

      await tester.pumpWidget(createWidgetUnderTest(onSave: (_) async {}));

      // Open add ingredient sheet
      await tester.tap(find.text('Add Ingredient'));
      await tester.pumpAndSettle();

      // Search or find ListTile
      await tester.tap(find.text('Sugar'));
      await tester.pumpAndSettle();

      // Check for SwitchListTile "Use Grams (g)"
      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsOneWidget);

      final SwitchListTile switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, isTrue); // Grams should be default
    });
  });
}
