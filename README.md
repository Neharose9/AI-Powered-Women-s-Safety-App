# Flutter Native Safety App (REST API approach)

This folder contains the source code for your **Native Flutter Application**.

Since `flutter` is currently NOT installed or configured in your system's PATH, I have created the source code files for you safely in this directory.

## How to use this project:

1. **Install Flutter:**
   - Download Flutter from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
   - Extract the zip file and add `flutter\bin` to your System Environment Variables (PATH).
   - Open a new terminal and verify installation by running `flutter doctor`.

2. **Initialize the Project:**
   - Once Flutter is installed, open a terminal in this directory (`d:\New folder\flutter_safety_app`).
   - Run the command:
     ```bash
     flutter create .
     ```
   - *This command will automatically generate all necessary Android, iOS, and Web building folders without overwriting the `lib/` Dart source code I just provided.*

3. **Install Dependencies:**
   - Run the following to fetch the packages I listed in `pubspec.yaml`:
     ```bash
     flutter pub get
     ```

4. **Run the App:**
   - Start the Django server in another terminal (`python manage.py runserver`).
   - Run your new Native Flutter app using:
     ```bash
     flutter run
     ```

## Features Implemented
- **Login / Register**: Connects to your newly created Django REST APIs (`api/login/` and `api/register/`).
- **SafetyApp Dashboard**: Fetches user cases dynamically.
- **SOS Button**: Uses the device geolocation to send SOS to your Django backend, which then sends the emails via the API.
