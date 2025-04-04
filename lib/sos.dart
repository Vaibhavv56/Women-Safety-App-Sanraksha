// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_sms/flutter_sms.dart';
// import 'package:permission_handler/permission_handler.dart';

// class SOSTimerScreen extends StatefulWidget {
//   const SOSTimerScreen({Key? key}) : super(key: key);

//   @override
//   State<SOSTimerScreen> createState() => _SOSTimerScreenState();
// }

// class _SOSTimerScreenState extends State<SOSTimerScreen> {
//   int _countdown = 5;
//   late Timer _timer;
//   bool _isTimerRunning = true;
//   bool _isSendingSMS = false;
//   String _userAddress = 'Loading your location...';
//   List<String> _emergencyContacts = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserAddress();
//     _fetchEmergencyContacts();
//     _startTimer();
//     _requestSMSPermission();
//   }

//   Future<void> _requestSMSPermission() async {
//     await Permission.sms.request();
//   }

//   Future<void> _fetchUserAddress() async {
//     // For this example, we're using the hardcoded address from your UI
//     // In a real app, you'd fetch this from a location service or Firebase
//     setState(() {
//       _userAddress = 'R. Navji Nagar, 5 Bunglows, Andheri (west), Mumbai';
//     });
//   }

//   Future<void> _fetchEmergencyContacts() async {
//     try {
//       // Get the current user
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Fetch emergency contacts from Firestore
//         final contactsSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('emergency_contacts')
//             .get();

//         List<String> phoneNumbers = [];
//         for (var doc in contactsSnapshot.docs) {
//           final phoneNumber = doc.data()['phoneNumber'] as String?;
//           if (phoneNumber != null && phoneNumber.isNotEmpty) {
//             phoneNumbers.add(phoneNumber);
//           }
//         }

//         setState(() {
//           _emergencyContacts = phoneNumbers;
//         });

//         print('Fetched ${_emergencyContacts.length} emergency contacts');
//       }
//     } catch (e) {
//       print('Error fetching emergency contacts: $e');
//       // Handle the error appropriately
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
//           // Send SOS SMS after countdown reaches zero
//           _sendSOSMessages();
//         }
//       });
//     });
//   }

//   Future<void> _sendSOSMessages() async {
//     if (_emergencyContacts.isEmpty) {
//       _showSnackBar('No emergency contacts found.');
//       return;
//     }

//     setState(() {
//       _isSendingSMS = true;
//     });

//     try {
//       // Get current location for more accurate help
//       Position? currentPosition;
//       try {
//         await Permission.location.request();
//         currentPosition = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//       } catch (e) {
//         print('Error getting location: $e');
//         // Continue with the saved address if location fetch fails
//       }

//       // Create SOS message
//       String message = 'EMERGENCY SOS! I need help immediately!';
      
//       // Add location information if available
//       if (currentPosition != null) {
//         message += '\nMy current location: https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}';
//       } else {
//         message += '\nMy address: $_userAddress';
//       }

//       // Send SMS to all emergency contacts
//       String result = await sendSMS(
//         message: message,
//         recipients: _emergencyContacts,
//         sendDirect: true,
//       ).catchError((error) {
//         print('Error sending SMS: $error');
//         return 'Error sending SMS';
//       });

//       print('SMS send result: $result');
      
//       // Show success message
//       _showSnackBar('Emergency alert sent to ${_emergencyContacts.length} contacts!');
//     } catch (e) {
//       print('Error in SOS procedure: $e');
//       _showSnackBar('Failed to send emergency alerts. Please try again.');
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
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
          
//           // Cancel button (only visible during countdown)
//           if (_isTimerRunning)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: GestureDetector(
//                 onTap: _cancelTimer,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'Tap to Cancel',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           if (!_isTimerRunning && !_isSendingSMS)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.green[400],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'Return to Home',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }



//Trail 02
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:twilio_flutter/twilio_flutter.dart';

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
  
//   int _countdown = 5;
//   late Timer _timer;
//   bool _isTimerRunning = true;
//   bool _isSendingSMS = false;
//   String _userAddress = 'Loading your location...';
//   List<Map<String, dynamic>> _emergencyContacts = [];

