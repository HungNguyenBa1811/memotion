# Role
You are a Senior Flutter Developer.

# Task
Write a complete, runnable Flutter code to fetch health data on **Android ONLY** using the **LATEST version** of the `health` package (v10+).

# CRITICAL CHANGE ALERT (Read Carefully)
- **DO NOT USE `HealthFactory`**. It is deprecated/removed.
- **USE `Health` class** (e.g., `Health()`).
- You **MUST** configure the plugin to use **Health Connect** (not Google Fit) in the `main` function.

# Context
- Device: Android (Samsung Galaxy Watch FE -> Samsung Health -> Health Connect).
- Goal: Display Steps, Heart Rate, and Calories.

# Output Structure (File by File)

## Step 1: `pubspec.yaml`
- Add `health: ^10.0.0` (or latest).
- Add `permission_handler`.

## Step 2: `android/app/src/main/AndroidManifest.xml` (MANDATORY)
- Provide the **EXACT** XML snippet.
- **Permissions:**
  - `ACTIVITY_RECOGNITION`
  - `READ_STEPS`, `READ_HEART_RATE`, `READ_TOTAL_CALORIES_BURNED`, `READ_EXERCISE`.
- **Activity Alias (CRITICAL for Android 14+):**
  - Add the `<activity-alias>` for `ViewPermissionUsageActivity`.
  - Add `<meta-data android:name="health_permissions" android:resource="@array/health_permissions" />` (if required by latest docs, otherwise stick to standard alias).

## Step 3: `lib/main.dart` (The Logic)
- **Init:** Inside `main()`, call `Health().configure(useHealthConnect: true)`.
- **Data Types:** `[HealthDataType.STEPS, HealthDataType.HEART_RATE, HealthDataType.ACTIVE_ENERGY_BURNED]`.
- **Authorization:**
  - Use `Health().requestAuthorization(types)`.
  - Handle the case where user denies permissions.
- **Fetching Data:**
  - **Steps & Calories:** Use `Health().getHealthDataFromTypes(...)` filtering by `DateTime.now().startOfDay`. Then **sum up** the values manually (since `value` is now a `NumericHealthValue`).
  - **Heart Rate:** Get the list and take the **last** (most recent) item.
- **UI:**
  - A clean screen with a "Refresh" button.
  - Display the total values.
  - Show "0" if data is null/empty.

# Tone
Strict code only. Do not explain standard Flutter widgets. Focus on the `health` package implementation.