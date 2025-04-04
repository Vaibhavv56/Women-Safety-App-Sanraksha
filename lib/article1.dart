import 'package:flutter/material.dart';
import 'contacts.dart';
import 'trackme.dart';
import 'explore.dart';

class ArticlePage1 extends StatelessWidget {
  const ArticlePage1({super.key});

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
                  'assets/asset1.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Global Safety Trends for Women',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'In recent years, the global landscape has witnessed significant advancements in addressing women\'s safety. Governments, organizations, and communities are implementing innovative strategies to tackle the challenges women face, ensuring safer environments and equal opportunities. Here are some key trends shaping the future of women\'s safety worldwide:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '- Governments are introducing stricter laws and policies to protect women from violence and harassment, both in public and private spaces.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Technological innovations, such as mobile apps and wearable devices, are empowering women to quickly seek help and stay connected in times of need.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Educational programs are being implemented to promote gender equality and challenge harmful stereotypes that perpetuate violence against women.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Urban planning and public transportation systems are being redesigned to include features such as better lighting, surveillance cameras, and women-only spaces.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'These advancements are fostering a sense of security and confidence among women, enabling them to participate more actively in all aspects of life.',
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


