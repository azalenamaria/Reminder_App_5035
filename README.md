# Reminder_App_5035
This is a prototype for the task reminder app (No firebase server, authentication, etc). It can be hosted locally.

This app is used to manage daily tasks with categories and priorities. As it is state only, reloading the app will reset all data.

For the initial release:
 - In memory, create, read, update, and delete tasks.
 - Categorize tasks
 - Set priority levels (Low, Medium, High, Urgent).
 - Filet tasks by category and priority.
 - Mark tasks complete/incomplete
 - Set due dates for tasks
 - Sample data to test on start up.

It does not include:
- Database
- Backend
- Auto-Priority escalation
- data presistence
- User Authentication

To Start (hypotetically - did most of coding on online IDE):
  1) Download flutter SDK and IDE.
  2) On bash: flutter create task_reminder_app
              cd task_reminder_app
  3) Replace files: lib/main.dart, lib.task_models.dart, pubspec.yaml. Replaced files are all under lib/
  4) Get dependencies, on bash: flutter pub get
  5) Run app, for android / ios: flutter run.

 Alternatively, on release page, there is a built-in apk. Just download and run on mobile device.

 The project is done with assistance from Claude to learn flutter and my own tweaking so it will run.
       
