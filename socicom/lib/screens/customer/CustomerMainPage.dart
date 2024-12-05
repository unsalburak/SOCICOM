import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_package;

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  _CustomerMainPageState createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  // Harita Kontrolleri
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();
  location_package.LocationData? _currentLocation;
  final location_package.Location _locationService = location_package.Location();
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final permissionStatus = await _locationService.requestPermission();
    if (permissionStatus == location_package.PermissionStatus.granted) {
      setState(() {
        _permissionGranted = true;
      });
      await _getCurrentLocation();
    } else {
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _locationService.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
      _moveCameraToCurrentLocation();
    } catch (e) {
      print("Hata: Konum alınamadı - $e");
    }
  }

  Future<void> _moveCameraToCurrentLocation() async {
    if (_currentLocation != null && _mapControllerCompleter.isCompleted) {
      final GoogleMapController controller = await _mapControllerCompleter.future;
      final currentLatLng = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLatLng,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // İşletmeler Listesi
            Expanded(
              child: ListView(
                children: [
                  businessItem('assets/barbecue_logo.png', 'BarbeCue'),
                  const SizedBox(height: 10),
                  businessItem('assets/antojitos_logo.png', 'Antojitos'),
                  const SizedBox(height: 10),
                  businessItem('assets/ecofood_logo.png', 'EcoFood'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Dinamik Harita Alanı
            Container(
              height: 325,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _permissionGranted && _currentLocation != null
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!,
                          ),
                          zoom: 16.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget businessItem(String imagePath, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        title: Text(name, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
