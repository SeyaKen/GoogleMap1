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
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = Set<Marker>();
  final Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _setMarker(const LatLng(37.42796133580664, -122.085749655962));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker'),
        position: point,
      ));
    });
  }

  void _setPolygon() {
    final polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polygonLatLngs,
      strokeWidth: 2,
      fillColor: Colors.transparent,
    ));
  }

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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      // 単語の最初の文字だけ大文字
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: '出発点',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    TextFormField(
                      controller: _destinationController,
                      // 単語の最初の文字だけ大文字
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: '目的地',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  // var place =
                  //     await LocationService().getPlace(_searchController.text);
                  // _goToPlace(place);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Expanded(
          //         child: TextFormField(
          //       controller: _searchController,
          //       // 単語の最初の文字だけ大文字
          //       textCapitalization: TextCapitalization.words,
          //       decoration: const InputDecoration(
          //         hintText: '探す',
          //         contentPadding: EdgeInsets.symmetric(horizontal: 10),
          //       ),
          //     )),
          //     IconButton(
          //       onPressed: () async {
          //         var place =
          //             await LocationService().getPlace(_searchController.text);
          //         _goToPlace(place);
          //       },
          //       icon: const Icon(Icons.search),
          //     ),
          //   ],
          // ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              // 二つ追加すると、二つピンが立つ
              // markersを設定することで地図上にピンを置ける。
              markers: _markers,
              polygons: _polygons,
              // polylinesを設定することで場所と場所を線で結ぶことができる。
              // polylines: {
              //   _kPolyline,
              // },
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
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

    _setMarker(LatLng(lat, lng));
  }
}
