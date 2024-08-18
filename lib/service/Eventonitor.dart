import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rive_flutter/service/local_notification.dart';

class EventMonitor {
  StreamSubscription<QuerySnapshot>? _subscription;
  Set<String> notifiedEvents = {};

  void startMonitoring() {
    print("EventMonitor: Starting monitoring");
    _subscription = FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          print("EventMonitor: New event detected");
          _handleNewEvent(change.doc);
        }
      }
    }, onError: (error) {
      print("EventMonitor: Error in Firestore listener: $error");
    });
  }

  void stopMonitoring() {
    print("EventMonitor: Stopping monitoring");
    _subscription?.cancel();
  }

  Future<void> _handleNewEvent(DocumentSnapshot event) async {
    print("EventMonitor: Handling new event ${event.id}");
    if (notifiedEvents.contains(event.id)) return;

    DateTime eventTime = (event['date'] as Timestamp).toDate();
    DateTime now = DateTime.now();
    DateTime tenMinutesBeforeEvent = eventTime.subtract(Duration(minutes: 10));

    if (now.isBefore(tenMinutesBeforeEvent)) {
      await scheduleLocalNotification(event);
      notifiedEvents.add(event.id);
    }
  }

  Future<void> scheduleLocalNotification(DocumentSnapshot event) async {
    print("EventMonitor: Scheduling notification for event ${event.id}");
    DateTime eventTime = (event['date'] as Timestamp).toDate();
    DateTime notificationTime = eventTime.subtract(Duration(minutes: 10));

    await GetIt.I<NotificationService>().scheduleNotification(
      event.id.hashCode,
      event['title'],
      "10 minutes remaining",
      notificationTime,
    );
    print("EventMonitor: Notification scheduled for ${notificationTime}");
    }
}