//   @override
//   void initState() {
//     Future<void> _requestMicrophonePermission() async {
//   var status = await Permission.microphone.status;
//   if (!status.isGranted) {
//     status = await Permission.microphone.request();
//   }
// }
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
//       print('Debug: Fetching emergency contacts for user: $userId');
      
//       if (userId != null) {
//         final snapshot = await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('contacts')
//             .get();

//         print('Debug: Found ${snapshot.docs.length} emergency contacts');
        
//         final fetchedContacts = snapshot.docs
//             .map((doc) {
//               print('Debug: Contact data: ${doc.data()}');
//               return {
//                 'id': doc.id,
//                 'name': doc.data()['name'] ?? 'Unknown',
//                 'phoneNumber': doc.data()['phoneNumber'] ?? '',
//               };
//             })
//             .where((contact) => contact['phoneNumber'] != null && contact['phoneNumber'].toString().isNotEmpty)
//             .toList();

//         setState(() {
//           _emergencyContacts = fetchedContacts;
//         });
        
//         print('Debug: Processed ${_emergencyContacts.length} valid emergency contacts');
//       } else {
//         print('Debug: User not authenticated when fetching emergency contacts');
//       }
//     } catch (e) {
//       print('Error fetching emergency contacts: $e');
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
//           // Send SOS SMS after countdown reaches zero
//           _sendSOSMessages();
//         }
//       });
//     });
//   }

//   // New method to fetch the latest location from Firebase
//   Future<Map<String, dynamic>?> _fetchLatestLocationFromFirebase() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         print('Debug: User not authenticated when fetching location');
//         return null;
//       }

//       // First try to get the lastLocation from the user document
//       final userDoc = await _firestore.collection('users').doc(userId).get();
//       if (userDoc.exists && userDoc.data()!.containsKey('lastLocation')) {
//         final lastLocation = userDoc.data()!['lastLocation'];
//         print('Debug: Found lastLocation in user document: $lastLocation');
//         return lastLocation;
//       }

//       // If that doesn't exist, try to get the most recent location from the locations collection
//       final locationsSnapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('locations')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();

//       if (locationsSnapshot.docs.isNotEmpty) {
//         final locationData = locationsSnapshot.docs.first.data();
//         print('Debug: Found most recent location: $locationData');
//         return locationData;
//       }

//       print('Debug: No location data found in Firebase');
//       return null;
//     } catch (e) {
//       print('Error fetching location from Firebase: $e');
//       return null;
//     }
//   }

//   Future<void> _sendSOSMessages() async {
//     if (_emergencyContacts.isEmpty) {
//       _showSnackBar('No emergency contacts found. Please add contacts first.');
//       return;
//     }

//     setState(() {
//       _isSendingSMS = true;
//     });

//     try {
//       // Try to get location from multiple sources in order of preference:
//       // 1. Current device location (most accurate and recent)
//       // 2. Latest location from Firebase (if device location fails)
//       // 3. Fallback to saved address (if both of the above fail)
      
//       Position? currentPosition;
//       Map<String, dynamic>? firebaseLocation;
//       String locationUrl = '';
      
//       // 1. Try to get current device location
//       try {
//         bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (serviceEnabled) {
//           LocationPermission permission = await Geolocator.checkPermission();
//           if (permission == LocationPermission.denied) {
//             permission = await Geolocator.requestPermission();
//           }
          
//           if (permission == LocationPermission.whileInUse || 
//               permission == LocationPermission.always) {
//             currentPosition = await Geolocator.getCurrentPosition(
//               desiredAccuracy: LocationAccuracy.high,
//             );
//             locationUrl = 'https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}';
//             print('Debug: Got current device location: $locationUrl');
//           }
//         }
//       } catch (e) {
//         print('Error getting current device location: $e');
//       }
      
