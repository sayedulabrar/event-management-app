import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Timer? _timer;
  List<QueryDocumentSnapshot> todaysEvents = [];
  Map<String, String> eventRemainingTimes = {};

  @override
  void initState() {
    super.initState();
    _fetchTodaysEvents();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTodaysEvents() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    setState(() {
      todaysEvents = snapshot.docs;
    });

    _updateRemainingTimes();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTimes();
    });
  }

  void _updateRemainingTimes() {
    DateTime now = DateTime.now();
    Map<String, String> newRemainingTimes = {};

    for (var event in todaysEvents) {
      DateTime eventDate = (event['date'] as Timestamp).toDate();
      Duration difference = eventDate.difference(now);

      if (difference.isNegative) {
        newRemainingTimes[event.id] = 'Started';
      } else {
        newRemainingTimes[event.id] = _formatDuration(difference);
      }
    }

    setState(() {
      eventRemainingTimes = newRemainingTimes;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: const Text("Reminders")),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: todaysEvents.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            'No Events Today',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: todaysEvents.length,
                        itemBuilder: (context, index) {
                          var event = todaysEvents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.event,
                                  color: Colors.blueAccent,
                                  size: 40.0,
                                ),
                                title: Text(
                                  event['title'] ?? 'No title',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.0),
                                    Text(
                                      (event['date'] as Timestamp)
                                          .toDate()
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Remaining: ${eventRemainingTimes[event.id] ?? 'Calculating...'}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ));
  }
}
