import 'package:flutter/material.dart';

class MyRoomName extends StatelessWidget {
  const MyRoomName(this.roomName);
  final String roomName;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        roomName,
        style: TextStyle(
          fontSize: 22,
        ),
      ),
    );
  }
}

class MyRoomStatus extends StatelessWidget {
  const MyRoomStatus(this.currentStatus);
  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        currentStatus,
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MyRoomCheckinButton extends StatelessWidget {
  const MyRoomCheckinButton(this.actionTitle);
  final String actionTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0),
            side: BorderSide(
              width: 2,
              color: Colors.white,
            ),
          ),
          color: Color.fromARGB(50, 0, 0, 0),
          child: Text(
            actionTitle,
            style: TextStyle(
              fontSize: 36,
            ),
          ),
          onPressed: () {
            print('check-in');
          },
        ),
      ),
    );
  }
}
