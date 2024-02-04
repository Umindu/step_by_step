import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:path_provider/path_provider.dart' as syspath;

class ShowStepDetails extends StatefulWidget {
  final int id;
  const ShowStepDetails({super.key, required this.id});

  @override
  State<ShowStepDetails> createState() => _ShowStepDetailsState();
}

class _ShowStepDetailsState extends State<ShowStepDetails> {
  File? _image;

  SQLdb sqLdb = SQLdb();

  Future<void> getStep() async {
    List<Map> step = await sqLdb.getData("SELECT * FROM 'step' WHERE id = ${widget.id}");

    List<Map> imge = await sqLdb.getData("SELECT * FROM 'image' WHERE id_step = ${widget.id}");
    print(imge);

  
    //load base64 to _image
    if (imge.isNotEmpty) {
      // Uint8List bytes = base64Decode(imge[0]['image']);
      final tempDir = await syspath.getApplicationDocumentsDirectory();
      final file = await File('${tempDir.path}/${imge[0]['image']}').create();
      print(file);
      // await file.writeAsBytes(bytes);
      setState(() {
        _image = file;
      });
    }

    

  }

  @override
  void initState() {
    super.initState();
    getStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step Details"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                  '${widget.id}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Step Title",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Step Description",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              _image != null
                  ? Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Text("No Image"),
            ],
          ),
        ),
      ),
    );
  }
}