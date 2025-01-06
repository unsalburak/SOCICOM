import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CustomerDirectionsWithRoute extends StatefulWidget {
  final String buisnessId;

  const CustomerDirectionsWithRoute({super.key, required this.buisnessId});

  @override
  State<CustomerDirectionsWithRoute> createState() =>
      _CustomerDirectionsWithRouteState();
}

class _CustomerDirectionsWithRouteState
    extends State<CustomerDirectionsWithRoute> {
  LocationData? _currentLocation;
  LatLng? _buisnessLocation;
  List<LatLng> polylineCoordinates = [];
  final String googleApiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchBuisnessData().then((_) {
      _fetchRoute();
    });
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      final locationData = await location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  Future<void> _fetchBuisnessData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .where('buisness_id', isEqualTo: widget.buisnessId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final addressCollection =
            await snapshot.docs.first.reference.collection('address').get();

        if (addressCollection.docs.isNotEmpty) {
          final addressData = addressCollection.docs.first.data();

          if (addressData.containsKey('latitude') &&
              addressData.containsKey('longitude')) {
            setState(() {
              _buisnessLocation = LatLng(
                addressData['latitude'],
                addressData['longitude'],
              );
            });
          }
        }
      }
    } catch (e) {
      print("İşletme verisi alınamadı: $e");
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _buisnessLocation == null) return;

    final String origin =
        "${_currentLocation!.latitude},${_currentLocation!.longitude}";
    final String destination =
        "${_buisnessLocation!.latitude},${_buisnessLocation!.longitude}";

    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleApiKey";

    try {
      final response = await Dio().get(url);
      print("Directions API Response: ${response.data}");

      final data = response.data;
      if (data['status'] == 'OK') {
        final points = data['routes'][0]['overview_polyline']['points'];
        polylineCoordinates.clear();
        polylineCoordinates.addAll(
          PolylinePoints()
              .decodePolyline(points)
              .map((point) => LatLng(point.latitude, point.longitude)),
        );
        print("Polyline Points: $polylineCoordinates");
        setState(() {});
      } else {
        print("Directions API Error: ${data['status']}");
      }
    } catch (e) {
      print("Directions API çağrısı sırasında hata: $e");
    }
  }

  Set<Marker> _createMarkers() {
    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
        infoWindow: const InfoWindow(title: "Mevcut Konumunuz"),
      ),
      if (_buisnessLocation != null)
        Marker(
          markerId: const MarkerId('buisness_location'),
          position: _buisnessLocation!,
          infoWindow: const InfoWindow(title: "Hedef Konum"),
        ),
    };
  }

  Set<Polyline> _createPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yol Tarifi"),
      ),
      body: _currentLocation == null || _buisnessLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 14,
              ),
              markers: _createMarkers(),
              polylines: _createPolylines(),
            ),
    );
  }
}
