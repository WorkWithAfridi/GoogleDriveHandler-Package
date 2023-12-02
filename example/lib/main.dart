import 'dart:io';

import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googledrivehandler/googledrivehandler.dart';
import 'package:open_file/open_file.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const GoogleDriveHandlerExampleApp(),
  );
}

class GoogleDriveHandlerExampleApp extends StatelessWidget {
  const GoogleDriveHandlerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  final String myApiKey = "YOUR_API_KEY";

  @override
  Widget build(BuildContext context) {
    GoogleDriveHandler().setAPIKey(
      apiKey: myApiKey,
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
                  /// Do something with the file
                  /// for instance open the file
                  OpenFile.open(myFile.path);
                  print(myFile.path);
                } else {
                  /// Discard...
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
