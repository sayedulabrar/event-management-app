import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  final String title;
  final Future<void> Function() onTap;

  const RoundButton({Key? key, required this.title, required this.onTap})
      : super(key: key);

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  bool _loading = false;

  void _handleTap() async {
    setState(() {
      _loading = true;
    });
    await widget.onTap();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: InkWell(
        onTap: _handleTap,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 10, right: 10, top: 20),
          padding: EdgeInsets.only(left: 20, right: 20),
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2196F3), Color(0xff21CBF3)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 50,
                color: Color(0xffEEEEEE),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  )
                : Text(
                    widget.title,
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
