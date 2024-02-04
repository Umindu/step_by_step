import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:image/image.dart' as img;
import 'package:step_by_step/page/ShowExperimentDetails.dart';
import 'package:step_by_step/page/Utility.dart';

class AddStep extends StatefulWidget {
  final id_exp;
  final title;

  const AddStep({super.key, this.id_exp, this.title});

  @override
  State<AddStep> createState() => _AddStepState();
}

class _AddStepState extends State<AddStep> {
  File? _image;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _date =
      DateFormat('EEE, MMM dd yyyy    hh:mm a').format(DateTime.now());
  SQLdb sqLdb = SQLdb();

  DateFormat dateFormat = DateFormat('EEE, MMM dd yyyy');
  DateFormat timeFormat = DateFormat('hh:mm a');

  void getImageGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void getImageCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
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
                              getImageCamera();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_outlined),
                            title: const Text("Gallery"),
                            onTap: () async {
                              getImageGallery();
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

                // get step table last id
                List<Map> listStep =
                    await sqLdb.getData("SELECT * FROM 'step'");
                int id_step = listStep.last['id'];

                if (_image != null) {
                  // save image
                  final appDir = await syspath.getApplicationDocumentsDirectory();
                  final fileName = path.basename(_image!.path);
                  final savedImage = await _image!.copy('${appDir.path}/$fileName');
                  print(savedImage.path);

                  // save image to db
                  Uint8List bytes = await savedImage.readAsBytes();

                  String base64Image = base64Encode(bytes);
                  print(base64Image);

                  await sqLdb.insertData(
                      "INSERT INTO 'image' (id_step, image) VALUES ($id_step,\"$fileName\")");
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
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _image != null
                    ? Image.file(
                        _image!,
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