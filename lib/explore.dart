import 'package:flutter/material.dart';
import 'package:sanrakshan25/homepage.dart';

import 'article1.dart';
import 'article2.dart';
import 'article3.dart';
import 'article4.dart';
import 'article5.dart';
import 'contacts.dart';
import 'sos.dart';
import 'trackme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, String>> articles = [
    {
      'title': 'Global Safety Trends for Women',
      'description': 'Explore how countries are improving safety for women through policies, education, and technological innovation.',
      'image': 'assets/asset1.png',
      'page': 'ArticlePage1', // Add reference to the corresponding page
    },
    {
      'title': 'Top 5 Self-Defense Tips for Women',
      'description': 'Learn practical self-defense techniques to stay safe in everyday situations.',
      'image': 'assets/asset2.jpg',
      'page': 'ArticlePage2', // Add reference to the corresponding page
    },
    {
      'title': 'Technology for Women’s Safety',
      'description': 'Discover how apps and wearables are enhancing safety for women globally.',
      'image': 'assets/asset3.jpg',
      'page': 'ArticlePage3', // Add reference to the corresponding page
    },
    {
      'title': 'Creating Safer Cities for Women',
      'description': 'Understand urban planning strategies that prioritize women’s safety.',
      'image': 'assets/asset4.jpg',
      'page': 'ArticlePage4', // Add reference to the corresponding page
    },
    {
      'title': 'Empowering Women Through Education',
      'description': 'How education and awareness campaigns are reducing safety risks for women.',
      'image': 'assets/asset5.jpg',
      'page': 'ArticlePage5', // Add reference to the corresponding page
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredArticles = articles
        .where((article) => article['title']!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search article',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          article['image']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () {
                          // Navigate to specific ArticlePage based on the article
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                switch (article['page']) {
                                  case 'ArticlePage1':
                                    return const ArticlePage1();
                                  case 'ArticlePage2':
                                    return const ArticlePage2();
                                  case 'ArticlePage3':
                                    return const ArticlePage3();
                                  case 'ArticlePage4':
                                    return const ArticlePage4();
                                  case 'ArticlePage5':
                                    return const ArticlePage5();
                                  default:
                                    return Container(); // Fallback case
                                }
                              },
                            ),
                          );
                        },
                        child: Text(
                          article['title']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline), // Optional styling
                        ),
                      ),
                      subtitle: Text(article['description']!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    bottomNavigationBar: Container(
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
      MaterialPageRoute(builder: (context) => ContactsPage()),
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
            child :Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, color: Color(0xFF3B5998)),
                Text('Explore', style: TextStyle(fontSize: 12)),
              ],
            ),
          )
          ],
        ),
      ),
    );
  }
}

// Define Separate ArticlePages for each article

