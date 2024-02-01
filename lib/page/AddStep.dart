import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddStep extends StatefulWidget {
  const AddStep({super.key});

  @override
  State<AddStep> createState() => _AddStepState();
}

class _AddStepState extends State<AddStep> {
  Uint8List? _image;
  File? selectedIMage;
  
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _date =
      DateFormat('EEE, MMM dd yyyy    hh:mm a').format(DateTime.now());

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
                        onTap: (){
                          pickImageCamera();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_outlined),
                        title: const Text("Gallery"),
                        onTap: (){
                          pickImageGallery();
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
            onPressed: () {},
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
              Image.asset(selectedIMage == null ? "images/temp.jpg" : selectedIMage.toString(), fit: BoxFit.contain, width: MediaQuery.of(context).size.width)
            ],
          ),
        ),
      ),
    );
  }

   //pick image gallery
  Future pickImageGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
        
        
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      selectedIMage?.copy("imges/IMG_20240202_004734.jpg");
    });
    print(selectedIMage);
    Navigator.pop(context);
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
