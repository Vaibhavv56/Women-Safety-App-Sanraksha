// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:app_settings/app_settings.dart'; // Add this package for opening device settings

// class TrackMePage extends StatefulWidget {
//   const TrackMePage({Key? key}) : super(key: key);

//   @override
//   State<TrackMePage> createState() => _TrackMePageState();
// }

// class _TrackMePageState extends State<TrackMePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   Timer? _locationUpdateTimer;
//   bool _isLoading = true;
//   String _errorMessage = '';
//   String _addressString = 'Fetching your location...';
//   bool _locationServicesDisabled = false;
  
//   // Map configuration
//   final CameraPosition _initialCameraPosition = const CameraPosition(
//     target: LatLng(19.0760, 72.8777), // Default: Mumbai
//     zoom: 14.0,
//   );
  
//   Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationServices();
//   }
  
//   @override
//   void dispose() {
//     _locationUpdateTimer?.cancel();
//     _mapController?.dispose();
//     super.dispose();
//   }

//   Future<void> _checkLocationServices() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
    
//     try {
//       // Check if location services are enabled at the system level
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() {
//           _isLoading = false;
//           _locationServicesDisabled = true;
//           _errorMessage = 'Location services are disabled on your device.';
//         });
//         return;
//       }
      
//       // If services are enabled, proceed with permission check
//       _requestLocationPermission();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Error checking location services: $e';
//       });
//       print('Location services check error: $e');
//     }
//   }

//   Future<void> _requestLocationPermission() async {
//     try {
//       // Request permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = 'Location permission denied. Please allow location access to use this feature.';
//           });
//           return;
//         }
//       }
      
//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Location permissions are permanently denied. Please enable them in your device settings.';
//         });
//         return;
//       }
      
//       // If we got here, permissions are granted
//       _getCurrentLocation();
      
//       // Start periodic updates
//       _startLocationUpdates();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Error initializing location services: $e';
//       });
//       print('Location permission error: $e');
//     }
//   }
  
//   void _startLocationUpdates() {
//     // Update location every 30 seconds
//     _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       _getCurrentLocation();
//     });
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
      
//       setState(() {
//         _currentPosition = position;
//         _isLoading = false;
//         _locationServicesDisabled = false;
//       });
      
//       // Update map camera position
//       if (_mapController != null) {
//         _mapController!.animateCamera(
//           CameraUpdate.newLatLng(
//             LatLng(position.latitude, position.longitude),
//           ),
//         );
//       }
      
//       // Update markers
//       _updateMarkers();
      
//       // Store location in Firestore
//       _storeLocationInFirestore(position);
      
//       // Update address string
//       _getAddressFromLatLng(position);
      
//     } catch (e) {
//       // Check if it's a location service disabled error
//       if (e.toString().contains("locationServicesDisabled")) {
//         setState(() {
//           _isLoading = false;
//           _locationServicesDisabled = true;
//           _errorMessage = 'Location services are disabled. Please enable location in your device settings.';
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Failed to get current location: $e';
//         });
//       }
//       print('Error getting location: $e');
//     }
//   }
  
//   Future<void> _getAddressFromLatLng(Position position) async {
//     // In a real app, you would use a geocoding service here
//     // For simplicity, we'll just display coordinates
//     setState(() {
//       _addressString = 'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
//     });
    
//     // Note: For a complete implementation, you would use a package like geocoding:
//     // import 'package:geocoding/geocoding.dart';
//     // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//     // Placemark place = placemarks[0];
//     // _addressString = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
//   }

//   void _updateMarkers() {
//     if (_currentPosition != null) {
//       setState(() {
//         _markers = {
//           Marker(
//             markerId: const MarkerId('currentLocation'),
//             position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//             infoWindow: const InfoWindow(title: 'Your Location'),
//           ),
//         };
//       });
//     }
//   }

//   Future<void> _storeLocationInFirestore(Position position) async {
//     final userId = _auth.currentUser?.uid;
    
//     if (userId != null) {
//       try {
//         await _firestore.collection('users').doc(userId).collection('locations').add({
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//           'timestamp': FieldValue.serverTimestamp(),
//           'accuracy': position.accuracy,
//           'altitude': position.altitude,
//           'speed': position.speed,
//           'speedAccuracy': position.speedAccuracy,
//           'heading': position.heading,
//         });
        
//         // Also update the user's latest location in their main document
//         await _firestore.collection('users').doc(userId).update({
//           'lastLocation': {
//             'latitude': position.latitude,
//             'longitude': position.longitude,
//             'timestamp': FieldValue.serverTimestamp(),
//           }
//         });
        
//         print('Location saved to Firestore successfully');
//       } catch (e) {
//         print('Error saving location to Firestore: $e');
//       }
//     } else {
//       print('User not authenticated, cannot save location');
//     }
//   }

//   // Open device location settings
//   void _openLocationSettings() async {
//     await AppSettings.openAppSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Track Me',
//           style: TextStyle(color: Colors.black),
//         ),
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
//           // Status and info section
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             color: const Color(0xFF3B5998).withOpacity(0.1),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5998).withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     _locationServicesDisabled ? Icons.location_off : Icons.location_on,
//                     color: Color(0xFF3B5998),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Live Location Tracking',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _isLoading 
//                             ? 'Fetching your current location...'
//                             : _errorMessage.isNotEmpty 
//                                 ? _errorMessage 
//                                 : 'Your location is being tracked and saved securely',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: _errorMessage.isNotEmpty ? Colors.red[700] : Colors.grey[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Map or Error section
//           Expanded(
//             child: _locationServicesDisabled
//                 ? _buildLocationDisabledView()
//                 : _errorMessage.isNotEmpty && !_locationServicesDisabled
//                     ? _buildErrorView()
//                     : _isLoading
//                         ? const Center(
//                             child: CircularProgressIndicator(),
//                           )
//                         : GoogleMap(
//                             initialCameraPosition: _initialCameraPosition,
//                             markers: _markers,
//                             myLocationEnabled: true,
//                             myLocationButtonEnabled: true,
//                             compassEnabled: true,
//                             mapToolbarEnabled: true,
//                             onMapCreated: (GoogleMapController controller) {
//                               _mapController = controller;
//                               if (_currentPosition != null) {
//                                 controller.animateCamera(
//                                   CameraUpdate.newLatLng(
//                                     LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//           ),
          
