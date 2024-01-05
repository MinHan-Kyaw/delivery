import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

int check = 0;
double lati = 22.9087753;
double longi = 96.4227587;
double aa = 16;
double bb = 18;
enum PopupMenuChoices { first, second }

class GetLocationPage extends StatefulWidget {
  @override
  _GetLocationPageState createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage>
    with TickerProviderStateMixin {
  // var location = new Location();
  Geolocator geolocator = Geolocator();

  Position userLocation;
  // Map<String, double> userLocation;
  MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    this._getLocation();
  }

  

  String dropdownValue;
  List markers;
  // static const String route = 'map_controller_animated';
  static LatLng london = LatLng(lati, longi);
  void _animatedMapMove(LatLng destLocation, double destZoom) {

    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: new MapOptions(
              onTap: _handleTap,
              zoom: 16,
              maxZoom: 100,
              minZoom: 10,
              center: london,
            ),
            layers: [
              new TileLayerOptions(
                urlTemplate: check == 0
                    ? 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png'
                    : 'http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                maxZoom: 100,
                subdomains:
                    check == 0 ? ['a', 'b', 'c'] : ['mt0', 'mt1', 'mt2', 'mt3'],
              ),
              new MarkerLayerOptions(markers: [
                new Marker(
                  width: 45,
                  height: 47,
                  point: london,
                  builder: (context) => new Icon(
                    Icons.location_on,
                    color: Colors.deepOrange,
                    textDirection: TextDirection.rtl,
                    size: 50,
                  ),
                ),
              ])
            ],
          ),
          Positioned(
            top: 15,
            right: 2,
            child: MaterialButton(
              child: Container(
                color: Colors.white,
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                _animatedMapMove(london, bb++);
                aa = 16;
              },
            ),
          ),
          Positioned(
            top: 60,
            right: 33,
            child: InkWell(
              onTap: () {
                _animatedMapMove(london, aa--);
                bb = 18;
              },
              child: Container(
                  height: 25,
                  width: 25,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.5, vertical: 11.5),
                    child: Container(
                      color: Colors.black,
                    ),
                  )),
            ),
          ),
          Positioned(
            top: 105,
            right: 28,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: selectPopup(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(Icons.my_location, color: Colors.black, size: 30),
          onPressed: () {
            _getLocation().then((value) {
              setState(() {
                userLocation = value;
                lati = userLocation.latitude;
                longi = userLocation.longitude;
                london = LatLng(lati, longi);
                _animatedMapMove(london, 16);
              });
            });
            print(userLocation.longitude.toString());
           
          }),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }


  Widget selectPopup() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("default"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("satellite"),
          ),
        ],
        initialValue: 0,
        onCanceled: () {
          print("You have canceled the menu.");
        },
        onSelected: (value) {
          print(value);
          if (value == 2) {
            setState(() {
              check = 1;
            });
          } else {
            setState(() {
              check = 0;
            });
          }
        },
        icon: Icon(
          Icons.layers,
          color: Colors.black,
        ),
      );

  _handleTap(LatLng point) {
    setState(() {
      london = LatLng(point.latitude, point.longitude);
    });
  }
}
