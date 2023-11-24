import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  Set<Polygon> _polygons = {};
  Set<Polyline> _polylines = {};
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.565160, -46.651797), zoom: 19);

  _onMapCreated(GoogleMapController googleMapController) {
    _controller.complete(googleMapController);
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  _carregarMarcadores() {
    Set<Marker> marcadoresLocal = {};

    Marker marcadorShopping = Marker(
        markerId: MarkerId("marcador-shopping"),
        position: LatLng(-27.613276221255145, -48.647764306093244),
        infoWindow: InfoWindow(title: "Shopping "),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        onTap: () {
          print("Shopping clicado!!");
        }
        //rotation: 45
        );

    Marker marcadorMercado = Marker(
        markerId: MarkerId("marcador-mercado"),
        position: LatLng(-27.612436390913096, -48.64457305560867),
        infoWindow: InfoWindow(title: "Mercado"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          print("Mercado clicado!!");
        });

    marcadoresLocal.add(marcadorShopping);
    marcadoresLocal.add(marcadorMercado);

    setState(() {
      _marcadores = marcadoresLocal;
    });

    Set<Polygon> listaPolygons = {};
    Polygon polygon1 = Polygon(
      polygonId: PolygonId("polygon1"),
      fillColor: const Color.fromARGB(71, 76, 175, 79),
      strokeColor: Colors.red,
      strokeWidth: 2,
      points: [
        LatLng(-27.615728943217373, -48.64853678230792),
        LatLng(-27.6142078818029, -48.647614102384836),
        LatLng(-27.613276221255145, -48.647764306093244),
        LatLng(-27.61262975825893, -48.64699182987855),
        LatLng(-27.614131828177687, -48.64347277156719),
        LatLng(-27.617154919108387, -48.6463910150449),
      ],
      consumeTapEvents: true,
      onTap: () {
        print("Clicou no continente shopping");
      },
      // zIndex: 1
    );

    Polygon polygon2 = Polygon(
      polygonId: PolygonId("polygon2"),
      fillColor: Color.fromARGB(80, 176, 39, 39),
      strokeColor: const Color.fromARGB(255, 55, 0, 255),
      strokeWidth: 2,
      points: [
        LatLng(-27.613063850937955, -48.64493668166542),
        LatLng(-27.612436390913096, -48.64457305560867),
        LatLng(-27.612747294980643, -48.643871321125346),
        LatLng(-27.613363447702397, -48.64425408539561),
      ],
      consumeTapEvents: true,
      onTap: () {
        print("clicou no lider atacadista");
      },
      // zIndex: 0
    );

    listaPolygons.add(polygon1);
    listaPolygons.add(polygon2);

    setState(() {
      _polygons = listaPolygons;
    });

    Set<Polyline> listaPolylines = {};
    Polyline polyline1 = Polyline(
      polylineId: PolylineId('value'),
      color: Colors.red,
      width: 5,
      points: [
        LatLng(-27.61408855121143, -48.64329474179838),
        LatLng(-27.61251935549772, -48.646925106049615),
        LatLng(-27.61209218166069, -48.65122448051517),
      ],
    );
    listaPolylines.add(polyline1);
    setState(() {
      _polylines = listaPolylines;
    });
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 17);
      _movimentarCamera();
    });

    //-23.565327, -46.650585

    //print("localizacao atual: " + position.toString() );
  }

  _adicionarListenerLocalizacao() {
    var locationSettings =
        LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print("localizacao atual: " + position.toString());

      Marker marcadorUsuario = Marker(
          markerId: MarkerId("marcador-usuario"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: "Meu local"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta),
          onTap: () {
            print("Meu local clicado!!");
          }
          //rotation: 45
          );

      setState(() {
        //-23.566989, -46.649598
        //-23.568395, -46.648353
        _marcadores.add(marcadorUsuario);
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 17);
        _movimentarCamera();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarMarcadores();
    //_recuperarLocalizacaoAtual();
    _adicionarListenerLocalizacao();
  }

  List<LatLng> listLatLng = [];
  _marcar(LatLng latLng) {
    listLatLng.add(latLng);

    print(listLatLng.toString());
    Set<Polyline> listaPolylines = {};
    Polyline polyline = Polyline(
        zIndex: 1,
        polylineId: PolylineId("polyline"),
        color: Colors.red,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        points: listLatLng);

    listaPolylines.add(polyline);
    setState(() {
      _polylines = listaPolylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testando mapa"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.done), onPressed: _movimentarCamera),
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          //mapType: MapType.hybrid,
          //mapType: MapType.none,
          //mapType: MapType.satellite,
          //mapType: MapType.terrain,
          //-23.562436, -46.655005
          initialCameraPosition: _posicaoCamera,
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          markers: _marcadores,
          onLongPress: _marcar,
          polygons: _polygons,
          polylines: _polylines,
        ),
      ),
    );
  }
}
