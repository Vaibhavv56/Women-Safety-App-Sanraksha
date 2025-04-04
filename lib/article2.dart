import 'package:flutter/material.dart';
import 'contacts.dart';
import 'trackme.dart';
import 'explore.dart';

class ArticlePage2 extends StatelessWidget {
  const ArticlePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/asset2.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Top 5 Self-Defense Tips for Women',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Being prepared and aware is the first step to ensuring personal safety. Here are five essential self-defense tips every woman should know:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. **Stay Aware of Your Surroundings:** Always remain alert and mindful of your environment, especially in unfamiliar or isolated areas. Trust your instincts if something feels off.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. **Learn Basic Self-Defense Moves:** Enroll in a self-defense class to learn techniques like striking vulnerable areas (eyes, nose, groin) and escaping holds effectively.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. **Carry Safety Tools:** Keep items like pepper spray, a whistle, or a personal alarm handy. Ensure you know how to use them in high-pressure situations.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. **Maintain a Confident Posture:** Walk confidently with your head held high. Attackers often target individuals who appear distracted or timid.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '5. **Have an Emergency Plan:** Share your location with trusted contacts and know the quickest escape routes in your surroundings. Use safety apps to alert contacts if needed.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'By practicing these tips and staying prepared, you can enhance your personal safety and navigate your daily life with greater confidence and peace of mind.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Track Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
        currentIndex: 2, // Current index for the "Explore" page
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrackMePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExplorePage()),
              );
              break;
          }
        },
      ),
    );
  }
}
