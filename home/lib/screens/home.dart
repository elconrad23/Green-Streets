import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webservice_ex/places.dart";

import 'api_key.dart';

// Center of the Google Map
const initialPosition = LatLng(37.7786, -122.4375);
// Hue used by the Google Map Markers to match the theme
const _pinkHue = 350.0;
// Places API client used for Place Photos
final _placesApiClient = GoogleMapsPlaces(apiKey: googleMapsApiKey);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Destination Routes',
      home: const HomePage(title: 'Traffic Destination Routes'),
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        useMaterial3: true,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({required this.title, super.key});
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot> _favorableRoutes;
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _favorableRoutes = FirebaseFirestore.instance
        .collection('favorable_routes')
        .orderBy('time_length')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _favorableRoutes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading...'));
          }

          return Stack(
            children: [
              StoreMap(
                documents: snapshot.data!.docs,
                initialPosition: initialPosition,
                mapController: _mapController,
              ),
              StoreCarousel(
                mapController: _mapController,
                documents: snapshot.data!.docs,
              ),
            ],
          );
        },
      ),
    );
  }
}

class StoreCarousel extends StatelessWidget {
  const StoreCarousel({
    super.key,
    required this.documents,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 90,
          child: StoreCarouselList(
            documents: documents,
            mapController: mapController,
          ),
        ),
      ),
    );
  }
}

class StoreCarouselList extends StatelessWidget {
  const StoreCarouselList({
    super.key,
    required this.documents,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Card(
              child: Center(
                child: StoreListTile(
                  document: documents[index],
                  mapController: mapController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreListTile extends StatefulWidget {
  const StoreListTile({
    super.key,
    required this.document,
    required this.mapController,
  });

  final DocumentSnapshot document;
  final Completer<GoogleMapController> mapController;

  @override
  State<StatefulWidget> createState() {
    return _StoreListTileState();
  }
}

class _StoreListTileState extends State<StoreListTile> {
  String _placePhotoUrl = '';
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _retrievePlacesDetails();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _retrievePlacesDetails() async {
    final details = await _placesApiClient
        .getDetailsByPlaceId(widget.document['placeId'] as String);
    if (!_disposed) {
      setState(() {
        _placePhotoUrl = _placesApiClient.buildPhotoUrl(
          photoReference: details.result!.photos[0].photoReference,
          maxHeight: 300,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.document['name'] as String),
      subtitle: Text(widget.document['address'] as String),
      leading: SizedBox(
        width: 100,
        height: 100,
        child: _placePhotoUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: Image.network(_placePhotoUrl, fit: BoxFit.cover),
              )
            : Container(),
      ),
      onTap: () async {
        final controller = await widget.mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                widget.document['location'].latitude as double,
                widget.document['location'].longitude as double,
              ),
              zoom: 16,
            ),
          ),
        );
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap({
    super.key,
    required this.documents,
    required this.initialPosition,
    required this.mapController,
  });

  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: documents
          .map((document) => Marker(
                markerId: MarkerId(document['placeId'] as String),
                icon: BitmapDescriptor.defaultMarkerWithHue(_pinkHue),
                position: LatLng(
                  document['location'].latitude as double,
                  document['location'].longitude as double,
                ),
                infoWindow: InfoWindow(
                  title: document['name'] as String?,
                  snippet: document['address'] as String?,
                ),
              ))
          .toSet(),
      onMapCreated: (mapController) {
        this.mapController.complete(mapController);
      },
    );
  }
}

