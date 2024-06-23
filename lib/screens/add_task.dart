import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTask extends StatefulWidget {
  const AddTask({Key? key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedPriority;

  List<String> priorities = ['High', 'Medium', 'Low'];

  void addTaskToFirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DateTime time = DateTime.now();
      String documentId = time.toString();
      FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('mytasks')
          .doc(documentId)
          .set({
        'title': titleController.text,
        'description': descriptionController.text,
        'time': time.toString(),
        'timestamp': time,
        'priority': selectedPriority,
      }).then((_) {
        Fluttertoast.showToast(msg: 'Task Added');
      }).catchError((error) {
        print('Error adding task: $error');
      });
      Navigator.pop(context);
    } else {
      // Handle the case where user is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('New Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Task Title *',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Task Description *',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Task Priority *',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select priority of task';
                    }
                    return null;
                  },
                  items: priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Priority',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addTaskToFirebase();
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}