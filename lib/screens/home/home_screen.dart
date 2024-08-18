import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive_flutter/model/event.dart';
import 'package:rive_flutter/screens/home/components/add_event.dart';
import 'package:rive_flutter/screens/home/components/edit_event.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/service/push_notification.dart';
import 'package:rive_flutter/widget/event_item.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  final PushNotificationService pushNotificationService;

  HomePage({required this.pushNotificationService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<Event>> _events;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    _authService.fetchUserRole();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadFirestoreEvents();
  }

  _loadFirestoreEvents() async {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1)
        .subtract(const Duration(days: 1));
    _events = {};

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();

    for (var doc in snap.docs) {
      final event = doc.data();
      final formattedDate = formatDateTime(event.date);
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);

      // Initialize the list if it's null
      _events[day] ??= [];

      // Check if the event is already in the list
      bool eventExists = _events[day]!.any((e) => e.id == doc.id);

      // If it doesn't exist, add it
      if (!eventExists) {
        _events[day]!.add(Event(
          title: event.title,
          description: event.description,
          date: event.date,
          id: doc.id,
          formattedDate: formattedDate,
          level: event.level,
        ));
      }
    }
    setState(() {});
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter =
        DateFormat('MMMM d, yyyy hh:mm a'); // Adjust format as needed
    return formatter.format(dateTime);
  }

  List<Event> _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Calendar App')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TableCalendar(
            weekendDays: const [5, 6],
            eventLoader: _getEventsForTheDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            focusedDay: _focusedDay,
            firstDay: _firstDay,
            lastDay: _lastDay,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadFirestoreEvents();
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              weekendTextStyle: TextStyle(
                color: Colors.red,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('MMMM yyyy').format(day),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ..._getEventsForTheDay(_selectedDay).map(
            (event) => AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: 1.0,
              child: EventItem(
                role: _authService.role,
                event: event,
                onTap: () async {
                  final res = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEvent(
                        firstDate: _firstDay,
                        lastDate: _lastDay,
                        event: event,
                      ),
                    ),
                  );
                  if (res ?? false) {
                    _loadFirestoreEvents();
                  }
                },
                onDelete: () async {
                  final delete = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Event?"),
                      content: const Text("Are you sure you want to delete?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('events')
                                .doc(event.id)
                                .delete();
                            _loadFirestoreEvents();
                            Navigator.pop(context, true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                  if (delete ?? false) {
                    _loadFirestoreEvents();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _authService.role == "user"
            ? () {}
            : () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEvent(
                      firstDate: _firstDay,
                      lastDate: _lastDay,
                      selectedDate: _selectedDay,
                      ntservice: widget.pushNotificationService,
                    ),
                  ),
                );
                if (result ?? false) {
                  _loadFirestoreEvents();
                }
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}
