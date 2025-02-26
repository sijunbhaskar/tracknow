import 'package:flutter/material.dart';
import 'route_selection.dart';
import 'passenger_home.dart';
import 'eta_page.dart'; // ✅ Import ETA Page
import 'alerts_page.dart'; // ✅ Import Alerts Page
import 'settings.dart'; // ✅ Import Settings Page
import 'nearby_stops.dart'; // ✅ Import Nearby Stops Page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Now',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Get real-time updates, track buses, and plan your journey with ease.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildFeatureButton(
                    context,
                    title: 'Nearby Stops',
                    icon: Icons.location_on,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NearbyStops()),
                    ),
                  ),
                  _buildFeatureButton(
                    context,
                    title: 'Select Routes',
                    icon: Icons.directions_bus,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RouteSelection()),
                    ),
                  ),
                  _buildFeatureButton(
                    context,
                    title: 'Live Tracking',
                    icon: Icons.map,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PassengerHome()),
                    ),
                  ),
                  _buildFeatureButton(
                    context,
                    title: 'ETA Alerts',
                    icon: Icons.access_time,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ETAPage()),
                    ),
                  ),
                  _buildFeatureButton(
                    context,
                    title: 'Announcements',
                    icon: Icons.announcement,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlertsPage()),
                    ),
                  ),
                  _buildFeatureButton(
                    context,
                    title: 'Settings',
                    icon: Icons.settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
