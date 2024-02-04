import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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
  Future<List<Map>> getAllFilms() async {
    List<Map> experiment = await sqLdb.getData("SELECT * FROM 'experiment'");
    return experiment;
  }

  //---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddExperiment(id: null,)));
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: (){
            showModalBottomSheet(context: context, builder: (context){
              return Container(
                height: 180,
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text("Backup"),
                      onTap: () async {
                        String db_path = await getDatabasesPath();
                        print(db_path);
                        await sqLdb.backupDB();
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.restore),
                      title: const Text("Restore"),
                      onTap: () async {
                        await sqLdb.restoreDB();
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text("Delete Database"),
                      onTap: () async {
                        await sqLdb.deleteDB();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            });
             

          }, icon: const Icon(Icons.more_vert))

        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                flex: 11,
                child: FutureBuilder(
                  future: getAllFilms(),
                  builder: (ctx, snp) {
                    if (snp.hasData) {
                      List<Map> listFilms = snp.data!;
                      return ListView.builder(
                          itemCount: listFilms.length,
                          itemBuilder: (ctx, index) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.lightbulb,
                                ),
                                title: Text(
                                  "${listFilms[index]['title']}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                subtitle: Text(
                                  "${listFilms[index]['description']}",
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
                                                                    id: listFilms[
                                                                            index]
                                                                        ['id']
                                                                  )));
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
                                                              (context) =>
                                                                  AlertDialog(
                                                                    title: Text(
                                                                      "Are you sure you want to delete? ${listFilms[index]['title']}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                    actions: [
                                                                      ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            int rep =
                                                                                await sqLdb.deleteData("DELETE FROM 'experiment' WHERE id = ${listFilms[index]['id']}");
                                                                            if (rep >
                                                                                0) {
                                                                              Navigator.of(context).pop();
                                                                              setState(() {});
                                                                            }
                                                                          },
                                                                          child:
                                                                              const Text("Ok")),
                                                                      ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text("Cancel")),
                                                                    ],
                                                                  ));
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.info,
                                                    ),
                                                    title:
                                                        const Text("Details"),
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
                                      builder: (context) =>
                                          ShowExperimentDetails(
                                              id: listFilms[index]['id'],
                                              title: listFilms[index]
                                                  ['title'])));
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
                )),
            Expanded(flex: 1, child: Container())
          ],
        ),
      ),
    );
  }
}
