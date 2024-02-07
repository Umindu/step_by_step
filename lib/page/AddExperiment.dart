import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/Home.dart';

class AddExperiment extends StatefulWidget {
  final id;
  const AddExperiment({Key? key, this.id}) : super(key: key);

  @override
  State<AddExperiment> createState() => _AddExperimentState();
}

class _AddExperimentState extends State<AddExperiment> {
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  SQLdb sqLdb = SQLdb();

  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      sqLdb
          .getData("SELECT * FROM experiment WHERE id = ${widget.id}")
          .then((value) {
        _title.text = value[0]["title"];
        _description.text = value[0]["description"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.id == null
            ? const Text("Add Experiment")
            : const Text("Edit Experiment"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: _title,
              style: const TextStyle(fontSize: 18),
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
              style: const TextStyle(fontSize: 18),
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
                    if (widget.id == null) {
                      int rep = await sqLdb.insertData(
                          "INSERT INTO 'experiment' (title, description, date, status) VALUES (\"${_title.text}\",\"${_description.text}\",\"${DateTime.now().toString()}\",'active')");
                      if (rep > 0) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                            (route) => false);
                      }
                    } else {
                      int rep = await sqLdb.updateData(
                          "UPDATE 'experiment' SET title = \"${_title.text}\", description = \"${_description.text}\" WHERE id = ${widget.id}");
                      if (rep > 0) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                            (route) => false);
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Title is empty"),
                    ));
                  }
                },
                child: widget.id == null ? const SizedBox(
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
                    )):
                    const SizedBox(
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
