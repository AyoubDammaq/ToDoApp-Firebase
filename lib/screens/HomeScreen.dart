import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todoappfirebase/auth/authscreen.dart';
import 'package:todoappfirebase/screens/EditTaskScreen.dart';
import 'package:todoappfirebase/screens/add_task.dart';
import 'package:todoappfirebase/screens/description.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String uid;
  late ScaffoldMessengerState scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('To Do List App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(),
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          scaffoldMessenger = ScaffoldMessenger.of(context);
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(uid)
                    .collection('mytasks')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                    return Column(
                      children: [
                        for (var index = 0; index < docs.length; index++)
                          _buildTaskItem(docs[index]),
                      ],
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTask()),
            );
          } catch (e) {
            print('Error navigating to AddTask: $e');
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTaskItem(DocumentSnapshot doc) {
    var time = (doc['timestamp'] as Timestamp).toDate();
    final title = doc['title'];
    final description = doc['description'];
    final priority = doc['priority'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Description(
              title: title,
              description: description,
              priority: priority,
              timestamp: time,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.lightBlue[50],
        margin: const EdgeInsets.only(bottom: 10),

        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    title ?? 'Missing Title',
                    style: GoogleFonts.roboto(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    DateFormat.yMd().add_jm().format(time),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Priority: $priority',
                  ),
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(
                        taskId: doc.id,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(uid)
                      .collection('mytasks')
                      .doc(doc.id)
                      .delete();
                },
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
