import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/AddStep.dart';

class ShowExperimentDetails extends StatefulWidget {
  final id;
  final title;
  final description;
  const ShowExperimentDetails(
      {super.key, this.id, this.title, this.description});

  @override
  State<ShowExperimentDetails> createState() => _ShowExperimentDetailsState();
}

class _ShowExperimentDetailsState extends State<ShowExperimentDetails> {
  SQLdb sqLdb = SQLdb();
  //---------------------------------
  Future<List<Map>> getAllFilms() async {
    List<Map> step = await sqLdb
        .getData("SELECT * FROM 'step' WHERE id_exp = '${widget.id}");
    return step;
  }
  //---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: FutureBuilder(
          future: getAllFilms(),
          builder: (ctx, snp) {
            if (snp.hasData) {
              List<Map> listStep = snp.data!;
              return ListView.builder(
                  itemCount: listStep.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.movie,
                          color: Colors.pink,
                          size: 30,
                        ),
                        title: Text(
                          "${listStep[index]['title']}",
                          style:
                              const TextStyle(fontSize: 25, color: Colors.pink),
                        ),
                        subtitle: Text(
                          "${listStep[index]['description']}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.purple),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () {},
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                  size: 25,
                                )),
                            TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(
                                                "Are you sure delete? ${listStep[index]['title']}"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    int rep =
                                                        await sqLdb.deleteData(
                                                            "DELETE FROM 'step' WHERE id = ${listStep[index]['id']}");
                                                    if (rep > 0) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: const Text("Ok")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                            ],
                                          ));
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 25,
                                ))
                          ],
                        ),
                        onTap: () {},
                      ),
                    );
                  });
            } else if (snp.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text("empty"),
              );
            }
          },
        )),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const AddStep()));
          },
          label: const Text('Add Step'),
          icon: const Icon(Icons.add),
        ));
  }

 
}
