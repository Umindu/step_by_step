import 'package:flutter/material.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/AddEditStep.dart';
import 'package:step_by_step/page/Home.dart';
import 'package:step_by_step/page/ShowStepDetails.dart';

class ShowExperimentDetails extends StatefulWidget {
  final id;
  final title;
  const ShowExperimentDetails({super.key, this.id, this.title});

  @override
  State<ShowExperimentDetails> createState() => _ShowExperimentDetailsState();
}

class _ShowExperimentDetailsState extends State<ShowExperimentDetails> {
  SQLdb sqLdb = SQLdb();
  //---------------------------------
  Future<List<Map>> getAllSteps() async {
    List<Map> step = await sqLdb.getData(
        "SELECT * FROM 'step' WHERE id_exp = ${widget.id} AND status = 'active'");
    return step;
  }

  int _listSize = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: FutureBuilder(
            future: getAllSteps(),
            builder: (ctx, snp) {
              if (snp.hasData) {
                List<Map> listStep = snp.data!.reversed.toList();
                _listSize = listStep.length;

                return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: listStep.length,
                    itemBuilder: (ctx, index) {
                      return Card(
                        child: ListTile(
                          leading:
                              // circal backgroung text
                              CircleAvatar(
                            radius: 20,
                            child: Text(
                              "${_listSize - index}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            "${listStep[index]['title']}",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "${listStep[index]['description']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                //show menu
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: 180,
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.edit,
                                              ),
                                              title: const Text("Edit"),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddEditStep(
                                                                id_exp:
                                                                    widget.id,
                                                                title: widget
                                                                    .title,
                                                                id_step: listStep[
                                                                        index]
                                                                    ['id'])));
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.delete,
                                              ),
                                              title: const Text("Delete"),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                  "Are you sure delete? ${listStep[index]['title']}"),
                                                              actions: [
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      try {
                                                                        int rep =
                                                                            await sqLdb.updateData("UPDATE 'step' SET status = 'deleted' WHERE id = ${listStep[index]['id']}");
                                                                        int rep2 =
                                                                            await sqLdb.updateData("UPDATE 'image' SET status = 'deleted' WHERE id_step = ${listStep[index]['id']}");

                                                                        print(
                                                                            "rep: $rep, rep2: $rep2");
                                                                        if (rep >
                                                                            0) {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(const SnackBar(
                                                                            content:
                                                                                Text("Delete successfully!"),
                                                                          ));
                                                                        } else {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(const SnackBar(
                                                                            content:
                                                                                Text("Delete failed!"),
                                                                          ));
                                                                        }
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        setState(
                                                                            () {});
                                                                      } catch (e) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(const SnackBar(
                                                                          content:
                                                                              Text("Delete failed!"),
                                                                        ));
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                        "Ok")),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        "Cancel")),
                                                              ],
                                                            ));
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.info,
                                              ),
                                              title: const Text("Details"),
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return Container();
                                                    });
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                size: 25,
                              )),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ShowStepDetails(
                                      id: listStep[index]['id'],
                                    )));
                          },
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
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddEditStep(
                    id_exp: widget.id, title: widget.title, id_step: null)));
          },
          label: const Text('Add Step'),
          icon: const Icon(Icons.add),
        ));
  }
}
