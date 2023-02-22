// ignore: file_names
import 'package:flutter/material.dart';
import '../../models/commentsModel.dart';

class Comments extends StatelessWidget {
  const Comments({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Destination Routes',
      home: const Comments(title: 'Traffic Destination Routes'),
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        useMaterial3: true,
      ),
    );
  }
}

// Create a Form widget.
class MyComments extends StatefulWidget {
  const MyComments({super.key});

  @override
  MyCommentsState createState() {
    return MyCommentsState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCommentsState extends State<MyComments> {
  @override
  Widget build(BuildContext context) {
    CommentsModel myComments =  CommentsModel();
    // TODO: implement buildcx
    final _formKey = GlobalKey<FormState>();
    const appTitle = 'Comments';

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  child: const Text('Save'),
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

void createComment() {}

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyFrequentsState>.

    
