import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleDriveScreen extends StatefulWidget {
  const GoogleDriveScreen({
    super.key,
    required this.fileList,
    required this.googleDriveApiKey,
    required this.authenticateClient,
    required this.userName,
  });

  // This is the file list received from the users google drive, folders are automatically and the contents are extracted and added onto this list!
  final FileList fileList;

  // This is the authenticated users display name, extracted from the google signin process.
  final String userName;

  // This is the developers GOOGLE CLOUD CONSOLE API CREDENTIAL KEY.
  final String googleDriveApiKey;

  // This is the authenticaedClient, generated after the signing in process.
  final authenticateClient;

  @override
  State<GoogleDriveScreen> createState() => _GoogleDriveScreenState();
}

class _GoogleDriveScreenState extends State<GoogleDriveScreen> {
  // global key is created to avoid the transfer of context across async gaps error
  final GlobalKey<ScaffoldState> contextKey = GlobalKey<ScaffoldState>();
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
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        key: contextKey,
        appBar: AppBar(
          elevation: 3,
          //backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              //color: Colors.black,
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
                  style: const TextStyle(
                    // fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
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
                    //color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
                size: 22,
                //color: Colors.black,
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Default top padding
                    const SizedBox(
                      height: 8,
                    ),
                    // List of files from the authenticated users Google drive account
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      //itemCount: widget.fileList.files!.toList().length,
                      children: [...gridListItems()],
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
          "https://www.googleapis.com/drive/v3/files/${file.id}/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&key=${widget.googleDriveApiKey} HTTP/1.1";

      response = await authenticateClient.get(
        Uri.parse(url),
      );
    } else if (!fileMimeType.contains(".folder")) {
      // If the file is uploaded from somewhere else or if the file is not a google doc file process it with the "Files: Get" process.
      String url =
          "https://www.googleapis.com/drive/v3/files/$fileId?includeLabels=alt%3Dmedia&alt=media&key=${widget.googleDriveApiKey} HTTP/1.1";

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

  //Creates a dialogue when a file is tapped and asks if user wants to download it
  Future<void> showDownloadDialogue(File file, var authenticateClient) async {
    switch (await showDialog<int>(
      context: contextKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Download'),
        content: Text(
          '${file.name!} ?',
          maxLines: 2,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: const Text('Yes'),
          ),
        ],
      ),
    )) {
      case 1:
        await _onItemTap(file, authenticateClient);
        break;
      case 2:
        break;
    }
  }

  List<Widget> gridListItems() {
    // loops through file list and returns the list items
    List<Widget?> listOfwidgets = widget.fileList.files!.toList().map((file) {
      if (searchVal == null) {
        // If searchVal is null, show all files and folders.
        return (file.mimeType!.contains(".folder")
            ?
            // if the list contains folders, ignore the folders. Since all the contents from the folders are already extracted and added in the file list.
            null
            : Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () async {
                    await showDownloadDialogue(file, widget.authenticateClient);
                  },
                  child: _ItemCard(
                    file: file,
                  ),
                ),
              ));
      } else {
        // if the searchVal is not null return only the files that contatins the searchVal in their name
        if (file.name!.toLowerCase().contains(searchVal!.toLowerCase())) {
          return file.mimeType!.contains(".folder")
              ? null
              : Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      await showDownloadDialogue(
                          file, widget.authenticateClient);
                    },
                    child: _ItemCard(
                      file: file,
                    ),
                  ),
                );
        } else {
          // Ignore if the file name does not contain the searchVal term.
          return null;
        }
      }
    }).toList();

    // removes all null values from the list
    listOfwidgets.removeWhere((element) => element == null);

    // To convert the List<Widget?> to List<Widget>
    List<Widget> newWidgetList =
        listOfwidgets.map<Widget>((item) => item!).toList();
    return newWidgetList;
  }
}

// This is the custom widget which lays out the google drive files.
class _ItemCard extends StatelessWidget {
  _ItemCard({
    Key? key,
    required this.file,
  }) : super(key: key);

  final File file;

  // Add other mimeTypes here
  final List<String> videoFileExt = ["video/mp4", "audio/mp4"];
  final List<String> powerpointExt = [
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "application/vnd.google-apps.presentation"
  ];
  final List<String> pdfExt = ["application/pdf"];
  final List<String> picExt = ["image/jpeg"];
  @override
  Widget build(BuildContext context) {
    // Set icon to display according to file mimeType
    Widget displayIcon = videoFileExt.contains(file.mimeType)
        ? const Icon(
            Icons.video_file,
            color: Colors.amberAccent,
            size: 50,
          )
        : powerpointExt.contains(file.mimeType)
            ? const Icon(
                Icons.slideshow,
                color: Colors.white,
                size: 50,
              )
            : pdfExt.contains(file.mimeType)
                ? const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 50,
                  )
                : picExt.contains(file.mimeType)
                    ? const Icon(
                        Icons.image,
                        color: Colors.purple,
                        size: 50,
                      )
                    : const Icon(
                        Icons.description,
                        color: Colors.lightBlue,
                        size: 50,
                      );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 2,
              child: Card(
                margin: const EdgeInsets.all(5),
                color: ThemeData.dark().primaryColorDark,
                child: displayIcon,
              )),
          const SizedBox(
            height: 3,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              child: Text(
                file.name!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
