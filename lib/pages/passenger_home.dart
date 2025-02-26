import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'login_page.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  _PassengerHomeState createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  GoogleMapController? _mapController;
  Map<String, Marker> _busMarkers = {};
  bool _isLoading = true;
  bool _isPermissionGranted = false;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showError("Location permission is required to use live tracking.");
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _isPermissionGranted = true;
      _userLocation = LatLng(position.latitude, position.longitude);
    });
    _showNearbyPrompt();
  }

  void _showNearbyPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Show Nearby Stops & Buses?"),
        content: const Text(
            "Would you like to see nearby bus stops and live buses?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: const Text("No, Thanks"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchBusLocations();
              _connectToSocket();
            },
            child: const Text("Yes, Show Me"),
          ),
        ],
      ),
    );
  }

  void _fetchBusLocations() async {
    try {
      List<Map<String, dynamic>> buses = await ApiService.getAllBuses();
      BitmapDescriptor busIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/bus_marker.png',
      );

      setState(() {
        for (var bus in buses) {
          _busMarkers[bus['busId']] = Marker(
            markerId: MarkerId(bus['busId']),
            position: bus['location'],
            icon: busIcon, // Use custom marker image
            infoWindow: InfoWindow(title: "Bus ${bus['busId']}"),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      _showError("Error fetching bus locations: $e");
    }
  }

  void _connectToSocket() async {
    BitmapDescriptor busIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/bus_marker.png',
    );

    SocketService.onLocationUpdate = (LatLng newLocation, String busId) {
      setState(() {
        _busMarkers[busId] = Marker(
          markerId: MarkerId(busId),
          position: newLocation,
          icon: busIcon, // Use custom marker image
          infoWindow: InfoWindow(title: "Bus $busId (Live)"),
        );
      });

      if (_mapController != null) {
        double distance = Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );
        if (distance > 100) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
        }
      }
    };

    SocketService.connectToSocket();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Bus Tracking"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isPermissionGranted
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation ?? const LatLng(22.5726, 88.3639),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: Set<Marker>.of(_busMarkers.values),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            )
          : const Center(
              child: Text(
                "Location permission is required to proceed.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() => _isLoading = false);
  }
}
