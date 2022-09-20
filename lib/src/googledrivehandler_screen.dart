import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleDriveScreen extends StatefulWidget {
  GoogleDriveScreen({
    super.key,
    required this.fileList,
    required this.GOOGLEDRIVEAPIKEY,
    required this.authenticateClient,
    required this.userName,
  });

  // This is the file list received from the users google drive, folders are automatically and the contents are extracted and added onto this list!
  FileList fileList;
  // This is the authenticated users display name, extracted from the google signin process.
  String userName;
  // This is the developers GOOGLE CLOUD CONSOLE API CREDENTIAL KEY.
  String GOOGLEDRIVEAPIKEY;
  // This is the authenticaedClient, generated after the signing in process.
  var authenticateClient;

  @override
  State<GoogleDriveScreen> createState() => _GoogleDriveScreenState();
}

class _GoogleDriveScreenState extends State<GoogleDriveScreen> {
  //On every search input this function gets called, and the search value (searchVal gets updated).
  onSearchFieldChange(String val) {
    setState(() {
      searchVal = val;
    });
    // If the input value is null, set searchVal to null.
    // When the searchVal is set as null the listWill show all the elements.
    if (val.isEmpty) {
      setState(() {
        searchVal = null;
      });
    }
  }

  // Keeps a track of the search toogle.
  bool showSearchTextForm = false;

  // This is the search value based on which the search results are shown,
  String? searchVal;

  // This is the search text editing controller.
  // We wont be using this controller.
  TextEditingController searchController = TextEditingController();

  // Keeps a track on whether the UI is loading or not
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.black,
          ),
        ),

        // Title widget changes base on whether user toggles search on not.
        title: showSearchTextForm
            ?
            // when search has been toggled this title Widget will be shown.
            // This is the text input field where users will input their search term
            TextFormField(
                controller: searchController,
                // textAlignVertical: TextAlignVertical.center,
                onChanged: (String value) {
                  onSearchFieldChange(value);
                },
                style: TextStyle(
                  // fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                ),
              )
            :
            //Default title widget
            Text(
                "${widget.userName}'s Google Drive",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearchTextForm = !showSearchTextForm;
                searchVal = null;
              });
            },
            icon: Icon(
              showSearchTextForm ? Icons.close : Icons.search,
              size: 18,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Default top padding
                  const SizedBox(
                    height: 10,
                  ),
                  // List of files from the authenticated users Google drive account
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.fileList.files!.toList().length,
                    itemBuilder: ((context, index) {
                      File file = widget.fileList.files!.toList()[index];

                      if (searchVal == null) {
                        // If searchVal is null, show all files and folders.
                        return (file.mimeType!.contains(".folder")
                            ?
                            // if the list contains folders, ignore the folders. Since all the contents from the folders are already extracted and added in the file list.
                            const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    await _onItemTap(
                                        file, widget.authenticateClient);
                                  },
                                  child: _ItemCard(
                                    file: file,
                                    fileList: widget.fileList,
                                    index: index,
                                  ),
                                ),
                              ));
                      } else {
                        // if the searchVal is not null return only the files that contatins the searchVal in their name
                        if (file.name!
                            .toLowerCase()
                            .contains(searchVal!.toLowerCase())) {
                          return file.mimeType!.contains(".folder")
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _onItemTap(
                                          file, widget.authenticateClient);
                                    },
                                    child: _ItemCard(
                                      file: file,
                                      fileList: widget.fileList,
                                      index: index,
                                    ),
                                  ),
                                );
                        } else {
                          // Ignore if the file name does not contain the searchVal term.
                          return const SizedBox.shrink();
                        }
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
          // If is loading show, circular progress indicator.
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlue,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> _onItemTap(File file, var authenticateClient) async {
    setState(() {
      isLoading = true;
    });
    String fileName = file.name!;
    String fileId = file.id!;
    String fileMimeType = file.mimeType!;

    http.Response? response;

    if (fileMimeType.contains("spreadsheet") && !fileName.contains(".xlsx")) {
      //If the file is a google doc file, export the file as instructed by the google team.
      String url =
          "https://www.googleapis.com/drive/v3/files/${file.id}/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&key=${widget.GOOGLEDRIVEAPIKEY} HTTP/1.1";

      response = await authenticateClient.get(
        Uri.parse(url),
      );
    } else if (!fileMimeType.contains(".folder")) {
      // If the file is uploaded from somewhere else or if the file is not a google doc file process it with the "Files: Get" process.
      String url =
          "https://www.googleapis.com/drive/v3/files/$fileId?includeLabels=alt%3Dmedia&alt=media&key=${widget.GOOGLEDRIVEAPIKEY} HTTP/1.1";

      response = await authenticateClient.get(
        Uri.parse(url),
      );
    }

    if (response != null) {
      // Get temporary application document directory
      final dir = await getApplicationDocumentsDirectory();
      // Create custom path, where the downloaded file will be saved. TEMPORARILY
      String path = "${dir.path}/${file.name}";
      // Save the file
      io.File myFile = await io.File(path).writeAsBytes(response.bodyBytes);
      // Returns the files
      Navigator.pop(
        context,
        myFile,
      );
    }
    setState(() {
      isLoading = false;
    });
  }
}

// This is the custom widget which lays out the google drive files.
class _ItemCard extends StatelessWidget {
  _ItemCard({
    Key? key,
    required this.file,
    required this.fileList,
    required this.index,
  }) : super(key: key);

  int index;
  final File file;
  final FileList fileList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description,
            color: Colors.lightBlue,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              fileList.files!.toList()[index].name!,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
