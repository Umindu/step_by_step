import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/Home.dart';
import 'package:step_by_step/page/ShowExperimentDetails.dart';

class AddStep extends StatefulWidget {
  final id_exp;
  final title;
  const AddStep({super.key, this.id_exp, this.title});

  @override
  State<AddStep> createState() => _AddStepState();
}

class _AddStepState extends State<AddStep> {
  File? _image;
  File? selectedIMage;
  
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _date =
      DateFormat('EEE, MMM dd yyyy    hh:mm a').format(DateTime.now());
  SQLdb sqLdb = SQLdb();

  DateFormat dateFormat = DateFormat('EEE, MMM dd yyyy');
  DateFormat timeFormat = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Step"),
        actions: [
          IconButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now());
                  
              TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              
              if (pickedDate != null || pickedTime != null) {
                setState(() {
                  _date = "${dateFormat.format(pickedDate!)}    ${pickedTime!.format(context)}";
                });
              }
            },
            icon: const Icon(Icons.date_range_outlined),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(context: context, builder: (context){
                return Container(
                  height: 130,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt_outlined),
                        title: const Text("Camera"),
                        onTap: () async {
                          File? selectedImage = await pickImage();
                          if (selectedImage != null) {
                            await copyImageToAssetsDirectory(selectedImage);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_outlined),
                        title: const Text("Gallery"),
                        onTap: () async {
                          File? selectedImage = await pickImage();
                          if (selectedImage != null) {
                            await copyImageToAssetsDirectory(selectedImage);
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
            },
            icon: const Icon(Icons.add_a_photo_outlined),
          ),
          TextButton(
            onPressed: () async{
              if (_title.text.isNotEmpty == true) {
                    int rep = await sqLdb.insertData(
                        "INSERT INTO 'step' (id_exp, title, description, date) VALUES (${widget.id_exp},\"${_title.text}\",\"${_description.text}\",\"${DateTime.now().toString()}\")");
                    if (rep > 0) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => ShowExperimentDetails(id: widget.id_exp, title: widget.title,)),
                          (route) => false);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Title is empty"),
                    ));
                  }
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _date,
              ),
              TextField(
                controller: _title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your title",
                ),
              ),
              TextField(
                controller: _description,
                minLines: 1,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your discription",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Image.asset(selectedIMage == null ? "assets/images/temp.jpg" : "assets/images/temp.jpg", fit: BoxFit.contain, width: MediaQuery.of(context).size.width)
            ],
          ),
        ),
      ),
    );
  }

  Future<File?> pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    print(pickedFile.path + "++++++++++++++++++++++++++++");
    return File(pickedFile.path);
  }

  return null;
}

Future<void> copyImageToAssetsDirectory(File selectedImage) async {
  try {
    // Get the app's documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Define the source and destination paths
    String sourcePath = selectedImage.path;
    String destinationDirectory =
        '${documentsDirectory.path}/assets/images/';

    // Create the destination directory if it doesn't exist
    Directory(destinationDirectory).createSync(recursive: true);

    // Specify the destination path including the file name
    String destinationPath =
        '$destinationDirectory${selectedImage.uri.pathSegments.last}';

    // Copy the file
    await File(sourcePath).copy(destinationPath);

    // Refresh the app to reflect changes
  } catch (e) {
    print('Error copying image: $e');
  }
}




   //pick image gallery
  Future pickImageGallery() async {
    // final returnImage =
    //     await ImagePicker().pickImage(source: ImageSource.gallery);
            
        
    // if (returnImage == null) return;
    // setState(() {
    //   selectedIMage = File(returnImage.path);
    // });
    // print(selectedIMage);
    // Navigator.pop(context);

    //image select and copy to app directory
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the app directory
      Directory appDirectory = await getApplicationDocumentsDirectory();

      // Create an "images" directory within the app directory
      Directory imagesDirectory = Directory('${appDirectory.path}/assets/images');
      if (!imagesDirectory.existsSync()) {
        imagesDirectory.createSync(recursive: true);
      }
    print(imagesDirectory);
      // Create a new file in the "images" directory
      File newImage = File('${imagesDirectory.path}/IMG_20240202_004734.jpg');

      // Copy the picked image to the "images" directory
      await newImage.writeAsBytes(await pickedFile.readAsBytes());

      setState(() {
        selectedIMage = newImage;
      });
    }
  }

  //pick image camera
  Future pickImageCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
    });
    Navigator.pop(context);
  }
}
