import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive_flutter/model/event.dart';
import 'package:rive_flutter/widget/button_widget.dart';

class EditEvent extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final Event event;

  const EditEvent({
    Key? key,
    required this.firstDate,
    required this.lastDate,
    required this.event,
  }) : super(key: key);

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedLevel ;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeEvent();
  }

  void _initializeEvent() {
    _selectedLevel=widget.event.level;
    _titleController.text = widget.event.title;
    _descController.text = widget.event.description!;
    _selectedDate = widget.event.date;
    _selectedTime =
        TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute);
    _dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
    _timeController.text = _selectedTime.format(context);
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      onTap: _editEvent,
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

  Future<void> _editEvent() async {
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

    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .update({
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(selectedDateTime),
      "level": _selectedLevel
    });

    if (mounted) {
      Navigator.pop<bool>(context, true);
    }
  }
}
