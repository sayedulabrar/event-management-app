import 'package:flutter/material.dart';

import '../model/event.dart';

class EventItem extends StatelessWidget {
  final Event event;
  final Function() onDelete;
  final Function()? onTap;
  final String? role;

  const EventItem({
    Key? key,
    required this.event,
    required this.onDelete,
    this.onTap,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        tileColor: role == "user" ? Colors.blue[50] : Colors.green[50],
        leading: CircleAvatar(
          backgroundColor: role == "user" ? Colors.blue : Colors.green,
          child: Icon(
            Icons.event,
            color: Colors.white,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          event.formattedDate!,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        onTap: role == "user" ? () {} : onTap,
        trailing: role == "user"
            ? null
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