//           // Address card - only show if we have a position
//           if (_currentPosition != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Card(
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       const CircleAvatar(
//                         radius: 25,
//                         backgroundColor: Color(0xFF3B5998),
//                         child: Icon(
//                           Icons.location_history,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Your Current Location',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               _addressString,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
          
//           // Update location button - only if not location disabled
//           if (!_locationServicesDisabled && _errorMessage.isEmpty)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//               child: GestureDetector(
//                 onTap: _getCurrentLocation,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3B5998),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       Icon(
//                         Icons.refresh,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Update My Location',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Special view for when location services are disabled
//   Widget _buildLocationDisabledView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.location_off,
//               size: 80,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Location Services Disabled',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Your device location services are turned off. Please enable location services to use the tracking feature.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _openLocationSettings,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B5998),
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Open Location Settings',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: _checkLocationServices,
//               child: const Text(
//                 'Retry After Enabling',
//                 style: TextStyle(
//                   color: Color(0xFF3B5998),
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // View for other errors
//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.orange[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.red[700],
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _checkLocationServices,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B5998),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





//trail02
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this package for opening device settings

class TrackMePage extends StatefulWidget {
  const TrackMePage({Key? key}) : super(key: key);

  @override
  State<TrackMePage> createState() => _TrackMePageState();
}