//       // 2. If current location fails, try Firebase location
//       if (currentPosition == null) {
//         firebaseLocation = await _fetchLatestLocationFromFirebase();
//         if (firebaseLocation != null && 
//             firebaseLocation.containsKey('latitude') && 
//             firebaseLocation.containsKey('longitude')) {
//           locationUrl = 'https://maps.google.com/?q=${firebaseLocation['latitude']},${firebaseLocation['longitude']}';
//           print('Debug: Using Firebase location: $locationUrl');
//         }
//       }

//       // Create SOS message
//       String message = 'EMERGENCY SOS! I need help immediately!';
      
//       // Add location information if available
//       if (locationUrl.isNotEmpty) {
//         message += '\nMy current location: $locationUrl';
//       } else {
//         message += '\nMy address: $_userAddress';
//       }

//       // Send SMS to each emergency contact using Twilio
//       bool allMessagesSent = true;
//       for (var contact in _emergencyContacts) {
//         String phoneNumber = contact['phoneNumber'].toString();
        
//         // Format phone number to E.164 format as required by Twilio
//         // This is a simple implementation - you may need to adjust based on your country
//         if (!phoneNumber.startsWith('+')) {
//           // If number doesn't start with +, assume it's an Indian number without country code
//           phoneNumber = '+91$phoneNumber';
//         }
        
//         try {
//           print('Debug: Sending Twilio SMS to: $phoneNumber');
//           await twilioFlutter.sendSMS(
//             toNumber: phoneNumber,
//             messageBody: message,
//           );
//           print('Debug: Successfully sent SMS to $phoneNumber');
//         } catch (e) {
//           print('Error sending SMS to $phoneNumber: $e');
//           allMessagesSent = false;
//         }
//       }
      
//       if (allMessagesSent) {
//         _showSnackBar('Emergency SOS messages sent successfully!');
//       } else {
//         _showSnackBar('Some emergency messages may not have been sent. Please try again.');
//       }
//     } catch (e) {
//       print('Error in SOS procedure: $e');
//       _showSnackBar('Failed to send emergency alerts. Please try again.');
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                   onTap: _cancelTimer,
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


//trail03
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:twilio_flutter/twilio_flutter.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'siren.dart'; 


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
//    bool _isSirenPlaying = false;
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
//     _startSiren();
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

//    Future<void> _startSiren() async {
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

//    Future<void> _stopSiren() async {
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
//       print('Debug: Fetching emergency contacts for user: $userId');
      
//       if (userId != null) {
//         final snapshot = await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('contacts')
//             .get();

//         print('Debug: Found ${snapshot.docs.length} emergency contacts');
        
//         final fetchedContacts = snapshot.docs
//             .map((doc) {
//               print('Debug: Contact data: ${doc.data()}');
//               return {
//                 'id': doc.id,
//                 'name': doc.data()['name'] ?? 'Unknown',
//                 'phoneNumber': doc.data()['phoneNumber'] ?? '',
//               };
//             })
//             .where((contact) => contact['phoneNumber'] != null && contact['phoneNumber'].toString().isNotEmpty)
//             .toList();

//         setState(() {
//           _emergencyContacts = fetchedContacts;
//         });
        
//         print('Debug: Processed ${_emergencyContacts.length} valid emergency contacts');
//       } else {
//         print('Debug: User not authenticated when fetching emergency contacts');
//       }
//     } catch (e) {
//       print('Error fetching emergency contacts: $e');
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
//           _startSiren();
//           // Send SOS SMS after countdown reaches zero
//           _sendSOSMessages();
//         }
//       });
//     });
//   }

//   // New method to fetch the latest location from Firebase
//   Future<Map<String, dynamic>?> _fetchLatestLocationFromFirebase() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         print('Debug: User not authenticated when fetching location');
//         return null;
//       }

//       // First try to get the lastLocation from the user document
//       final userDoc = await _firestore.collection('users').doc(userId).get();
//       if (userDoc.exists && userDoc.data()!.containsKey('lastLocation')) {
//         final lastLocation = userDoc.data()!['lastLocation'];
//         print('Debug: Found lastLocation in user document: $lastLocation');
//         return lastLocation;
//       }

//       // If that doesn't exist, try to get the most recent location from the locations collection
//       final locationsSnapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('locations')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();

