import 'package:flutter/material.dart';
import 'contacts.dart';
import 'trackme.dart';
import 'explore.dart';

class ArticlePage5 extends StatelessWidget {
  const ArticlePage5({super.key});

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
                  'assets/asset4.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Empowering Women Through Education',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Education is a powerful tool that not only transforms individual lives but also strengthens entire communities. By empowering women through education, we can pave the way for a more equitable and prosperous future. Here’s how education plays a critical role in women’s empowerment:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. **Breaking the Cycle of Poverty:** Educated women are more likely to secure better jobs, contribute economically, and lift their families out of poverty.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. **Promoting Gender Equality:** Education challenges traditional gender norms and fosters a sense of equality and mutual respect between men and women.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. **Improving Health and Well-Being:** Educated women make informed decisions about health, family planning, and child-rearing, leading to healthier families and communities.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. **Encouraging Leadership:** Education opens doors for women to step into leadership roles, inspiring change and driving progress across all sectors.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                '5. **Creating Safer Environments:** Knowledge equips women with the confidence to advocate for their rights and take a stand against violence, discrimination, and inequality.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'By ensuring access to quality education for all women, we can unlock their potential and create a world where opportunities are limitless and barriers are broken.',
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
