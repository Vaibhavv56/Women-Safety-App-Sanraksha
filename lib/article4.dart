import 'package:flutter/material.dart';
import 'contacts.dart';
import 'trackme.dart';
import 'explore.dart';

class ArticlePage4 extends StatelessWidget {
  const ArticlePage4({super.key});

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
                  'assets/asset3.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Creating Safer Cities for Women',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'As urban areas expand, it is essential to prioritize women’s safety to foster inclusive and empowering environments. Here are some key approaches being implemented globally to make cities safer for women:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. **Improved Lighting and Surveillance:** Well-lit streets, parks, and public transportation hubs, along with widespread installation of CCTV cameras, deter potential threats and provide a sense of security.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. **Women-Only Zones and Services:** Cities are introducing women-only compartments in public transportation and exclusive waiting areas to ensure comfort and safety during travel.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. **Community Awareness Programs:** Initiatives to educate citizens about women’s rights and the importance of creating respectful spaces help reduce harassment and discrimination.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. **Safety Audits and Reporting Mechanisms:** Engaging local communities to identify unsafe areas and enabling women to report incidents through apps or hotlines ensures targeted action.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '5. **Gender-Inclusive Urban Planning:** Designing cities with accessible infrastructure, wide sidewalks, and safe public spaces encourages active participation by women in all aspects of city life.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'By implementing these measures, cities can evolve into secure, inclusive spaces where women can thrive and lead with confidence.',
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
