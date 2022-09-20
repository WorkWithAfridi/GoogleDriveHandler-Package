# GoogleDriveHandler

## A package for viewing, browsing, searching, downloading and uploading Google Drive files.

A package for viewing, browsing, searching, downloading and uploading Google Drive files. Once triggered and authenticated, users can view their own Google Drive contents, browse and download them, they can even upload files directly from the app to their Google Drive storage.

## Images/ Screenshots

//To be added later

## Features

- Browsing User Google Drive Files
- Searching User Google Drive Files
- Downloading User Google CDrive Files
- Uploading Files to the Users Google Drive

## Getting started

* Import this package!

* Android:

// None

* iOS:

For Google Sign in to work on iOS devices we need to follow the following steps:

iOS integration
This plugin requires iOS 9.0 or higher.
1. First register your application.
2. Make sure the file you download in step 1 is named GoogleService-Info.plist.
3. Move or copy GoogleService-Info.plist into the [my_project]/ios/Runner directory.
4. Open Xcode, then right-click on Runner directory and select Add Files to "Runner".
5. Select GoogleService-Info.plist from the file manager.
6. A dialog will show up and ask you to select the targets, select the Runner target.
7. Then add the CFBundleURLTypes attributes below into the [my_project]/ios/Runner/Info.plist file.

````plist

<!-- Put me in the [my_project]/ios/Runner/Info.plist file -->
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.861823949799-vc35cprkp249096uujjn0vvnmcvjppkn</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->

````

As an alternative to adding GoogleService-Info.plist to your Xcode project, you can instead configure your app in Dart code. In this case, skip steps 3-6 and pass clientId and serverClientId to the GoogleSignIn constructor:

````plist

GoogleSignIn _googleSignIn = GoogleSignIn(
  ...
  // The OAuth client id of your app. This is required.
  clientId: ...,
  // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
  serverClientId: ...,
);

````

Note that step 7 is still required.

* Integrate Firebase to your project, and active authentication

* Add Google Signin Authentication from firebase

* Generate SHA Keys by
  1. “cd android”
  2. “./gradlew signingReport”

* Add SHA Keys to firebase project settings for Google Auth

* Then head over to https://console.cloud.google.com and ACTIVATE GOOGLE DRIVE API for the project

* Then search for Credentials on cloud console and CREATE NEW CREDENTIAL (API KEY) <- You'll need this key later!

* Create instance of the GoogleDriveHandler class, setAPIKey and call the getFileFromGoogleDrive function with the required parameters, that being the context, and thats it!! :D BUT BEFORE THAT...

* Copy the APIKEY and use GoogleDriveHandler().setApiKey(APIKey); to set your key

* And then finally call GoogleDriveHandler().getFilesFromGoogleDrive(context); to get the google drive file list

## PLEASE BE ADVISED

* Clicking on any file on the Google Drive interface will download the file and store it in the apps cache, and return an instance of the file instance to the calling method, that being GoogleDriveHandler().getFilesFromGoogleDrive(context), in other words, that function returns an instance of the clicked file.

* The resulting download file is saved in `NSTemporaryDirectory` on iOS and application Cache directory on Android, so it can be lost later, you are responsible for storing it somewhere permanent (if needed).

### Required parameters

* **BUILD CONTEXT** for Navigaton

* **Google Drive APIKEY** for Google Drive related functionalaties

## Additional information

* Packages used in this project.
* firebase_auth: ^3.9.0
* firebase_core: ^1.22.0
* google_sign_in: ^5.4.1
* googleapis: ^9.2.0
* http: ^0.13.5
* path_provider: ^2.0.11

## Example

````dart

import 'package:googleDriveHandler/googleDriveHandler.dart';
import 'dart:io';

Future getFileFromGoogleDrive() async {
  File? file;
  GoogleDriveHandler().setAPIKey(APIKey: YourAPIKEY);
  File? myFile = await GoogleDriveHandler().getFileFromGoogleDrive(context: context);
  if (myFile != null) {
    //Do something with the file
  } else{
    //Discard...
  }
}

````

## Questions ?

* If you have any questions feel free to contact me at: khondakarafridi35@gmail.com