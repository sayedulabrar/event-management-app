import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String? description;
  final String? formattedDate;
  final DateTime date;
  final String id;
  final String level; // New field for event level

  Event({
    required this.title,
    this.description,
    required this.date,
    required this.id,
    this.formattedDate,
    required this.level, // Add this line
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      date: data['date'].toDate(),
      title: data['title'],
      description: data['description'],
      id: snapshot.id,
      level: data['level'] ?? 'Unit level', // Add this line, with a default value
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "date": Timestamp.fromDate(date),
      "title": title,
      "description": description,
      "level": level, // Add this line
    };
  }
}