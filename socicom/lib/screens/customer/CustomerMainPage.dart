import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_package;
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // İşletme Listesi ve Ziyaret Sayıları
  List<Map<String, dynamic>> _buisnesses = [];
  Map<String, int> _visitCounts = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchTopbuisnesses();
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
      final GoogleMapController controller =
          await _mapControllerCompleter.future;
      final currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
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

  Future<void> _fetchTopbuisnesses() async {
    try {
      print("Firestore'dan ben_buradayım koleksiyonu çekiliyor...");
      
      // 1. ben_buradayım koleksiyonundaki tüm belgeleri çek
      final benBuradayimSnapshot = await FirebaseFirestore.instance
          .collection('ben_buradayim')
          .get();

      print("Veriler çekildi: ${benBuradayimSnapshot.docs.length} belge bulundu.");

      // 2. buisness_id'leri ve sayımlarını tutmak için bir Map oluştur
      Map<String, int> buisnessIdCount = {};

      for (var doc in benBuradayimSnapshot.docs) {
        final buisnessId = doc['buisness_id'] as String;
        if (buisnessIdCount.containsKey(buisnessId)) {
          buisnessIdCount[buisnessId] = buisnessIdCount[buisnessId]! + 1;
        } else {
          buisnessIdCount[buisnessId] = 1;
        }
      }

      print("buisness ID'ler sayıldı: $buisnessIdCount");

      // 3. buisness_id'leri sıklığa göre azalan sırayla sırala ve ilk 3'ü al
      final topbuisnessIds = (buisnessIdCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
          .take(3)
          .map((entry) => entry.key)
          .toList();

      print("En çok kullanılan buisness_id'ler: $topbuisnessIds");

      // 4. buisness_profiles koleksiyonundan bu ID'lere ait işletme bilgilerini getir
      List<Map<String, dynamic>> buisnesses = [];
      for (String buisnessId in topbuisnessIds) {
        final buisnessSnapshot = await FirebaseFirestore.instance
            .collection('buisness_profiles')
            .where('buisness_id', isEqualTo: buisnessId)
            .get();

        if (buisnessSnapshot.docs.isNotEmpty) {
          final data = buisnessSnapshot.docs.first.data();
          buisnesses.add({
            'buisness_id': buisnessId,
            'name': data['buisness_name'], // Yeni isim
            'logo_path': data['buisness_logo'], // Yeni isim
          });
        } else {
          print("buisness profili bulunamadı: $buisnessId");
        }
      }

      // 5. İşletmeler ve ziyaret sayısını UI için güncelle
      setState(() {
        _buisnesses = buisnesses;
        _visitCounts = buisnessIdCount;
      });

      print("İşletmeler UI için hazırlandı: $_buisnesses");
    } catch (e) {
      print("Hata: İşletme verileri alınamadı - $e");
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Haftanın Yıldızları',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // İşletmeler Listesi
            Expanded(
              child: _buisnesses.isEmpty
                  ? const Center(
                      child: Text(
                        'Hiç işletme bulunamadı.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _buisnesses.length,
                      itemBuilder: (context, index) {
                        final buisness = _buisnesses[index];
                        final visitCount =
                            _visitCounts[buisness['buisness_id']] ?? 0;
                        return buisnessItem(
                          buisness['logo_path'] ?? '',
                          buisness['name'] ?? 'Bilinmeyen İşletme',
                          visitCount,
                        );
                      },
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

  Widget buisnessItem(String imagePath, String name, int visitCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imagePath),
          radius: 30,
        ),
        title: Text(name, style: const TextStyle(fontSize: 16)),
        subtitle: Text('$visitCount kişi buradaydı'),
      ),
    );
  }
}