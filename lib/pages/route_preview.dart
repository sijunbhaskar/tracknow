import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutePreview extends StatefulWidget {
  final String routeId;
  final String routeName;
  final List<LatLng> stops; // ✅ List of all stops

  const RoutePreview({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.stops,
  });

  @override
  _RoutePreviewState createState() => _RoutePreviewState();
}

class _RoutePreviewState extends State<RoutePreview> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _orsLoaded = false; // ✅ Track if ORS loaded successfully
  final String _apiKey =
      "5b3ce3597851110001cf62484dc2605f028543fda8115e355e79d0cd"; // 🔹 Replace with ORS API Key

  @override
  void initState() {
    super.initState();
    _drawInitialRoute(); // ✅ Draw Direct Line Immediately
    _fetchORSRoute(); // ✅ Fetch ORS Route in Background
  }

  /// ✅ Draw a Simple Polyline Between Stops (Fallback Route)
  void _drawInitialRoute() {
    setState(() {
      _polylines.clear();
      List<LatLng> simpleRoute = List.from(widget.stops);

      _polylines.add(
        Polyline(
          polylineId: const PolylineId("direct_route"),
          points: simpleRoute,
          color: Colors.grey, // ⏳ Temporary Direct Line (Grey)
          width: 4,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      );

      _markers.clear();
      _markers.addAll(widget.stops.map((stop) {
        return Marker(
          markerId: MarkerId(stop.toString()),
          position: stop,
          infoWindow: const InfoWindow(title: "Stop"),
        );
      }));

      _isLoading = false;
    });

    _moveCameraToRoute(widget.stops);
  }

  /// ✅ Fetch Optimized Route from ORS API in Background
  Future<void> _fetchORSRoute() async {
    if (widget.stops.length < 2) return;

    List<List<double>> coordinates = widget.stops
        .map((stop) => [stop.longitude, stop.latitude]) // ORS uses [LONG, LAT]
        .toList();

    String url =
        "https://api.openrouteservice.org/v2/directions/driving-car/geojson";

    Map<String, dynamic> requestBody = {
      "coordinates": coordinates,
      "format": "geojson"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": _apiKey, // ✅ Ensure API Key is Correct
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("🔵 ORS Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Extract Route Path Correctly
        List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        List<LatLng> routePath = coords.map((point) {
          return LatLng(point[1], point[0]); // ORS returns [LONG, LAT]
        }).toList();

        if (routePath.isNotEmpty) {
          setState(() {
            _polylines.clear(); // ✅ Remove direct polyline
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("optimized_route"),
                points: routePath,
                color: Colors.blue, // ✅ ORS Route (Blue)
                width: 5,
              ),
            );
            _orsLoaded = true; // ✅ ORS Loaded
          });

          _moveCameraToRoute(routePath);
        }
      } else {
        print("❌ ORS Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching ORS route: $e");
    }
  }

  /// ✅ Move Camera to Fit Route
  void _moveCameraToRoute(List<LatLng> routePath) {
    if (_mapController == null || routePath.isEmpty) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(_getBounds(routePath), 50),
    );
  }

  /// ✅ Get map bounds from route path
  LatLngBounds _getBounds(List<LatLng> points) {
    double south = points.first.latitude, north = points.first.latitude;
    double west = points.first.longitude, east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.routeName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(22.5726, 88.3639),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                ),
                if (!_orsLoaded) // ✅ Show "Loading ORS Route" Banner
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black87,
                      child: const Text(
                        "Loading Optimized Route...",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutePreview extends StatefulWidget {
  final String routeId;
  final String routeName;
  final List<LatLng> stops; // ✅ List of all stops

  const RoutePreview({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.stops,
  });

  @override
  _RoutePreviewState createState() => _RoutePreviewState();
}

class _RoutePreviewState extends State<RoutePreview> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  final String _apiKey =
      "5b3ce3597851110001cf62484dc2605f028543fda8115e355e79d0cd"; // 🔹 Replace with ORS API Key

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  /// ✅ Fetch Route Path from ORS API
  Future<void> _fetchRoute() async {
    if (widget.stops.length < 2) {
      _showError("❌ Not enough stops to create a route.");
      return;
    }

    List<List<double>> coordinates = widget.stops
        .map((stop) =>
            [stop.longitude, stop.latitude]) // ORS format: [LONG, LAT]
        .toList();

    String url =
        "https://api.openrouteservice.org/v2/directions/driving-car/geojson";

    Map<String, dynamic> requestBody = {
      "coordinates": coordinates,
      "format": "geojson"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": _apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print("🔵 ORS Response Code: ${response.statusCode}");
      print("🔵 ORS Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("features") &&
            data["features"].isNotEmpty &&
            data["features"][0].containsKey("geometry") &&
            data["features"][0]["geometry"].containsKey("coordinates")) {
          List<dynamic> coords = data["features"][0]["geometry"]["coordinates"];

          List<LatLng> routePath = coords.map((point) {
            if (point is List && point.length >= 2) {
              return LatLng(
                  point[1].toDouble(), point[0].toDouble()); // ORS format fix
            }
            return LatLng(0, 0); // Handle unexpected format
          }).toList();

          if (routePath.isNotEmpty) {
            setState(() {
              _polylines.clear();
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: routePath,
                  color: Colors.blue,
                  width: 5,
                ),
              );

              _markers.clear();
              _markers.addAll(widget.stops.map((stop) {
                return Marker(
                  markerId: MarkerId(stop.toString()),
                  position: stop,
                  infoWindow: const InfoWindow(title: "Stop"),
                );
              }));

              _isLoading = false;
            });

            // Ensure _mapController is initialized before updating the camera
            if (_mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngBounds(_getBounds(routePath), 50),
              );
            } else {
              Future.delayed(const Duration(seconds: 2), () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(_getBounds(routePath), 50),
                  );
                }
              });
            }
          } else {
            print("⚠ No valid route path found.");
          }
        } else {
          _showError("❌ Invalid ORS response format.");
        }
      } else {
        _showError("❌ Failed to load route (Error ${response.statusCode})");
      }
    } catch (e) {
      _showError("❌ Error fetching route: $e");
    }
  }

  /// ✅ Get map bounds from route path
  LatLngBounds _getBounds(List<LatLng> points) {
    double south = points.first.latitude, north = points.first.latitude;
    double west = points.first.longitude, east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  /// ✅ Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.routeName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(22.5726, 88.3639),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            ),
    );
  }
}*/
