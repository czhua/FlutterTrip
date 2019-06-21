import 'package:flutter/material.dart';

class TravelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TravelPageState();
  }
}

class _TravelPageState extends State<TravelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('旅拍'),
      ),
    );
  }
}
