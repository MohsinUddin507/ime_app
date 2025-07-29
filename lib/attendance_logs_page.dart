import 'dart:io';

import 'package:flutter/material.dart';
import 'database_helper.dart';

class AttendanceRecordsPage extends StatefulWidget {
  const AttendanceRecordsPage({super.key});

  @override
  _AttendanceRecordsPageState createState() => _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState extends State<AttendanceRecordsPage> {
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = DatabaseHelper.instance.getAttendanceRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Records')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data!;

          if (records.isEmpty) {
            return const Center(child: Text('No attendance records found'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    record['type'] == 'check_in' ? Icons.login : Icons.logout,
                    color: record['type'] == 'check_in' ? Colors.green : Colors.red,
                  ),
                  title: Text(record['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${record['employee_id']}'),
                      Text('Time: ${record['timestamp']}'),
                      Text('Type: ${record['type']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () {
                      // Show the captured image
                      if (record['image_path'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerPage(imagePath: record['image_path']),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final String imagePath;

  const ImageViewerPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Photo')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}