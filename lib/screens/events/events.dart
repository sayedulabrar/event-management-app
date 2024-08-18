import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive_flutter/model/event.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  Set<int> _expandedEvents = {};
  bool _isLoading = true;
  String _searchQuery = '';

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter =
        DateFormat('MMMM d, yyyy hh:mm a'); // Adjust format as needed
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _loadFirestoreEvents();
  }

  Future<void> _loadFirestoreEvents() async {
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();

    final events = snap.docs.map((doc) => doc.data()).toList();

    setState(() {
      _events = events;
      _filteredEvents = events;
      _isLoading = false;
    });
  }

  void _filterEvents(String query) {
    final filteredEvents = _events.where((event) {
      final titleLower = event.title.toLowerCase();
      final descriptionLower = event.description?.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) ||
          descriptionLower!.contains(searchLower);
    }).toList();
    filteredEvents.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _filteredEvents = filteredEvents;
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    _filteredEvents.sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Events')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterEvents,
              decoration: const InputDecoration(
                hintText: 'Search events...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? const Center(child: Text('No events found'))
                    : ListView.builder(
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = _filteredEvents[index];
                          final now = DateTime.now();
                          final isUpcoming = event.date.isAfter(now) ||
                              event.date.isAtSameMomentAs(now);
                          final isExpanded = _expandedEvents.contains(index);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.green[700],
                                      child: const Icon(
                                        Icons.event,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    title: Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatDateTime(event.date),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isUpcoming
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedEvents.remove(index);
                                        } else {
                                          _expandedEvents.add(index);
                                        }
                                      });
                                    },
                                  ),
                                  if (isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(event.description ?? ''),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
