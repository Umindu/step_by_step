import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/Home.dart';

class AddExperiment extends StatefulWidget {
  const AddExperiment({Key? key}) : super(key: key);

  @override
  State<AddExperiment> createState() => _AddExperimentState();
}

class _AddExperimentState extends State<AddExperiment> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  SQLdb sqLdb = SQLdb();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Experiment"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: _title,
              style: const TextStyle(fontSize: 18, color: Colors.purple),
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
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _description,
              style: const TextStyle(fontSize: 18, color: Colors.purple),
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
            ElevatedButton(
                onPressed: () async {
                  if (_title.text.isNotEmpty == true) {
                    int rep = await sqLdb.insertData(
                        "INSERT INTO 'experiment' (title, description, date) VALUES (\"${_title.text}\",\"${_description.text}\",\"${DateTime.now().toString()}\")");
                    if (rep > 0) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const Home()),
                          (route) => false);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Title is empty"),
                    ));
                  }
                },
                child: const SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Add Experiment",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ))
                    ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
