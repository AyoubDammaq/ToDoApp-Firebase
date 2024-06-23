import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedPriority;

  List<String> priorities = ['High', 'Medium', 'Low'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('Edit Task'),
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
                  style: TextStyle(fontSize: 16),
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
                  style: TextStyle(fontSize: 16),
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
                        _updateTask();
                      }
                    },
                    child: const Text('Update Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void _updateTask() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(user.uid)
            .collection('mytasks')
            .doc(widget.taskId)
            .update({
          'title': titleController.text,
          'description': descriptionController.text,
          'priority': selectedPriority,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  void _fetchTaskDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .doc(user.uid)
            .collection('mytasks')
            .doc(widget.taskId)
            .get();

        final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          titleController.text = data['title'];
          descriptionController.text = data['description'];
          selectedPriority = data['priority'];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch task details: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
