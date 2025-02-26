import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'route_preview.dart'; // ✅ Navigate to Route Preview after selection

class RouteSelection extends StatefulWidget {
  const RouteSelection({super.key});

  @override
  _RouteSelectionState createState() => _RouteSelectionState();
}

class _RouteSelectionState extends State<RouteSelection> {
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  /// ✅ Fetch available routes from the backend
  Future<void> _fetchRoutes() async {
    try {
      final response = await http.get(
        Uri.parse("https://bustrackingapp-oezp.onrender.com/routes"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _routes = data.map((route) {
            return {
              "id": route["routeId"]
                  .toString(), // ✅ Ensure ID is properly assigned
              "name": route["routeName"], // ✅ Ensure Name is properly assigned
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        _showError("⚠ Failed to load routes (Error ${response.statusCode})");
      }
    } catch (e) {
      _showError("❌ Error fetching routes: $e");
    }
  }

  /// ✅ Fetch stops for selected route & Navigate
  void _selectRoute(String routeId, String routeName) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://bustrackingapp-oezp.onrender.com/routes/$routeId/stops"),
      );

      if (response.statusCode == 200) {
        List<dynamic> stopData = jsonDecode(response.body);

        List<LatLng> stops = stopData.map((stop) {
          return LatLng(stop["latitude"], stop["longitude"]);
        }).toList();

        if (stops.isEmpty) {
          _showError("⚠ No stops available for this route.");
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoutePreview(
              routeId: routeId,
              routeName: routeName,
              stops: stops,
            ),
          ),
        );
      } else {
        _showError("⚠ Failed to fetch stops (Error ${response.statusCode})");
      }
    } catch (e) {
      _showError("❌ Error fetching stops: $e");
    }
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
      appBar: AppBar(title: const Text("Select a Route")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? const Center(child: Text("No routes available"))
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.directions_bus,
                            color: Colors.blue),
                        title: Text(route["name"],
                            style: const TextStyle(fontSize: 18)),
                        onTap: () => _selectRoute(route["id"], route["name"]),
                      ),
                    );
                  },
                ),
    );
  }
}
