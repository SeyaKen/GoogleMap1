import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap1/location_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // positionで指定したところの地図上に「ピン」を置く
  static const Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: '現在地'),
    // ピン
    icon: BitmapDescriptor.defaultMarker,
    // ピンを置く場所
    position: LatLng(37.42796133580664, -122.085749655962),
  );

  // 湖のpositionを指定
  static final Marker _kLakeMarker = Marker(
    markerId: const MarkerId('_kGooglePlex'),
    infoWindow: const InfoWindow(title: 'みずうみ'),
    // ピンの色を変えることができる※デフォルトは赤
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: const LatLng(37.43296265331129, -122.08832357078792),
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  // 二つの点を結ぶ
  static const Polyline _kPolyline = Polyline(
    polylineId: PolylineId('_kPolyline'),
    points: [
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.43296265331129, -122.08832357078792),
    ],
    // 線の太さ
    width: 5,
  );

  // 線ではなく多角形もできる。
  static const Polygon _Polygon = Polygon(
    polygonId: PolygonId('_kPolygon'),
    points: [
      LatLng(37.43296265331129, -122.08832357078792),
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.418, -122.092),
      LatLng(37.435, -122.092),
    ],
    // 線の太さ
    strokeWidth: 5,
    // 真ん中を透明にして、線にする。
    fillColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _searchController,
                // 単語の最初の文字だけ大文字
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: '探す',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              )),
              IconButton(
                onPressed: () async {
                  var place =
                      await LocationService().getPlace(_searchController.text);
                  _goToPlace(place);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              // 二つ追加すると、二つピンが立つ
              // markersを設定することで地図上にピンを置ける。
              markers: {
                _kGooglePlexMarker,
                // _kLakeMarker,
              },
              // polylinesを設定することで場所と場所を線で結ぶことができる。
              polylines: {
                _kPolyline,
              },
              polygons: {
                _Polygon,
              },
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    // 緯度
    final double lat = place['geometry']['location']['lat'];
    // 経度
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 12,
    )));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
