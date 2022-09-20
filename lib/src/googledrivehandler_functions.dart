import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import 'googledrivehandler_screen.dart';

class GoogleDriveHandler {
  GoogleDriveHandler._internal();
  static final GoogleDriveHandler _googleDriveHandler =
      GoogleDriveHandler._internal();
  factory GoogleDriveHandler() => _googleDriveHandler;

  signIn.GoogleSignInAccount? account;

  String? _GOOGLEDRIVEAPIKEY;

  setAPIKey({required String APIKey}) {
    _GOOGLEDRIVEAPIKEY = APIKey;
  }

  Future getFileFromGoogleDrive({required BuildContext context}) async {
    if (_GOOGLEDRIVEAPIKEY != null) {
      await _signinUser();
      if (account != null) {
        return await _openGoogleDriveScreen(context);
      } else {
        log("Google Signin was declined by the user!");
      }
    } else {
      log('GOOGLEDRIVEAPIKEY has not yet been set. Please follow the documentation and call GoogleDriveHandler().setApiKey(YourAPIKey); to set your own API key');
    }
  }

  _openGoogleDriveScreen(BuildContext context) async {
    final authHeaders = await account!.authHeaders;
    log(account!.displayName.toString());
    final authenticateClient = _GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    drive.FileList fileList = await driveApi.files.list();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoogleDriveScreen(
          fileList: fileList,
          GOOGLEDRIVEAPIKEY: _GOOGLEDRIVEAPIKEY.toString(),
          authenticateClient: authenticateClient,
          userName: account!.displayName!.substring(
            0,
            account!.displayName!.indexOf(" "),
          ),
        ),
      ),
    );
  }

  Future _signinUser() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    account = await googleSignIn.signIn();
    return;
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
