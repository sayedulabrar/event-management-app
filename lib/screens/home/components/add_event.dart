import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive_flutter/service/push_notification.dart';
import 'package:rive_flutter/widget/button_widget.dart';

class AddEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final PushNotificationService ntservice;

  const AddEvent(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      this.selectedDate,
      required this.ntservice})
      : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedLevel = 'Unit level';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timeController.text = _selectedTime.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today)),
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                    labelText: 'Event Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time)),
                readOnly: true,
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Event Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: <String>['Div level', 'Bde level', 'Unit level']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLevel = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: "Save",
                onTap: _addEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = _selectedTime.format(context);
      });
    }
  }

  Future<void> sendNotificationToAllUsers() async {
    List<String> tokens = await widget.ntservice.getAllTokens();
    DateTime eventTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    String eventTimeIsoString = eventTime.toIso8601String();

    for (String token in tokens) {
      widget.ntservice
          .sendNotification(token, _titleController.text, eventTimeIsoString);
    }
  }

  Future<void> _addEvent() async {
    final title = _titleController.text;
    final description = _descController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final DateTime selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await FirebaseFirestore.instance.collection('events').add({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(selectedDateTime),
      "level": _selectedLevel, // Add this line to include the selected level
    });

    await sendNotificationToAllUsers();

    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }
}
