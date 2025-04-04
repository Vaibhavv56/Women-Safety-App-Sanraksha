import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                // Top section with illustration - reduced height
                Container(
                  height: screenHeight * 0.45, // Reduced from 0.6 to avoid overflow
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      // Blue circular decorations at the top
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          height: screenWidth * 0.25, // Slightly smaller
                          width: screenWidth * 0.25,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B5998),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(120),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: screenWidth * 0.25, // Slightly smaller
                          width: screenWidth * 0.25,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B5998),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(120),
                            ),
                          ),
                        ),
                      ),
                      // Blue center shape
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: screenHeight * 0.06, // Smaller height
                            width: screenWidth * 0.25,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94B4E2),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Main illustration
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.03), // Less padding
                          child: Image.asset(
                            'assets/images/intro.jpeg',
                            height: screenHeight * 0.3, // Smaller image
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Text section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Use minimum space needed
                      children: [
                        // Welcome Text
                        Text(
                          'Welcome To Sanraksha',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045, // Slightly smaller
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015), // Less spacing
                        
                        // Description Text - with a maximum number of lines
                        Text(
                          'Women’s safety is about creating a secure environment where women can move freely without fear. It involves proactive measures like self-defense training, emergency response systems, and technology-driven solutions such as safety apps.',
                          textAlign: TextAlign.center,
                          maxLines: 5, // Limit text to prevent overflow
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033, // Smaller font
                            color: Colors.black87,
                            height: 1.3, // Less line height
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Let's Start Button
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: screenHeight * 0.02), // Less bottom margin
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5998),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015, // Less padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Let\'s Start',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}