class _TrackMePageState extends State<TrackMePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Marker> _nearbyServicesMarkers = [];
  bool _showNearbyServices = false;

   static const String _googlePlacesApiKey = 'AIzaSyB1LWBukEu9tQf8IANRU8N-dekeVeTBUFE';
  
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Timer? _locationUpdateTimer;
  bool _isLoading = true;
  String _errorMessage = '';
  String _addressString = 'Fetching your location...';
  bool _locationServicesDisabled = false;
  
  // Map configuration
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(19.0760, 72.8777), // Default: Mumbai
    zoom: 14.0,
  );
  
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }
  
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

   Future<void> _fetchNearbyServices() async {
    if (_currentPosition == null) return;

    // List of place types to search
    List<String> serviceTypes = ['police', 'hospital'];
    
    // Clear existing markers
    setState(() {
      _nearbyServicesMarkers.clear();
    });

    for (String type in serviceTypes) {
      await _searchNearbyPlaces(type);
    }
  }

   Future<void> _searchNearbyPlaces(String type) async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
      '&radius=1000' // 1 km radius
      '&type=$type'
      '&key=$_googlePlacesApiKey'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['results'] != null) {
          for (var place in data['results']) {
            _addNearbyServiceMarker(place, type);
          }
        }
      }
    } catch (e) {
      print('Error fetching nearby $type: $e');
    }
  }

   void _addNearbyServiceMarker(Map<String, dynamic> place, String type) {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];
    final name = place['name'];

    // Choose marker icon based on service type
    BitmapDescriptor markerIcon = type == 'police' 
      ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
      : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    final marker = Marker(
      markerId: MarkerId('${type}_${place['place_id']}'),
      position: LatLng(lat, lng),
      icon: markerIcon,
      infoWindow: InfoWindow(
        title: name,
        snippet: type == 'police' ? 'Police Station' : 'Hospital',
      ),
    );

    setState(() {
      _nearbyServicesMarkers.add(marker);
    });
  }

  Future<void> _checkLocationServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Check if location services are enabled at the system level
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _locationServicesDisabled = true;
          _errorMessage = 'Location services are disabled on your device.';
        });
        return;
      }
      
      // If services are enabled, proceed with permission check
      _requestLocationPermission();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking location services: $e';
      });
      print('Location services check error: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permission denied. Please allow location access to use this feature.';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permissions are permanently denied. Please enable them in your device settings.';
        });
        return;
      }
      
      // If we got here, permissions are granted
      _getCurrentLocation();
      
      // Start periodic updates
      _startLocationUpdates();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing location services: $e';
      });
      print('Location permission error: $e');
    }
  }
  
  void _startLocationUpdates() {
    // Update location every 30 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _locationServicesDisabled = false;
      });
      
      // Update map camera position
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
      
      // Update markers
      _updateMarkers();
      
      // Store location in Firestore
      _storeLocationInFirestore(position);
      
      // Update address string
      _getAddressFromLatLng(position);
      
    } catch (e) {
      // Check if it's a location service disabled error
      if (e.toString().contains("locationServicesDisabled")) {
        setState(() {
          _isLoading = false;
          _locationServicesDisabled = true;
          _errorMessage = 'Location services are disabled. Please enable location in your device settings.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to get current location: $e';
        });
      }
      print('Error getting location: $e');
    }
  }
  
  Future<void> _getAddressFromLatLng(Position position) async {
    // In a real app, you would use a geocoding service here
    // For simplicity, we'll just display coordinates
    setState(() {
      _addressString = 'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
    });
    
    // Note: For a complete implementation, you would use a package like geocoding:
    // import 'package:geocoding/geocoding.dart';
    // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark place = placemarks[0];
    // _addressString = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
  }

  void _updateMarkers() {
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        };
      });
    }
  }

  Future<void> _storeLocationInFirestore(Position position) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId != null) {
      try {
        await _firestore.collection('users').doc(userId).collection('locations').add({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'speedAccuracy': position.speedAccuracy,
          'heading': position.heading,
        });
        
        // Also update the user's latest location in their main document
        await _firestore.collection('users').doc(userId).update({
          'lastLocation': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
          }
        });
        
        print('Location saved to Firestore successfully');
      } catch (e) {
        print('Error saving location to Firestore: $e');
      }
    } else {
      print('User not authenticated, cannot save location');
    }
  }

  // Open device location settings
  void _openLocationSettings() async {
    await AppSettings.openAppSettings();
  }

  @override
  @override
Widget build(BuildContext context) {
  // Combine existing markers with nearby services markers
  Set<Marker> allMarkers = {..._markers, ..._nearbyServicesMarkers};

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Track Me',
        style: TextStyle(color: Colors.black),
      ),
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
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
    body: Column(
      children: [
        // Status and info section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          color: const Color(0xFF3B5998).withOpacity(0.1),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5998).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _locationServicesDisabled ? Icons.location_off : Icons.location_on,
                  color: Color(0xFF3B5998),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Location Tracking',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading 
                          ? 'Fetching your current location...'
                          : _errorMessage.isNotEmpty 
                              ? _errorMessage 
                              : 'Your location is being tracked and saved securely',
                      style: TextStyle(
                        fontSize: 12,
                        color: _errorMessage.isNotEmpty ? Colors.red[700] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Nearby Services Toggle (add this section)
        if (!_locationServicesDisabled && !_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Show Nearby Services',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _showNearbyServices,
                  onChanged: (bool value) {
                    setState(() {
                      _showNearbyServices = value;
                    });
                    if (value) {
                      _fetchNearbyServices();
                    }
                  },
                  activeColor: const Color(0xFF3B5998),
                ),
              ],
            ),
          ),
        
        // Map or Error section
        Expanded(
          child: _locationServicesDisabled
              ? _buildLocationDisabledView()
              : _errorMessage.isNotEmpty && !_locationServicesDisabled
                  ? _buildErrorView()
                  : _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : GoogleMap(
                          initialCameraPosition: _initialCameraPosition,
                          markers: _showNearbyServices ? allMarkers : _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          compassEnabled: true,
                          mapToolbarEnabled: true,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            if (_currentPosition != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                ),
                              );
                            }
                          },
                        ),
        ),
          
          // Address card - only show if we have a position
          if (_currentPosition != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFF3B5998),
                      child: Icon(
                        Icons.location_history,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Current Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _addressString,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
          
          // Update location button - only if not location disabled
          if (!_locationServicesDisabled && _errorMessage.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: _getCurrentLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5998),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Update My Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Special view for when location services are disabled
  Widget _buildLocationDisabledView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Location Services Disabled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your device location services are turned off. Please enable location services to use the tracking feature.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _openLocationSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5998),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Open Location Settings',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _checkLocationServices,
              child: const Text(
                'Retry After Enabling',
                style: TextStyle(
                  color: Color(0xFF3B5998),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // View for other errors
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkLocationServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5998),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}