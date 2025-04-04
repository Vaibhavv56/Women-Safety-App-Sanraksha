import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SirenScreen extends StatefulWidget {
  const SirenScreen({Key? key}) : super(key: key);

  @override
  _SirenScreenState createState() => _SirenScreenState();
}

class _SirenScreenState extends State<SirenScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSirenPlaying = false;

  @override
  void initState() {
    super.initState();
    _startSiren();
  }

  Future<void> _startSiren() async {
    try {
      // Set audio to loop continuously
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Play the siren sound from assets
      await _audioPlayer.play(AssetSource('audio/siren.mp3'));
      
      setState(() {
        _isSirenPlaying = true;
      });
    } catch (e) {
      print('Error starting siren: $e');
      _showErrorSnackBar();
    }
  }

  Future<void> _stopSiren() async {
    await _audioPlayer.stop();
    setState(() {
      _isSirenPlaying = false;
    });
    // Optionally, navigate back or to another screen
    Navigator.of(context).pop();
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to play siren. Please check audio file.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Always stop and dispose of the audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text('Emergency Siren', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'EMERGENCY ALERT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Siren is Active',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: _stopSiren,
              child: Text(
                'Stop Siren',
                style: TextStyle(
                  color: Colors.red[900],
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}