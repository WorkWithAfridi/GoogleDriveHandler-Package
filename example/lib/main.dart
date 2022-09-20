import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googledrivehandler/googledrivehandler.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
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
  String APIKEY = "YOUR_GOOGLE_DRIVE_API_KEY";

  @override
  Widget build(BuildContext context) {
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
                GoogleDriveHandler().setAPIKey(
                  APIKey: APIKEY,
                );
                File? myFile = await GoogleDriveHandler()
                    .getFileFromGoogleDrive(context: context);
                if (myFile != null) {
                  //Do something with the file
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
