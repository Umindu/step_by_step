import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/ShowExperimentDetails.dart';
import 'package:image_cropper/image_cropper.dart';

class AddStep extends StatefulWidget {
  final id_exp;
  final title;

  const AddStep({super.key, this.id_exp, this.title});

  @override
  State<AddStep> createState() => _AddStepState();
}

class _AddStepState extends State<AddStep> {
  XFile? _imageFile;
  String? base64String;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _date =
      DateFormat('EEE, MMM dd yyyy    hh:mm a').format(DateTime.now());
  SQLdb sqLdb = SQLdb();

  DateFormat dateFormat = DateFormat('EEE, MMM dd yyyy');
  DateFormat timeFormat = DateFormat('hh:mm a');

  Future<XFile?> CropImage(
      {required CropAspectRatio cropAspectRatio,
      required ImageSource imageSource}) async {
    XFile? pickImage = await ImagePicker().pickImage(source: imageSource);
    if (pickImage == null) null;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickImage!.path,
      aspectRatio: cropAspectRatio,
      compressQuality: 100,
      compressFormat: ImageCompressFormat.jpg,
    );
    if (croppedFile == null) return null;

    return XFile(croppedFile.path);
  }

  void getImageGallery() async {
    CropImage(
            cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
            imageSource: ImageSource.gallery)
        .then((value) => setState(() async {
              _imageFile = value;
              List<int> imageBytes =
                  await File(_imageFile!.path).readAsBytesSync();
              setState(() {
                base64String = base64Encode(imageBytes);
                print(base64String);
              });
            }));
  }

  // void getImageGallery() async {
  //   final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _imageFile = image;
  //     });
  //   }
  //   List<int> imageBytes = await File(_imageFile!.path).readAsBytesSync();
  //   setState(() {
  //     base64String = base64Encode(imageBytes);
  //   });
  // }

  void getImageCamera() async {
    CropImage(
            cropAspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
            imageSource: ImageSource.camera)
        .then((value) => setState(() async {
              _imageFile = value;
              List<int> imageBytes =
                  await File(_imageFile!.path).readAsBytesSync();
              setState(() {
                base64String = base64Encode(imageBytes);
                print(base64String);
              });
            }));
  }

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

              TimeOfDay? pickedTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());

              if (pickedDate != null || pickedTime != null) {
                setState(() {
                  _date =
                      "${dateFormat.format(pickedDate!)}    ${pickedTime!.format(context)}";
                });
              }
            },
            icon: const Icon(Icons.date_range_outlined),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
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
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                Permission.camera,
                                Permission.storage,
                              ].request();

                              if (statuses[Permission.camera]!.isGranted &&
                                  statuses[Permission.storage]!.isGranted) {
                                Navigator.pop(context);
                                getImageCamera();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Permission denied, please enable permission")));
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_outlined),
                            title: const Text("Gallery"),
                            onTap: () async {
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                Permission.camera,
                                Permission.storage,
                              ].request();

                              if (statuses[Permission.camera]!.isGranted &&
                                  statuses[Permission.storage]!.isGranted) {
                                Navigator.pop(context);
                                getImageGallery();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Permission denied, please enable permission")));
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
            onPressed: () async {
              if (_title.text.isNotEmpty == true) {
                int rep = await sqLdb.insertData(
                    "INSERT INTO 'step' (id_exp, title, description, date) VALUES (${widget.id_exp},\"${_title.text}\",\"${_description.text}\",\"${DateTime.now().toString()}\")");

                List<Map> listStep =
                    await sqLdb.getData("SELECT * FROM 'step'");
                int idStep = listStep.last['id'];

                if (base64String != null) {
                  print(base64String);
                  await sqLdb.insertData(
                      "INSERT INTO 'image' (id_step, image) VALUES (${idStep},\"$base64String\")");
                }
                if (rep > 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => ShowExperimentDetails(
                                id: widget.id_exp,
                                title: widget.title,
                              )),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              Container(
                height: null,
                width: MediaQuery.of(context).size.width,
                child: _imageFile != null
                    ? Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text("No Image"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
