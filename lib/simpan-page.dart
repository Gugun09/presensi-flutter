import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  _SimpanPageState createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  Future<LocationData?> _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    LocationData locationData = await location.getLocation();
    print(
        "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}");
    return locationData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Presensi"),
      ),
      body: FutureBuilder<LocationData?>(
          future: _currentLocation(),
          builder:
              (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data!;
              return SafeArea(
                  child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(layers: [
                      MapTileLayer(
                        initialFocalLatLng: MapLatLng(currentLocation.latitude!,
                            currentLocation.longitude!),
                        initialZoomLevel: 15,
                        initialMarkersCount: 1,
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        markerBuilder: (BuildContext context, int index) {
                          return MapMarker(
                            latitude: currentLocation.latitude!,
                            longitude: currentLocation.longitude!,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          );
                        },
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {}, child: Text("Simpan Presensi"))
                ],
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
