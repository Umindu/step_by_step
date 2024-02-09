import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/AddExperiment.dart';
import 'package:step_by_step/page/ShowExperimentDetails.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SQLdb sqLdb = SQLdb();

  //---------------------------------
  Future<List<Map>> getExperiment() async {
    List<Map> experiment = await sqLdb
        .getData("SELECT * FROM 'experiment' WHERE status = 'active'");
    return experiment;
  }

  Future<void> exportDB() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage]!.isGranted) {
      if (await sqLdb.exportDB()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Export successfully!, Check in Download folder!")));

      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Export failed!")));
      }
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission denied!")));}
  }

  Future<void> importDB() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    if (statuses[Permission.storage]!.isGranted) {
      // pick file
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null) {
        File file = File(result.files.single.path!);

        if (await sqLdb.importDB(file)) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Import successfully!")));

          // app restart
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Home()),
              (route) => false);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Import failed!")));
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Permission denied!")));
    }
  }

  Future<void> backupDB() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Are you sure you want to backup?",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      if (await sqLdb.backupDB()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Backup successfully!")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Backup failed!")));
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
              ],
            ));
  }

  Future<void> restoreDB() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Are you sure you want to restore?",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      if (await sqLdb.restoreDB()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Restore successfully!")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Restore failed!")));
                      }

                      //app restart
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const Home()),
                          (route) => false);
                    },
                    child: const Text("Ok")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
              ],
            ));
  }

  //---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddExperiment(
                    id: null,
                  )));
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 240,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              leading: const Icon(Icons.upload),
                              title: const Text("Export"),
                              onTap: () {
                                Navigator.of(context).pop();
                                exportDB();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.download),
                              title: const Text("Import"),
                              onTap: () async {
                                Navigator.of(context).pop();
                                importDB();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.backup),
                              title: const Text("Backup"),
                              onTap: () async {
                                Navigator.of(context).pop();
                                backupDB();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.restore),
                              title: const Text("Restore"),
                              onTap: () async {
                                Navigator.of(context).pop();
                                restoreDB();
                              },
                            ),
                          ],
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: FutureBuilder(
          future: getExperiment(),
          builder: (ctx, snp) {
            if (snp.hasData) {
              List<Map> listExperiment = snp.data!.reversed.toList();
              return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: listExperiment.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.lightbulb,
                        ),
                        title: Text(
                          "${listExperiment[index]['title']}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          "${listExperiment[index]['description']}",
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
                                                          AddExperiment(
                                                              id: listExperiment[
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
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: Text(
                                                              "Are you sure you want to delete? ${listExperiment[index]['title']}",
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            ),
                                                            actions: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    int rep = await sqLdb
                                                                        .updateData(
                                                                            "UPDATE 'experiment' SET status = 'deleted' WHERE id = ${listExperiment[index]['id']}");
                                                                    await sqLdb
                                                                        .updateData(
                                                                            "UPDATE 'step' SET status = 'deleted' WHERE id_exp = ${listExperiment[index]['id']}");
                                                                    await sqLdb
                                                                        .updateData(
                                                                            "UPDATE 'image' SET status = 'deleted' WHERE id_exp = ${listExperiment[index]['id']}");
                                                                    //delete folder
                                                                    // Directory dir = Directory("/storage/emulated/0/StepbyStep/Images/${listExperiment[index]['id']}");
                                                                    // dir.deleteSync( recursive: true);
                                                                    if (rep >
                                                                        0) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              const SnackBar(content: Text("Delete successfully!")));

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();

                                                                      setState(
                                                                          () {});
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              const SnackBar(content: Text("Delete failed!")));
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
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
                              builder: (context) => ShowExperimentDetails(
                                  id: listExperiment[index]['id'],
                                  title: listExperiment[index]['title'])));
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
    );
  }
}
