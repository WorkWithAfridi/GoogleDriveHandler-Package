import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googledrivehandler/googledrivehandler.dart';
import 'package:open_file/open_file.dart';

// import 'firebase_options.dart';
// Connect firebase

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   // options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
    const GoogleDriveHandlerExampleApp(),
  );
}

class GoogleDriveHandlerExampleApp extends StatelessWidget {
  const GoogleDriveHandlerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  String APIKEY = "YOUR API HERE";

  @override
  Widget build(BuildContext context) {
    GoogleDriveHandler().setAPIKey(
      APIKey: APIKEY,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GoogleDriveHandlerExampleApp",
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                File? myFile = await GoogleDriveHandler().getFileFromGoogleDrive(context: context);
                if (myFile != null) {
                  //Do something with the file
                  //for instance open the file
                  OpenFile.open(myFile.path);
                } else {
                  //Discard...
                }
              },
              child: const Text(
                "Get file from google drive",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
