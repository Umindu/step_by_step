import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/Home.dart';

class UpdateExperiment extends StatefulWidget {
  final id;
  final title;
  final description;
  const UpdateExperiment({Key? key, this.id, this.title, this.description}) : super(key: key);

  @override
  State<UpdateExperiment> createState() => _UpdateExperimentState();
}

class _UpdateExperimentState extends State<UpdateExperiment> {
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  SQLdb sqLdb = SQLdb();
@override
  void initState() {
  _title.text = widget.title;
  _description.text = widget.description.toString();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Experiment"),),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            TextField(
              controller: _title,
              style:  const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: "Title",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _description,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Description",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: ()async{
              int rep = await sqLdb.updateData('''
              UPDATE "experiment" SET
              title = "${_title.text}",
              description = "${_description.text}"
              WHERE id = ${widget.id}
              ''');
              if(rep>0){
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context)=>const Home()),
                        (route) => false);
              }
            }, child: const SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.update,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Update Experiment",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    )))

          ],
        ),
      )

    );
  }
}
