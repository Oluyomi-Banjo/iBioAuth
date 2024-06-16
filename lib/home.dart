import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth_screen.dart'; // Import the authentication screen file

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Timer _timer;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _setState(false); // Set state to false upon initialization
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        _setState(true); // Set state to true after 1 minute
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  void _lockDevice() {
    _timer.cancel();
    _setState(true); // Set state to true when the lock button is pressed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _setState(bool state) {
    _databaseReference.child('state').set(state);
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Successful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device Unlocked'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lockDevice,
              child: const Text('Lock'),
            ),
          ],
        ),
      ),
    );
  }
}
