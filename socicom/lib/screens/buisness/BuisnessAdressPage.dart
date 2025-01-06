import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuisnessAdressPage extends StatefulWidget {
  final Map<String, dynamic> buisnessData;

  const BuisnessAdressPage({required this.buisnessData, super.key});

  @override
  State<BuisnessAdressPage> createState() => _BuisnessAdressPageState();
}

class _BuisnessAdressPageState extends State<BuisnessAdressPage> {
  GoogleMapController? _mapController;
  LatLng? _buisnessLocation;
  String? _addressDocId;

  @override
  void initState() {
    super.initState();
    _fetchBuisnessLocation();
  }

  Future<void> _fetchBuisnessLocation() async {
    try {
      final buisnessId = widget.buisnessData['buisness_id'];

      // Doğru belgeyi buisness_id ile bul
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .where('buisness_id', isEqualTo: buisnessId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        // Adres alt koleksiyonunu al
        final addressSnapshot = await FirebaseFirestore.instance
            .collection('buisness_profiles')
            .doc(doc.id)
            .collection('address')
            .get();

        if (addressSnapshot.docs.isNotEmpty) {
          final addressData = addressSnapshot.docs.first.data();
          setState(() {
            _buisnessLocation = LatLng(addressData['latitude'], addressData['longitude']);
            _addressDocId = addressSnapshot.docs.first.id; // Adres belgesinin ID'si
          });
        } else {
          print('Adres bilgisi bulunamadı.');
        }
      } else {
        print('buisness_id ile eşleşen belge bulunamadı.');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      final buisnessId = widget.buisnessData['buisness_id'];

      // Doğru belgeyi buisness_id ile bul
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .where('buisness_id', isEqualTo: buisnessId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        if (_addressDocId != null) {
          // Adres belgesini güncelle
          await FirebaseFirestore.instance
              .collection('buisness_profiles')
              .doc(doc.id)
              .collection('address')
              .doc(_addressDocId)
              .update({
            'latitude': latitude,
            'longitude': longitude,
          });

          setState(() {
            _buisnessLocation = LatLng(latitude, longitude);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adres başarıyla güncellendi!')),
          );
        } else {
          print('Adres belgesi ID bulunamadı.');
        }
      } else {
        print('buisness_id ile eşleşen belge bulunamadı.');
      }
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adres güncellenirken hata oluştu.')),
      );
    }
  }

  void _openNewMapToPickLocation() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: _buisnessLocation,
        ),
      ),
    );

    if (pickedLocation != null) {
      _updateAddress(pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Adresiniz'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _buisnessLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _buisnessLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('buisnessLocation'),
                      position: _buisnessLocation!,
                      infoWindow: const InfoWindow(title: 'İşletme Konumu'),
                    ),
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: _openNewMapToPickLocation,
                    child: const Icon(Icons.edit_location_alt),
                  ),
                ),
              ],
            ),
    );
  }
}

class MapPickerScreen extends StatelessWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({this.initialLocation, super.key});

  @override
  Widget build(BuildContext context) {
    LatLng? selectedLocation = initialLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onTap: (location) {
              selectedLocation = location;
            },
            initialCameraPosition: CameraPosition(
              target: initialLocation ?? const LatLng(37.7749, -122.4194),
              zoom: 12,
            ),
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: selectedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            left: 20, // Sol kenardan uzaklık
            bottom: 20, // Alt kenardan uzaklık
            child: FloatingActionButton(
              onPressed: () {
                if (selectedLocation != null) {
                  Navigator.of(context).pop(selectedLocation);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir konum seçin.')),
                  );
                }
              },
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

