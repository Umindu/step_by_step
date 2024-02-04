import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_by_step/db/SQLDB.dart';
import 'package:step_by_step/page/Utility.dart';

class ShowStepDetails extends StatefulWidget {
  final int id;
  const ShowStepDetails({super.key, required this.id});

  @override
  State<ShowStepDetails> createState() => _ShowStepDetailsState();
}

class _ShowStepDetailsState extends State<ShowStepDetails> {
  String? base64String;
  String? date;
  String? title;
  String? description;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  SQLdb sqLdb = SQLdb();

  Future<void> getStep() async {
    List<Map> step =
        await sqLdb.getData("SELECT * FROM 'step' WHERE id = ${widget.id}");

    setState(() {
      date = step[0]['date'];
      title = step[0]['title'];
      description = step[0]['description'];
      _title.value = TextEditingValue(text: title!);
      _description.value = TextEditingValue(text: description!);
    });

    List<Map> imge = await sqLdb
        .getData("SELECT * FROM 'image' WHERE id_step = ${widget.id}");
    print(imge);
    if (imge[0]['image'] != null) {
      setState(() {
        base64String = imge[0]['image'];
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
        title: Text(title ?? ""),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                //date format
                date == null
                    ? ""
                    : DateFormat('EEE, MMM dd yyyy    hh:mm a')
                        .format(DateTime.parse(date!)),
              ),
              TextField(
                readOnly: true,
                controller: _title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              TextField(
                readOnly: true,
                controller: _description,
                minLines: 1,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: null,
                width: MediaQuery.of(context).size.width,
                child: base64String != null
                    ? Image.memory(
                        Utility.dataFromBase64String(base64String!),
                        fit: BoxFit.cover,
                      )
                    : Text("No Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
