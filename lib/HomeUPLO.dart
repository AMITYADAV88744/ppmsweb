import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class HomeUPLO extends StatefulWidget {
  const HomeUPLO({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeUPLO> {
  //PickedFile? pickedFile;

  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: Image.network(
                    'https://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
              ),
              const SizedBox(
                height: 16,
              ),
              const Center(
                child: Text('Flutter on Back4app - Save File',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SavePage()),
                    );
                  },
                  child: const Text('Upload File'),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayPage()),
                      );
                    },
                    child: const Text('Display File'),
                  ))
            ],
          ),
        ));
  }
}

class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  PickedFile? pickedFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Fie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              child: pickedFile != null
                  ? Container(
                  width: 250,
                  height: 250,
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.blue)),
                  child: kIsWeb
                      ? Image.network(pickedFile!.path)
                      : Image.file(File(pickedFile!.path)))
                  : Container(
                width: 250,
                height: 250,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.blue)),
                child: const Center(
                  child: Text('Click here to pick image from Gallery'),
                ),
              ),
              onTap: () async {
                PickedFile? image =
                await ImagePicker().getImage(source: ImageSource.gallery);

                if (image != null) {
                  setState(() {
                    pickedFile = image;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: isLoading || pickedFile == null
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });
                    ParseFileBase? parseFile;

                    if (kIsWeb) {
                      //Flutter Web
                      parseFile = ParseWebFile(
                          await pickedFile!.readAsBytes(),
                          name: 'image.txt'); //Name for file is required
                    } else {
                      //Flutter Mobile/Desktop
                      parseFile = ParseFile(File(pickedFile!.path));
                    }
                    await parseFile.save();

                    final gallery = ParseObject('Gallery')
                      ..set('file', parseFile);
                    await gallery.save();

                    setState(() {
                      isLoading = false;
                      pickedFile = null;
                    });

                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(
                          'Save file with success on Back4app',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                  },
                  child: const Text('Upload file'),
                ))
          ],
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display Gallery"),
      ),
      body: FutureBuilder<List<ParseObject>>(
          future: getGalleryList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: const CircularProgressIndicator()),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error..."),
                  );
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        //Web/Mobile/Desktop
                        ParseFileBase? varFile =
                        snapshot.data![index].get<ParseFileBase>('file');

                        //Only iOS/Android/Desktop
                        /*
                        ParseFile? varFile =
                            snapshot.data![index].get<ParseFile>('file');
                        */
                        return Image.network(
                          varFile!.url!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.fitHeight,
                        );
                      });
                }
            }
          }),
    );
  }

  Future<List<ParseObject>> getGalleryList() async {
    QueryBuilder<ParseObject> queryPublisher =
    QueryBuilder<ParseObject>(ParseObject('Gallery'))
      ..orderByAscending('createdAt');
    final ParseResponse apiResponse = await queryPublisher.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}