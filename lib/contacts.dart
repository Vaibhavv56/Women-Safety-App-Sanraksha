import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sanrakshan25/explore.dart';
import 'package:sanrakshan25/trackme.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Check if the user is authenticated first
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // If not authenticated, we should handle this case
      setState(() {
        isLoading = false;
        errorMessage = 'You need to be logged in to view contacts.';
      });
      print('Debug: User not authenticated');
    } else {
      print('Debug: User authenticated with ID: ${currentUser.uid}');
      fetchContacts();
    }
  }

  Future<void> fetchContacts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final userId = _auth.currentUser?.uid;
      print('Debug: Fetching contacts for user: $userId');
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('contacts')
            .get();

        print('Debug: Found ${snapshot.docs.length} contacts');
        
        final fetchedContacts = snapshot.docs
            .map((doc) {
              print('Debug: Contact data: ${doc.data()}');
              return {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'Unknown',
                'phoneNumber': doc.data()['phoneNumber'] ?? 'No Number',
              };
            })
            .toList();

        setState(() {
          contacts = fetchedContacts;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'User not authenticated';
        });
      }
    } catch (e) {
      print('Error fetching contacts: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load contacts: $e';
      });
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String dialogError = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Add Emergency Contact'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dialogError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        dialogError,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      hintText: '+91XXXXXXXXXX',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      
                      // Indian phone number validation
                      RegExp indianPhoneRegex = RegExp(r'^\+91[1-9]\d{9}$');
                      if (!indianPhoneRegex.hasMatch(value)) {
                        return 'Enter a valid Indian phone number (+91XXXXXXXXXX)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B5998),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userId = _auth.currentUser?.uid;
                    if (userId == null) {
                      setDialogState(() {
                        dialogError = 'User not authenticated';
                      });
                      print('Debug: User not authenticated when adding contact');
                      return;
                    }
                    
                    try {
                      print('Debug: Adding contact for user: $userId');
                      print('Debug: Name: ${nameController.text.trim()}, Phone: ${phoneController.text.trim()}');
                      
                      // First, make sure the user document exists
                      await _firestore.collection('users').doc(userId).set({
                        'lastUpdated': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                      
                      // Then add the contact
                      DocumentReference docRef = await _firestore
                          .collection('users')
                          .doc(userId)
                          .collection('contacts')
                          .add({
                        'name': nameController.text.trim(),
                        'phoneNumber': phoneController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      
                      print('Debug: Contact added with ID: ${docRef.id}');
                      
                      Navigator.pop(context);
                      fetchContacts(); // Refresh the list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Contact added successfully')),
                      );
                    } catch (e) {
                      print('Error adding contact: $e');
                      setDialogState(() {
                        dialogError = 'Failed to add contact: $e';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add contact: $e')),
                      );
                    }
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _deleteContact(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      print('Debug: Deleting contact with ID: $id for user: $userId');
      
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('contacts')
            .doc(id)
            .delete();
        
        print('Debug: Contact deleted successfully');
        fetchContacts(); // Refresh the list
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact deleted')),
        );
      }
    } catch (e) {
      print('Error deleting contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete contact: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Contact',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Add refresh button for debugging
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchContacts,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchContacts,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : contacts.isEmpty
                  ? Center(
                      child: Text(
                        'No emergency contacts added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF3B5998),
                              child: Text(
                                contact['name'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(contact['name']),
                            subtitle: Text(contact['phoneNumber']),
                            trailing: IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Delete'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _deleteContact(contact['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF3B5998),
        child: Icon(Icons.add),
        onPressed: _showAddContactDialog,
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
            Container(
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