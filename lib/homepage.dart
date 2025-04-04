import 'package:flutter/material.dart';
import 'package:sanrakshan25/explore.dart';
import 'contacts.dart';
import 'sos.dart';
import 'trackme.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: Padding(
    padding: const EdgeInsets.all(8.0), // Add some spacing
    child: Image.asset(
      'assets/images/logo.png', // Update with correct path
      width: 40, // Adjust size if needed
      height: 40,
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.home, color: const Color.fromARGB(255, 0, 46, 124)),
      onPressed: () {
        // Already on home page
      },
    ),
  ],
),

      body: Column(
        children: [
          // Emergency text section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Are you in emergency?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Press the button below help will reach you soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // SOS Button
          Expanded(
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFB0C4DE).withOpacity(0.5),
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6A85B6).withOpacity(0.7),
                      ),
                    ),
                    // Inner button
                    InkWell(
  onTap: () {
    // Navigate to SOS Timer Screen
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => SOSTimerScreen())
    );
  },
  child: Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFF3B5998),
    ),
    child: Center(
      child: Text(
        'SOS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ),
          ),
          
          // Address card
          
          
          // Bottom navigation
          // Bottom navigation
 Container(
            height: 80,
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => TrackMePage())
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF3B5998)),
                      Text('Track Me', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ContactsPage())
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF3B5998),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ExplorePage())
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, color: Color(0xFF3B5998)),
                      Text('Explore', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
