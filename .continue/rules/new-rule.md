---
Sargon: Developing Rules
---

Always Read: ARCHITECTURE.md first and update it when any new feature is added keep it minimal
For sargon_app all the models should be moved to Firebase.
The Firebase Database Structure must be industry level designed!
always use components lib/component/

1. CODING STANDARDS & NAMING RULES

Files
	•	Screen: xyz_screen.dart
	•	Widget: xyz_widget.dart
	•	Model: xyz_model.dart
	•	Service: xyz_service.dart
	•	Cubit/Bloc: xyz_cubit.dart, xyz_state.dart

Classes
	•	Class names in PascalCase.
	•	Private helpers start with _.

Functions
	•	Pure functions preferred.
	•	Use explicit types (do not use var unless necessary).

Widgets
	•	Always separate UI from logic.
	•	Keep widget build method below 100 lines.

2. ALWAYS CREATE REUSABLE WIDGET CLASSES

Cursor must always:
	•	Extract UI portions into reusable widgets when they repeat.
	•	Place reusable widgets under:
	•	core/widgets/ (global)
	•	features/<module>/presentation/widgets/ (module-level widgets)

Every widget must:
	•	Be stateless if possible.
	•	Use const constructors.
	•	Accept required params.
	•	Support theming via context.

3. STATE MANAGEMENT RULES

Use:
	•	Cubit 
Requirements:
	•	Business logic NEVER lives inside widgets.
	•	Network calls always go through Repositories → Services → Data providers.
	•	Cubits only talk to repositories.

4. UI/UX GUIDELINES (ENTERPRISE READY)
	•	Consistent spacing & typography → use constants.
	•	Separate light & dark themes.
	•	Use custom reusable components:
	•	PrimaryButton
	•	AppTextField
	•	AppCard
	•	AppLoader
	•	AppErrorWidget
	•	Each screen must include:
	•	SafeArea
	•	Scaffold
	•	Scrollable content where needed

5. TESTING RULES (Cursor Should Auto-Generate)

	•	Models (JSON)
	•	Repositories
	•	Cubits/Blocs
	•	Widgets (golden tests optional)

Tests must use:
	•	mocktail
	•	flutter_test

6. DOCUMENTATION RULES

	•	Add dartdoc comments for all classes/methods
	•	Generate README updates when new features added
	•	Maintain CHANGELOG.md per release

7.  PERFORMANCE RULES

	•	Use const wherever possible
	•	Extract heavy widgets
	•	Debounce rapid API calls
	•	Cache images & API data
	•	Enable release-mode optimizations

8. LINTING RULES
    flutter_lints
    very_good_analysis

9. AI-ASSISTED GENERATION RULES
    must enforce:

✔ Create complete file implementations

✔ Maintain folder structure

✔ Automatically create missing files

✔ Suggest enhancements before writing code

✔ Generate most scalable & reusable architecture

✔ Never mix UI and business logic

✔ Always propose industry-level improvements

10. No file's number of line must increase 400-600, if it is increasing start create new files for widgets.
