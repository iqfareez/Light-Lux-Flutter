import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'equivalent.dart';

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  String _luxString = 'Unknown';
  String _equivalentText = 'Unknown';
  Light _light;
  double _opacity;
  StreamSubscription _subscription;

  void onData(int luxValue) async {
    setState(() {
      _luxString = "$luxValue";
      _opacity = newValueFromRange(
          luxValue.clamp(0, 800).toDouble(), 0, 800, 0.1, 1.0);
      _equivalentText = EquivalentLuxValue.getEquivalent(luxValue);
    });
  }

  void stopListening() => _subscription.cancel();

  void startListening() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _opacity = 0.0;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async => startListening();

  double newValueFromRange(
          num value, num oldMin, num oldMax, num newMin, num newMax) =>
      (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 800),
          child: Container(
            color: Colors.orange,
          ),
        ),
        Center(
          child: AutoSizeText(
            _luxString,
            maxLines: 1,
            style: TextStyle(
              fontSize: 173,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          width: MediaQuery.of(context).size.width,
          bottom: MediaQuery.of(context).orientation == Orientation.landscape
              ? 50
              : 110,
          child: Text(
            _equivalentText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
