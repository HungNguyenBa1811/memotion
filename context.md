# Role
Act as a Senior Flutter Developer. Your task is to implement a "Medication Reminder" feature that parses a specific API response, saves the data locally, and schedules alarms.
# Tech Stack
- Flutter (Null Safety)
- Packages: `alarm`, `shared_preferences`, `intl` (for date parsing), `json_annotation` (optional, or manual parsing).
# Context & Data
I have an API that returns a list of medication tasks.
- **Base URL for Images:** `http://14.225.218.83:8005`
- **JSON Structure:**
```json
{
  "code": "200",
  "data": [
    {
      "task_id": "c9640785-9dc7-4059-9cd4-972125b0201b",
      "task_duedate": "2026-02-10T08:00:00",
      "medication_detail": {
        "name": "Paracetamol 500mg",
        "dosage": "1 viên",
        "notes": "Uống sau ăn",
        "image_path": "/images/meds/paracetamol.png"
      }
    }
  ]
}
Requirements:
1. Data Model (medication_model.art)
Create a model to parse the JSON.
It must have a method fromJson.
It must have a method toJson (to save to SharedPrefs).
2. Logic Service (scheduler_service.dart
Create a class MedicationScheduler with a static function syncTasks(Map<String, dynamic> apiResponse).
Step A: Parse the data list from the JSON.
Step B: Filter for tasks where task_duedate is in the future.
Step C: Loop through tasks:
Generate a unique int ID from the task_id (UUID) string (Use .hashCode or a similar deterministic method because alarm package requires int IDs).
CRITICAL: Save the specific task's JSON string into SharedPreferences using the key medication_task_$alarmId. This is "The DB" to retrieve details later.
Schedule the alarm using Alarm.set:
id: The generated int ID.
dateTime: Parse task_duedate.
assetAudioPath: 'assets/alarm.mp3'.
notificationTitle: "Time to take ${medication_detail.name}".
notificationBody: "${medication_detail.dosage} - ${medication_detail.notes}".
3. UI Implementation (main.dart)
Initialize Alarm and SharedPreferences in main().
Create a HomePage with a button "Simulate API Sync" (which passes the provided JSON example to SchedulerService).
Alarm Trigger Logic:
Listen to Alarm.ringStream.
When an alarm rings (receiving alarmSettings):
Extract the id.
Retrieve the saved task JSON from SharedPreferences (key: medication_task_$id).
Parse it back to the Model.
Show a Full Screen Dialog / Alert:
Image: http://14.225.218.83:8005 + image_path (Handle error if image is null).
Text: Display Medication Name, Dosage, and Notes clearly.
Button: "Mark as Taken" -> Stop the alarm using Alarm.stop(id).
Constraints:
-NO EMOJIS, SHIT COMMENTS. Comments like a senior, not a tutor
-NO PLACEHOLDERS. Write the full, working code for all 3 files.
-Handle timezone conversion properly (assume the API date is local time or handle parsing correctly).
-Ensure the image_path is concatenated correctly with the Base URL.
-DO NOT MAKE MISTAKES