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

  FileList fileList;
  String userName;
  String GOOGLEDRIVEAPIKEY;
  var authenticateClient;

  @override
  State<GoogleDriveScreen> createState() => _GoogleDriveScreenState();
}

class _GoogleDriveScreenState extends State<GoogleDriveScreen> {
  onSearchFieldChange(String val) {
    setState(() {
      searchVal = val;
    });
    if (val.isEmpty) {
      setState(() {
        searchVal = null;
      });
    }
  }

  bool showSearchTextForm = false;
  String? searchVal;
  TextEditingController searchController = TextEditingController();
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
        title: showSearchTextForm
            ? TextFormField(
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
            : Text(
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
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.fileList.files!.toList().length,
                    itemBuilder: ((context, index) {
                      File file = widget.fileList.files!.toList()[index];

                      if (searchVal == null) {
                        return (file.mimeType!.contains(".folder")
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
                              ));
                      } else {
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
                          return const SizedBox.shrink();
                        }
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
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
    print(fileName);
    print(fileId);
    print(fileMimeType);

    http.Response? response;

    if (fileMimeType.contains("spreadsheet") && !fileName.contains(".xlsx")) {
      //For google doc files ONLY
      String url =
          "https://www.googleapis.com/drive/v3/files/${file.id}/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&key=${widget.GOOGLEDRIVEAPIKEY} HTTP/1.1";

      response = await authenticateClient.get(
        Uri.parse(url),
      );
    } else if (!fileMimeType.contains(".folder")) {
      //FOR NORMAL FILES
      String url =
          "https://www.googleapis.com/drive/v3/files/$fileId?includeLabels=alt%3Dmedia&alt=media&key=${widget.GOOGLEDRIVEAPIKEY} HTTP/1.1";

      response = await authenticateClient.get(
        Uri.parse(url),
      );
    }

    if (response != null) {
      print(response.body);
      print(response.bodyBytes);

      final dir = await getApplicationDocumentsDirectory();
      String path = "${dir.path}/${file.name}";
      io.File myFile = await io.File(path).writeAsBytes(response.bodyBytes);

      print(myFile.path);

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