//       if (locationsSnapshot.docs.isNotEmpty) {
//         final locationData = locationsSnapshot.docs.first.data();
//         print('Debug: Found most recent location: $locationData');
//         return locationData;
//       }

//       print('Debug: No location data found in Firebase');
//       return null;
//     } catch (e) {
//       print('Error fetching location from Firebase: $e');
//       return null;
//     }
//   }

//   Future<void> _sendSOSMessages() async {
    
//     if (_emergencyContacts.isEmpty) {
//       _showSnackBar('No emergency contacts found. Please add contacts first.');
//       return;
//     }

//     setState(() {
//       _isSendingSMS = true;
//     });

//     try {
//       // Try to get location from multiple sources in order of preference:
//       // 1. Current device location (most accurate and recent)
//       // 2. Latest location from Firebase (if device location fails)
//       // 3. Fallback to saved address (if both of the above fail)
      
//       Position? currentPosition;
//       Map<String, dynamic>? firebaseLocation;
//       String locationUrl = '';
      
//       // 1. Try to get current device location
//       try {
//         bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (serviceEnabled) {
//           LocationPermission permission = await Geolocator.checkPermission();
//           if (permission == LocationPermission.denied) {
//             permission = await Geolocator.requestPermission();
//           }
          
//           if (permission == LocationPermission.whileInUse || 
//               permission == LocationPermission.always) {
//             currentPosition = await Geolocator.getCurrentPosition(
//               desiredAccuracy: LocationAccuracy.high,
//             );
//             locationUrl = 'https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}';
//             print('Debug: Got current device location: $locationUrl');
//           }
//         }
//       } catch (e) {
//         print('Error getting current device location: $e');
//       }
      
//       // 2. If current location fails, try Firebase location
//       if (currentPosition == null) {
//         firebaseLocation = await _fetchLatestLocationFromFirebase();
//         if (firebaseLocation != null && 
//             firebaseLocation.containsKey('latitude') && 
//             firebaseLocation.containsKey('longitude')) {
//           locationUrl = 'https://maps.google.com/?q=${firebaseLocation['latitude']},${firebaseLocation['longitude']}';
//           print('Debug: Using Firebase location: $locationUrl');
//         }
//       }

//       // Create SOS message
//       String message = 'EMERGENCY SOS! I need help immediately!';
      
//       // Add location information if available
//       if (locationUrl.isNotEmpty) {
//         message += '\nMy current location: $locationUrl';
//       } else {
//         message += '\nMy address: $_userAddress';
//       }

//       // Send SMS to each emergency contact using Twilio
//       bool allMessagesSent = true;
//       for (var contact in _emergencyContacts) {
//         String phoneNumber = contact['phoneNumber'].toString();
        
//         // Format phone number to E.164 format as required by Twilio
//         // This is a simple implementation - you may need to adjust based on your country
//         if (!phoneNumber.startsWith('+')) {
//           // If number doesn't start with +, assume it's an Indian number without country code
//           phoneNumber = '+91$phoneNumber';
//         }
        
//         try {
//           print('Debug: Sending Twilio SMS to: $phoneNumber');
//           await twilioFlutter.sendSMS(
//             toNumber: phoneNumber,
//             messageBody: message,
//           );
//           print('Debug: Successfully sent SMS to $phoneNumber');
//         } catch (e) {
//           print('Error sending SMS to $phoneNumber: $e');
//           allMessagesSent = false;
//         }
//       }
      
//       if (allMessagesSent) {
//         _showSnackBar('Emergency SOS messages sent successfully!');
//       } else {
//         _showSnackBar('Some emergency messages may not have been sent. Please try again.');
//       }
//     } catch (e) {
//       print('Error in SOS procedure: $e');
//       _showSnackBar('Failed to send emergency alerts. Please try again.');
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
      accountSid: 'ACb378ff4ab39e261304634af1f5d2c2b8', // Replace with your Twilio Account SID
      authToken: '48235f9354f3b628d3997df18e490aee',    // Replace with your Twilio Auth Token
      twilioNumber: '12202156453' // Replace with your Twilio phone number
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