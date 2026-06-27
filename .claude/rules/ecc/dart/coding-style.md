---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/analysis_options.yaml"
---
# Dart/Flutter Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Dart and Flutter-specific content.

## Formatting

- **dart format** for all `.dart` files — enforced in CI (`dart format --set-exit-if-changed .`)
- Line length: 80 characters (dart format default)
- Trailing commas on multi-line argument/parameter lists to improve diffs and formatting

## Immutability

- Prefer `final` for local variables and `const` for compile-time constants
- Use `const` constructors wherever all fields are `final`
- Return unmodifiable collections from public APIs (`List.unmodifiable`, `Map.unmodifiable`)
- Use `copyWith()` for state mutations in immutable state classes

```dart
// BAD
var count = 0;
List<String> items = ['a', 'b'];

// GOOD
final count = 0;
const items = ['a', 'b'];
```

## Naming

Follow Dart conventions:
- `camelCase` for variables, parameters, and named constructors
- `PascalCase` for classes, enums, typedefs, and extensions
- `snake_case` for file names and library names
- `SCREAMING_SNAKE_CASE` for constants declared with `const` at top level
- Prefix private members with `_`
- Extension names describe the type they extend: `StringExtensions`, not `MyHelpers`

**Note**: For project-specific file naming conventions (e.g., `_screen.dart`, `_widget.dart` suffixes), see the [Project-Specific Rules](#project-specific-rules-from-sargon-app) section below.

## Null Safety

- Avoid `!` (bang operator) — prefer `?.`, `??`, `if (x != null)`, or Dart 3 pattern matching; reserve `!` only where a null value is a programming error and crashing is the right behaviour
- Avoid `late` unless initialization is guaranteed before first use (prefer nullable or constructor init)
- Use `required` for constructor parameters that must always be provided

```dart
// BAD — crashes at runtime if user is null
final name = user!.name;

// GOOD — null-aware operators
final name = user?.name ?? 'Unknown';

// GOOD — Dart 3 pattern matching (exhaustive, compiler-checked)
final name = switch (user) {
  User(:final name) => name,
  null => 'Unknown',
};

// GOOD — early-return null guard
String getUserName(User? user) {
  if (user == null) return 'Unknown';
  return user.name; // promoted to non-null after the guard
}
```

## Sealed Types and Pattern Matching (Dart 3+)

Use sealed classes to model closed state hierarchies:

```dart
sealed class AsyncState<T> {
  const AsyncState();
}

final class Loading<T> extends AsyncState<T> {
  const Loading();
}

final class Success<T> extends AsyncState<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends AsyncState<T> {
  const Failure(this.error);
  final Object error;
}
```

Always use exhaustive `switch` with sealed types — no default/wildcard:

```dart
// BAD
if (state is Loading) { ... }

// GOOD
return switch (state) {
  Loading() => const CircularProgressIndicator(),
  Success(:final data) => DataWidget(data),
  Failure(:final error) => ErrorWidget(error.toString()),
};
```

## Error Handling

- Specify exception types in `on` clauses — never use bare `catch (e)`
- Never catch `Error` subtypes — they indicate programming bugs
- Use `Result`-style types or sealed classes for recoverable errors
- Avoid using exceptions for control flow

```dart
// BAD
try {
  await fetchUser();
} catch (e) {
  log(e.toString());
}

// GOOD
try {
  await fetchUser();
} on NetworkException catch (e) {
  log('Network error: ${e.message}');
} on NotFoundException {
  handleNotFound();
}
```

## Async / Futures

- Always `await` Futures or explicitly call `unawaited()` to signal intentional fire-and-forget
- Never mark a function `async` if it never `await`s anything
- Use `Future.wait` / `Future.any` for concurrent operations
- Check `context.mounted` before using `BuildContext` after any `await` (Flutter 3.7+)

```dart
// BAD — ignoring Future
fetchData(); // fire-and-forget without marking intent

// GOOD
unawaited(fetchData()); // explicit fire-and-forget
await fetchData();      // or properly awaited
```

## Imports

- Use `package:` imports throughout — never relative imports (`../`) for cross-feature or cross-layer code
- Order: `dart:` → external `package:` → internal `package:` (same package)
- No unused imports — `dart analyze` enforces this with `unused_import`

## Code Generation

- Generated files (`.g.dart`, `.freezed.dart`, `.gr.dart`) must be committed or gitignored consistently — pick one strategy per project
- Never manually edit generated files
- Keep generator annotations (`@JsonSerializable`, `@freezed`, `@riverpod`, etc.) on the canonical source file only

## Project-Specific Rules (from sargon_app)

### File Organization
- **NO FILE SHOULD EXCEED 600 LINES** - If approaching this limit, extract widgets/classes into new files

### Widget Guidelines
- **Stateless Preferred**: Use `StatelessWidget` unless local state (like `TextEditingController`) is absolutely necessary
- **Extract Widgets**: If a `build` method exceeds **100 lines**, extract parts into smaller widgets
- **Const Constructors**: Always use `const` where possible
- **Theming**: Access colors/styles via `Theme.of(context)` or `AppColors`. **Do not hardcode hex values**
- **Reusable Components**: Always create reusable widget classes and place them in:
  - `lib/component/` (global/shared)
  - `lib/features/<module>/presentation/widgets/` (module-specific)
- **Every widget must**:
  - Be stateless if possible
  - Use const constructors
  - Accept required params
  - Support theming via context

### State Management
- **USE CUBIT** for state management
- **Business logic NEVER lives inside widgets**
- **Network calls always go through Repositories → Services → Data providers**
- **Cubits only talk to repositories**
- **Pattern**: UI -> Cubit -> Repository -> Data Source
- **State**: Use `Equatable` for States to ensure efficient rebuilds

### Firebase-Specific Rules
- **For sargon_app all models should be designed for Firebase/Firestore**
- **Firebase Database Structure must be industry level designed** (follow patterns in lib/core/models/)
- **Always use components from lib/component/** (e.g., `@lib/component/inputs/app_phone_field.dart` for phone fields)
- **NEVER EVER HARDCODE BUSINESS RULES** - implement via configurable services or Firebase functions
- **Update Firebase Rules (database.rules.json) whenever adding new screens or data access patterns**

### UI/UX Guidelines (Enterprise Ready)
- Consistent spacing & typography → use constants
- Separate light & dark themes
- Use custom reusable components:
  - PrimaryButton
  - AppTextField
  - AppCard
  - AppLoader
  - AppErrorWidget
- Each screen must include:
  - SafeArea
  - Scaffold
  - Scrollable content where needed

### Testing Rules
- Tests should be auto-generated for:
  - Models (JSON serialization)
  - Repositories
  - Cubits/Blocs
  - Widgets (golden tests optional)
- Tests must use:
  - mocktail
  - flutter_test

### Documentation Rules
- Add dartdoc comments for all classes/methods
- Generate README updates when new features added
- Maintain CHANGELOG.md per release

### Performance Rules
- Use const wherever possible
- Extract heavy widgets
- Debounce rapid API calls
- Cache images & API data
- Enable release-mode optimizations

### Linting Rules
- flutter_lints
- very_good_analysis

### AI-Assisted Generation Rules
When using AI to generate code:
- ✔ Create complete file implementations
- ✔ Maintain folder structure
- ✔ Automatically create missing files
- ✔ Suggest enhancements before writing code
- ✔ Generate most scalable & reusable architecture
- ✔ Never mix UI and business logic
- ✔ Always propose industry-level improvements

### Code Quality Checklist
Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] No file exceeds 600 lines (extract widgets if approaching limit)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)
- [ ] No hardcoded business rules
- [ ] Uses reusable components from lib/component/ where applicable
- [ ] Uses AppPhoneField for phone number inputs (not regular text fields)
- [ ] Firebase rules updated for any new data access
- [ ] Tests exist for new functionality (unit/widget/golden as appropriate)
- [ ] Documentation updated (dartdoc, README, CHANGELOG)
