



//trail04
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'siren.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class SOSTimerScreen extends StatefulWidget {
  const SOSTimerScreen({Key? key}) : super(key: key);

  @override
  State<SOSTimerScreen> createState() => _SOSTimerScreenState();
}

class _SOSTimerScreenState extends State<SOSTimerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Twilio instance
  late TwilioFlutter twilioFlutter;

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _countdown = 5;
  late Timer _timer;
  bool _isTimerRunning = true;
  bool _isSendingSMS = false;
  bool _isSirenPlaying = false;
  String _userAddress = 'Loading your location...';
  List<Map<String, dynamic>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _initTwilio();
    _fetchUserAddress();
    _fetchEmergencyContacts();
    _startTimer();
    _requestLocationPermission();
  }

  void _initTwilio() {
    // Initialize Twilio with your credentials
    // Store these securely, ideally in Firebase Remote Config or similar
     twilioFlutter = TwilioFlutter(
    accountSid: dotenv.env['TWILIO_ACCOUNT_SID'] ?? "",
    authToken: dotenv.env['TWILIO_AUTH_TOKEN'] ?? "",
    twilioNumber: dotenv.env['TWILIO_NUMBER'] ?? "",
  );
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
      _showSnackBar('Failed to play siren. Please check audio file.');
    }
  }

  Future<void> _stopSiren() async {
    await _audioPlayer.stop();
    setState(() {
      _isSirenPlaying = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
    }
  }

  Future<void> _fetchUserAddress() async {
    // For this example, we're using the hardcoded address from your UI
    // In a real app, you'd fetch this from a location service or Firebase
    setState(() {
      _userAddress = 'R. Navji Nagar, 5 Bunglows, Andheri (west), Mumbai';
    });
  }

  Future<void> _fetchEmergencyContacts() async {
    setState(() {
      _emergencyContacts = [];
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('contacts')
            .get();

        final fetchedContacts = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.data()['name'] ?? 'Unknown',
                  'phoneNumber': doc.data()['phoneNumber'] ?? '',
                })
            .where((contact) => 
                contact['phoneNumber'] != null && 
                contact['phoneNumber'].toString().isNotEmpty)
            .toList();

        setState(() {
          _emergencyContacts = fetchedContacts;
        });
        
        print('Fetched ${_emergencyContacts.length} emergency contacts');
      }
    } catch (e) {
      print('Error fetching emergency contacts: $e');
      _showSnackBar('Could not fetch emergency contacts');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer.cancel();
          _isTimerRunning = false;
          _startSiren(); // Start siren when countdown reaches zero
          _sendSOSMessages(); // Send SOS messages
        }
      });
    });
  }

  Future<String> _getLocationURL() async {
    try {
      Position? currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return 'https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}';
    } catch (e) {
      print('Location fetch error: $e');
      return '';
    }
  }

  Future<void> _sendSOSMessages() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('User not authenticated. Please log in.');
      return;
    }

    // Fetch contacts again to ensure latest data
    await _fetchEmergencyContacts();

    if (_emergencyContacts.isEmpty) {
      _showSnackBar('No emergency contacts found. Please add contacts in your profile.');
      return;
    }

    setState(() {
      _isSendingSMS = true;
    });

    try {
      // Get location URL
      String locationUrl = await _getLocationURL();

      // Craft detailed SOS message
      String message = '''
EMERGENCY SOS! I need immediate help!
User: ${currentUser.displayName ?? 'Unknown'}
Location: ${locationUrl.isNotEmpty ? locationUrl : _userAddress}
Timestamp: ${DateTime.now()}
''';

      // Send SMS to each contact
      for (var contact in _emergencyContacts) {
        String phoneNumber = contact['phoneNumber'];
        
        // Ensure proper phone number formatting
        if (!phoneNumber.startsWith('+')) {
          phoneNumber = '+91$phoneNumber'; // Assumes Indian phone numbers
        }
        

        try {
          await twilioFlutter.sendSMS(
            toNumber: phoneNumber,
            messageBody: message,
          );
          print('SMS sent successfully to $phoneNumber');
        } catch (e) {
          print('Failed to send SMS to $phoneNumber: $e');
          _showSnackBar('Could not send SMS to all contacts. Check phone numbers.');
        }
      }

      _showSnackBar('Emergency alerts sent to ${_emergencyContacts.length} contacts!');
    } catch (e) {
      print('Comprehensive SOS sending error: $e');
      _showSnackBar('Emergency alert system failed. Please check your network and try again.');
    } finally {
      setState(() {
        _isSendingSMS = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancelTimer() {
    _timer.cancel();
    Navigator.of(context).pop(); // Return to previous screen
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The entire existing build method remains unchanged
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Menu functionality
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              _stopSiren();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Text(
              'Press the button below help will reach you soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          
          // SOS Timer
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB0C4DE).withOpacity(0.5),
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6A85B6).withOpacity(0.7),
                      ),
                    ),
                    // Inner button with countdown
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3B5998),
                      ),
                      child: Center(
                        child: _isTimerRunning 
                          ? Text(
                              '$_countdown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : _isSendingSMS
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 40,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          // Siren Status Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _isSirenPlaying ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  _isSirenPlaying ? 'Siren Active' : 'Siren Inactive',
                  style: TextStyle(
                    color: _isSirenPlaying ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          
          // Address card
          
          
          // Status or action button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _isTimerRunning
              ? GestureDetector(
                 onTap: () {
                    _stopSiren(); // Stop siren when cancelling
                    _cancelTimer();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap to Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : _isSendingSMS
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B5998)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sending emergency alerts...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      _stopSiren();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Return to Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}



//trail05
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// // import 'package:another_telephony/another_telephony.dart';
// import 'package:audioplayers/audioplayers.dart';

// class SOSTimerScreen extends StatefulWidget {
//   const SOSTimerScreen({Key? key}) : super(key: key);

//   @override
//   State<SOSTimerScreen> createState() => _SOSTimerScreenState();
// }

// class _SOSTimerScreenState extends State<SOSTimerScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   // Twilio instance
//   late TwilioFlutter twilioFlutter;

//   final AudioPlayer _audioPlayer = AudioPlayer();
  
//   int _countdown = 5;
//   late Timer _timer;
//   bool _isTimerRunning = true;
//   bool _isSendingSMS = false;
//   bool _isSirenPlaying = false;
//   String _userAddress = 'Loading your location...';
//   List<Map<String, dynamic>> _emergencyContacts = [];

//   @override
//   void initState() {
//     super.initState();
//     _initTwilio();
//     _fetchUserAddress();
//     _fetchEmergencyContacts();
//     _startTimer();
//     _requestLocationPermission();
//   }

//   void _initTwilio() {
//     // Initialize Twilio with your credentials
//     // Store these securely, ideally in Firebase Remote Config or similar
//     twilioFlutter = TwilioFlutter(
//       accountSid: 'ACb378ff4ab39e261304634af1f5d2c2b8', // Replace with your Twilio Account SID
//       authToken: '48235f9354f3b628d3997df18e490aee',    // Replace with your Twilio Auth Token
//       twilioNumber: '12202156453' // Replace with your Twilio phone number
//     );
//   }

//   Future<void> _startSiren() async {
//     try {
//       // Set audio to loop continuously
//       await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
//       // Play the siren sound from assets
//       await _audioPlayer.play(AssetSource('audio/siren.mp3'));
      
//       setState(() {
//         _isSirenPlaying = true;
//       });
//     } catch (e) {
//       print('Error starting siren: $e');
//       _showSnackBar('Failed to play siren. Please check audio file.');
//     }
//   }

//   Future<void> _stopSiren() async {
//     await _audioPlayer.stop();
//     setState(() {
//       _isSirenPlaying = false;
//     });
//   }

//   Future<void> _requestLocationPermission() async {
//     var locationStatus = await Permission.location.status;
//     if (!locationStatus.isGranted) {
//       locationStatus = await Permission.location.request();
//     }
//   }

//   Future<void> _fetchUserAddress() async {
//     // For this example, we're using the hardcoded address from your UI
//     // In a real app, you'd fetch this from a location service or Firebase
//     setState(() {
//       _userAddress = 'R. Navji Nagar, 5 Bunglows, Andheri (west), Mumbai';
//     });
//   }

//   Future<void> _fetchEmergencyContacts() async {
//     setState(() {
//       _emergencyContacts = [];
//     });

//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         final snapshot = await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('contacts')
//             .get();

//         final fetchedContacts = snapshot.docs
//             .map((doc) => {
//                   'id': doc.id,
//                   'name': doc.data()['name'] ?? 'Unknown',
//                   'phoneNumber': doc.data()['phoneNumber'] ?? '',
//                 })
//             .where((contact) => 
//                 contact['phoneNumber'] != null && 
//                 contact['phoneNumber'].toString().isNotEmpty)
//             .toList();

//         setState(() {
//           _emergencyContacts = fetchedContacts;
//         });
        
//         print('Fetched ${_emergencyContacts.length} emergency contacts');
//       }
//     } catch (e) {
//       print('Error fetching emergency contacts: $e');
//       _showSnackBar('Could not fetch emergency contacts');
//     }
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_countdown > 0) {
//           _countdown--;
//         } else {
//           _timer.cancel();
//           _isTimerRunning = false;
//           _startSiren(); // Start siren when countdown reaches zero
//           _sendSOSMessages(); // Send SOS messages
//         }
//       });
//     });
//   }

//   Future<String> _getLocationURL() async {
//     try {
//       Position? currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       return 'https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}';
//     } catch (e) {
//       print('Location fetch error: $e');
//       return '';
//     }
//   }

//   Future<void> _sendSOSMessages() async {
//     final User? currentUser = _auth.currentUser;
//     if (currentUser == null) {
//       _showSnackBar('User not authenticated. Please log in.');
//       return;
//     }

//     // Fetch contacts again to ensure latest data
//     await _fetchEmergencyContacts();

//     if (_emergencyContacts.isEmpty) {
//       _showSnackBar('No emergency contacts found. Please add contacts in your profile.');
//       return;
//     }

//     setState(() {
//       _isSendingSMS = true;
//     });

//     try {
//       // Get location URL
//       String locationUrl = await _getLocationURL();

//       // Craft detailed SOS message
//       String message = '''
// EMERGENCY SOS! I need immediate help!
// User: ${currentUser.displayName ?? 'Unknown'}
// Location: ${locationUrl.isNotEmpty ? locationUrl : _userAddress}
// Timestamp: ${DateTime.now()}
// ''';

//       // Send SMS to each contact
//       for (var contact in _emergencyContacts) {
//         String phoneNumber = contact['phoneNumber'];
        
//         // Ensure proper phone number formatting
//         if (!phoneNumber.startsWith('+')) {
//           phoneNumber = '+91$phoneNumber'; // Assumes Indian phone numbers
//         }
        

//         try {
//           await twilioFlutter.sendSMS(
//             toNumber: phoneNumber,
//             messageBody: message,
//           );
//           print('SMS sent successfully to $phoneNumber');
//         } catch (e) {
//           print('Failed to send SMS to $phoneNumber: $e');
//           _showSnackBar('Could not send SMS to all contacts. Check phone numbers.');
//         }
//       }

//       _showSnackBar('Emergency alerts sent to ${_emergencyContacts.length} contacts!');
//     } catch (e) {
//       print('Comprehensive SOS sending error: $e');
//       _showSnackBar('Emergency alert system failed. Please check your network and try again.');
//     } finally {
//       setState(() {
//         _isSendingSMS = false;
//       });
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _cancelTimer() {
//     _timer.cancel();
//     Navigator.of(context).pop(); // Return to previous screen
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _audioPlayer.stop();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // The entire existing build method remains unchanged
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.black),
//           onPressed: () {
//             // Menu functionality
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.home, color: Colors.black),
//             onPressed: () {
//               _stopSiren();
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
//             child: Text(
//               'Press the button below help will reach you soon',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
          
//           // SOS Timer
//           Expanded(
//             child: Center(
//               child: Container(
//                 width: 180,
//                 height: 180,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Outer circle
//                     Container(
//                       width: 180,
//                       height: 180,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: const Color(0xFFB0C4DE).withOpacity(0.5),
//                       ),
//                     ),
//                     // Middle circle
//                     Container(
//                       width: 140,
//                       height: 140,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: const Color(0xFF6A85B6).withOpacity(0.7),
//                       ),
//                     ),
//                     // Inner button with countdown
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Color(0xFF3B5998),
//                       ),
//                       child: Center(
//                         child: _isTimerRunning 
//                           ? Text(
//                               '$_countdown',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : _isSendingSMS
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : const Icon(
//                                   Icons.check,
//                                   color: Colors.white,
//                                   size: 40,
//                                 ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),


//           // Siren Status Indicator
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.warning_amber_rounded,
//                   color: _isSirenPlaying ? Colors.red : Colors.grey,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   _isSirenPlaying ? 'Siren Active' : 'Siren Inactive',
//                   style: TextStyle(
//                     color: _isSirenPlaying ? Colors.red : Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
          
//           // Address card
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 25,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: const AssetImage('assets/images/profile_pic.png'),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Your Current Address',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _userAddress,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
          
//           // Status or action button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: _isTimerRunning
//               ? GestureDetector(
//                  onTap: () {
//                     _stopSiren(); // Stop siren when cancelling
//                     _cancelTimer();
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'Tap to Cancel',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 )
//               : _isSendingSMS
//                 ? Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 3,
//                             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B5998)),
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Text(
//                           'Sending emergency alerts...',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : GestureDetector(
//                     onTap: () {
//                       _stopSiren();
//                       Navigator.of(context).pop();
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.green[400],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         'Return to Home',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }