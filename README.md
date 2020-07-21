# Messaging App - Flutter & Firebase
![Made with Love in India](https://madewithlove.org.in/badge.svg)
> version 1.0.0

Messaging app is a nicely designed and developed mobile application developed using Flutter. Flutter is an open-source mobile application development SDK created by Google and used to develop applications for Android and iOS.

Messaging app gives an modern look and feel in the mobile application it has been build using flutter and firebase. It saves lots of hustle and time to develop a nicely designed messaging app Android & iOS. The app is ready to use and can be easily integrated in any flutter project. The code organization is easy to understand any part can be taken out and added into flutter application.

Messaging App comes with 8 screen application pages. It comes with both light and dark theme and works great with both android and ios.

### App Screens

- Signup
- Login
- User Info
- Edit Details
- Home Page
- Messaging page
- Message Detail
- FullScreen Image Page

## Screenshots of the application 

<p>
<img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/auth.png" width="400" />
<img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/main_page.png" width="400"/>
</p>
<p float="left">
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/chat_window.png" width="100" /> 
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/chat_window2.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/sign_out_dialog.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/uid_dialog.png" width="100" /> 
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/user_info.png" width="100" /> 
  </p>
  <p float="left">
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/search_user.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/search_Result.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/received_message_detail.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/theme_settings.png" width="100" />
  <img src="https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/data_dialog.png" width="100" />
</p>
 Working Video https://github.com/AmanNegi/Messaging-App-Flutter-/blob/master/Screenshots/walkthrough.mp4

## Topics Covered

* **Firebase Cloud Firestore**<br/>
Users data, profile image etc is received and stored in the firestore. The messages are also saved there.

* **Messaging through firebase**</br>
The app implements messaging feature as a side feature to help the users communicate.

* **Shared Prefrences**<br/>
Shared prefrences is used to save local user data. eg: User firebase id.

* **Firebase Auth**</br>
For users to login and signUp we have used firebase Auth.

* **Theme settings**</br>
The app provides a number of theme changing options from mainColor to primary font and dark and light Mode.


### Project Structure

```
...
   ├── auth/   #This folder contains auth related files.
   ├── consts/   # This folder contains theme related files.
   ├── data/   # This folder contains data i.e sharedPrefs file and constant strings.
   ├── layout/   # This folder contains all element widgets used in other pages.
   ├── message/   # This folder contains all files regarding the message page and message detail.
   ├── user/   #This folder contains all files regarding the user and userPages.
   ├──app_data.dart   # Contains all the theme related settings of the app
   └── main.dart   # Root file of the project
```

## Project Setup

In order to set up the project, please follow below steps:

### Flutter setup

1. Install package dependencies:

```
flutter pub get
```

2. Go to google firebase and create your own project and extract the googleservices.json.


3. Run the project by running command:

```
flutter run
```

4. Use one of these commands to build the project:

```
flutter build ios
flutter build apk
flutter build appbundle
```

5. If any issue (run the below command to troubleshoot):

```
flutter doctor
```

For help getting started with Flutter, check [online documentation](https://flutter.dev/docs), which offers great tutorials, samples, guidance on mobile development, and a full API reference. If you run into any issue or question, feel free to reach out to us via email akuro787898@gmail.com.

### Flutter packages used in Blogit:

-  firebase_analytics
-  firebase_auth
-  firebase_core
-  google_fonts
-  rxdart
-  fluttertoast
-  firebase_storage
-  image_picker
-  cloud_firestore
-  shared_preferences
-  flutter_clipboard_manager
-  flutter_svg
-  intl
-  material_design_icons_flutter
-  photo_view
-  dynamic_theme
-  shimmer
-  mdi
-  url_launcher
-  cached_network_image

## Authors

>  [**Aman Negi**](https://github.com/AmanNegi) - *Initial work*


## Feel Free to Contract

* Gmail : akuro787898@gmail.com
* Facebook : https://www.facebook.com/flyWithFlutter

