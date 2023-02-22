// ignore: file_names
import 'package:flutter/material.dart';
import '../../models/commentsModel.dart';

class InsertComments extends StatelessWidget {
  const InsertComments({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Destination Routes',
      home: const InsertComments(title: 'Traffic Destination Routes'),
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        useMaterial3: true,
      ),
    );
  }
}

// Create a Form widget.
class MyInsertComments extends StatefulWidget {
  const MyInsertComments({super.key});

  @override
  MyInsertCommentsState createState() {
    return MyInsertCommentsState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyInsertCommentsState extends State<MyInsertComments> {
  @override
  Widget build(BuildContext context) {
    CommentsModel myComments = CommentsModel();
    // TODO: implement buildcx
    final _formKey = GlobalKey<FormState>();
    const appTitle = 'InsertComments';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),

        // Build a Form widget using the _formKey created above.
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (name) {
                  if (name == null || name.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              FormBuilderTextField(
                name: "description",
                decoration: const InputDecoration(
                  label: Text("Please describe your experience..."),
                  icon: Icon(Icons.edit),
                ),
                validator: (name) {
                  if (name == null || name.isEmpty) {
                    decoration: const InputDecoration(
                      label: Text("Please describe your experience...",
                      style: TextStyle(color: Colors.amber),
                      ),
                      fillColor: Colors.red,
                      icon: Icon(Icons.edit),
                    );
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  child: const Text('Insert comment'),
                  onPressed: () {
                    myComments.tableCreate();
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // throw UnimplementedError();
}
