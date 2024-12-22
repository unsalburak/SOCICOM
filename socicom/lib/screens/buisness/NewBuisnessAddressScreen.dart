import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_package;

class NewBusinessAddressScreen extends StatefulWidget {
  const NewBusinessAddressScreen({super.key});

  @override
  _NewBusinessAddressScreenState createState() =>
      _NewBusinessAddressScreenState();
}

class _NewBusinessAddressScreenState extends State<NewBusinessAddressScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();
  location_package.LocationData? _currentLocation;
  final location_package.Location _locationService = location_package.Location();
  bool _permissionGranted = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final permissionStatus = await _locationService.requestPermission();
    if (permissionStatus == location_package.PermissionStatus.granted) {
      _permissionGranted = true;
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
        _selectedLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
      _moveCameraToCurrentLocation();
    } catch (e) {
      print("Hata: Konum alınamadı - $e");
    }
  }

  Future<void> _moveCameraToCurrentLocation() async {
    if (_currentLocation != null && _mapControllerCompleter.isCompleted) {
      final GoogleMapController controller =
          await _mapControllerCompleter.future;
      final currentLatLng = LatLng(
          _currentLocation!.latitude!, _currentLocation!.longitude!);

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLatLng,
            zoom: 16.0,
          ),
        ),
      );

      setState(() {
        _selectedLocation = currentLatLng;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
      if (_currentLocation != null) {
        _moveCameraToCurrentLocation();
      }
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _saveAndReturn() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir konum seçin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Adres Bilgileri',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
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
                        myLocationButtonEnabled: true,
                        onTap: _onTap,
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId:
                                      const MarkerId('selected_location'),
                                  position: _selectedLocation!,
                                ),
                              }
                            : {},
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAndReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Adres Kaydet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
