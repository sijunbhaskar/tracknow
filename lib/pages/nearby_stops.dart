import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NearbyStops extends StatefulWidget {
  const NearbyStops({super.key});

  @override
  _NearbyStopsState createState() => _NearbyStopsState();
}

class _NearbyStopsState extends State<NearbyStops> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _nearbyStops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showError("Location permission denied!");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );

    _fetchStops();
  }

  Future<void> _fetchStops() async {
    try {
      final response = await http.get(
        Uri.parse("https://bustrackingapp-oezp.onrender.com/stops"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> allStops =
            List<Map<String, dynamic>>.from(data);

        _filterNearbyStops(allStops);
      } else {
        _showError("Failed to load stops.");
      }
    } catch (e) {
      _showError("Error fetching stops: $e");
    }
  }

  void _filterNearbyStops(List<Map<String, dynamic>> allStops) {
    if (_currentPosition == null) return;

    List<Map<String, dynamic>> nearbyStops = allStops.where((stop) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        stop["latitude"],
        stop["longitude"],
      );

      return distance <= 1000;
    }).toList();

    setState(() {
      _nearbyStops = nearbyStops;
      _isLoading = false;
    });

    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    _markers.clear();

    for (var stop in _nearbyStops) {
      LatLng stopLocation = LatLng(stop["latitude"], stop["longitude"]);

      _markers.add(
        Marker(
          markerId: MarkerId(stop["stopName"]),
          position: stopLocation,
          infoWindow: InfoWindow(title: stop["stopName"]),
        ),
      );
    }

    setState(() {});
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Bus Stops"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(22.5726, 88.3639),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: _nearbyStops.length,
                      itemBuilder: (context, index) {
                        final stop = _nearbyStops[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            title: Text(
                              stop["stopName"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Distance: ${(Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, stop["latitude"], stop["longitude"]) / 1000).toStringAsFixed(2)} km",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            leading: Icon(Icons.location_on,
                                color: Colors.blueAccent, size: 30),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
