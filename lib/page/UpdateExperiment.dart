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
  TextEditingController _titre = TextEditingController();
  TextEditingController _duree = TextEditingController();
  SQLdb sqLdb = SQLdb();
@override
  void initState() {
  _titre.text = widget.title;
  _duree.text = widget.description.toString();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Film"),),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            TextField(
              controller: _titre,
              style:  const TextStyle(fontSize: 20,color: Colors.purple),
              decoration:  const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
              ),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _duree,
              style: const TextStyle(fontSize: 20,color: Colors.purple),
              decoration: const InputDecoration(
                labelText: "Durée",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: ()async{
              int rep = await sqLdb.updateData('''
              UPDATE "films" SET
              titre = "${_titre.text}",
              duree = ${int.parse(_duree.text)}
              WHERE id = "${widget.id}"
              ''');
              if(rep>0){
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context)=>const Home()),
                        (route) => false);
              }
            }, child: const Text("Modifier"))

          ],
        ),
      )

    );
  }
}
