# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## Core Principles

### KISS (Keep It Simple)

- Prefer the simplest solution that actually works
- Avoid premature optimization
- Optimize for clarity over cleverness

### DRY (Don't Repeat Yourself)

- Extract repeated logic into shared functions or utilities
- Avoid copy-paste implementation drift
- Introduce abstractions when repetition is real, not speculative

### YAGNI (You Aren't Gonna Need It)

- Do not build features or abstractions before they are needed
- Avoid speculative generality
- Start simple, then refactor when the pressure is real

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type
- **NO FILE SHOULD EXCEED 600 LINES** - If approaching this limit, extract widgets/classes into new files

## Error Handling

ALWAYS handle errors comprehensively:
- Handle errors explicitly at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Naming Conventions

- Variables and functions: `camelCase` with descriptive names
- Booleans: prefer `is`, `has`, `should`, or `can` prefixes
- Interfaces, types, and components: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Custom hooks: `camelCase` with a `use` prefix
- **FILES**: `snake_case.dart` with specific suffixes:
  - Screen: `_screen.dart` (e.g., `user_profile_screen.dart`)
  - Widget: `_widget.dart` (e.g., `user_profile_widget.dart`)
  - Model: `_model.dart` (e.g., `user_model.dart`)
  - Service: `_service.dart` (e.g., `user_service.dart`)
  - Cubit/Bloc: `_cubit.dart`, `_state.dart` (e.g., `user_cubit.dart`, `user_state.dart`)
- **CLASSES**: `PascalCase` (e.g., `UserProfileScreen`)
- **ENUM MEMBERS**: `camelCase` (e.g., `PaymentStatus.partiallyPaid`) - **strictly avoid snake_case**

## Widget Guidelines

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

## State Management

- **USE CUBIT** for state management
- **Business logic NEVER lives inside widgets**
- **Network calls always go through Repositories → Services → Data providers**
- **Cubits only talk to repositories**
- **Pattern**: UI -> Cubit -> Repository -> Data Source
- **State**: Use `Equatable` for States to ensure efficient rebuilds

## Firebase-Specific Rules

- **For sargon_app all models should be designed for Firebase/Firestore**
- **Firebase Database Structure must be industry level designed** (follow patterns in lib/core/models/)
- **Always use components from lib/component/** (e.g., `@lib/component/inputs/app_phone_field.dart` for phone fields)
- **NEVER EVER HARDCODE BUSINESS RULES** - implement via configurable services or Firebase functions
- **Update Firebase Rules (database.rules.json) whenever adding new screens or data access patterns**

## UI/UX Guidelines (Enterprise Ready)

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

## Testing Rules

- Tests should be auto-generated for:
  - Models (JSON serialization)
  - Repositories
  - Cubits/Blocs
  - Widgets (golden tests optional)
- Tests must use:
  - mocktail
  - flutter_test

## Documentation Rules

- Add dartdoc comments for all classes/methods
- Generate README updates when new features added
- Maintain CHANGELOG.md per release

## Performance Rules

- Use const wherever possible
- Extract heavy widgets
- Debounce rapid API calls
- Cache images & API data
- Enable release-mode optimizations

## Linting Rules

- flutter_lints
- very_good_analysis

## AI-Assisted Generation Rules

When using AI to generate code:
- ✔ Create complete file implementations
- ✔ Maintain folder structure
- ✔ Automatically create missing files
- ✔ Suggest enhancements before writing code
- ✔ Generate most scalable & reusable architecture
- ✔ Never mix UI and business logic
- ✔ Always propose industry-level improvements

## Code Quality Checklist

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
