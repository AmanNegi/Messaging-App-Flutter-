# Blogit - Flutter UI Kit

> version 1.0.0

Blogit is a nicely designed and developed mobile application UI kit developed using Flutter. Flutter is an open-source mobile application development SDK created by Google and used to develop applications for Android and iOS.

Blogit makes an easy job for developer to have the modern look and feel in the mobile application. It saves lots of hustle and time to develop a nicely design Blog App UI for modern mobile application. Blogit is ready to use and can be easily integrated in any flutter project. The code organization is easy to understand any part can be taken out and added into flutter application.

Blogit comes with 7 screen application pages. It comes with both light and dark theme and works great with both android and ios.

### App Screens

- Splash Screen
- Signup
- Login
- Forget Password
- Profile
- Home Page
- Blog Detail Page

### Project Structure

```
...
   ├── data/   #This folder contains the dummy data used for the offline version of app.
   ├── elements/   # This folder is an helper folder to the pages folder,it contains many files, each of which corresponds to different widget element of a screen.
   ├── pages/   # This folder contains many files each of which corresponds to the different screens of the app.
   ├── models/   # This folder contains all model classes of the app.
   ├──app_theme.dart   # Contains all the theme related settings of the app
   ├──route_generator.dart   # Contains the routes used throughout the app.
   └── main.dart   # Root file of the project
```

## Project Setup

In order to set up the project, please follow below steps:

### Flutter setup

1. Install package dependencies:

```
flutter pub get
```

2. Run the project by running command:

```
flutter run
```

3. Use one of these commands to build the project:

```
flutter build ios
flutter build apk
flutter build appbundle
```

4. If any issue (run the below command to troubleshoot):

```
flutter doctor
```

For help getting started with Flutter, check [online documentation](https://flutter.dev/docs), which offers great tutorials, samples, guidance on mobile development, and a full API reference. If you run into any issue or question, feel free to reach out to us via email rishabh@technofox.com

### Flutter packages used in Blogit:

- shared_preferences
- cupertino_icons
- mdi
- google_fonts
