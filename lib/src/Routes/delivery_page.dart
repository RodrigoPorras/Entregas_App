import 'dart:async';

import 'package:entregas_app/src/Providers/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class DeliveryPage extends StatefulWidget {
  //DeliveryPage({Key key}) : super(key: key);

  final String cedula;

  DeliveryPage({
    @required this.cedula,
  });

  @override
  _DeliveryPageState createState() => _DeliveryPageState();

}

class _DeliveryPageState extends State<DeliveryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var title = "Entregas Pendientes";

  static var cedula = "";

  static var nombre = '';

  static var geolocator = Geolocator();

  static var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(

          (Position position) {
            print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
            UpdateFirebasePosition(position);

      });

  static void UpdateFirebasePosition(Position position) async {
    FirebaseDatabase().reference().child('class_persona').child(cedula).update({
      'latitud' : '${position.latitude}',
      'longitud' : '${position.longitude}'
    });

  }

  var _deliveryQuery;
  var _deliveries =  new Map<dynamic, dynamic>();
  var _deliveried = new Map<dynamic, dynamic>();

  @override
  void initState() {
    super.initState();

    cedula =  widget.cedula;

    FirebaseDatabase().reference().child('class_persona').child(cedula).once().then(
            (value) => nombre = value.value['nombre']
    );

    _deliveryQuery = FirebaseDatabase()
        .reference()
        .child('class_paquete')
        .orderByChild("persona_asignada")
        .equalTo(cedula).onValue.listen((Event event) {
      setState(() {
        //_error = null;
        var dataValue = event.snapshot.value;

        if(dataValue != null){
          _deliveried = new Map<dynamic, dynamic>();
          _deliveries = new Map<dynamic, dynamic>();

          Map<dynamic, dynamic> data = dataValue;

          data.forEach((key, value) {
            print(value['estado']);
             if(value['estado'] == 'entregado'){
               _deliveried.putIfAbsent(key, () => value);
             }else{
               _deliveries.putIfAbsent(key, () => value);
             }
          });

        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),

      ),
      body:_getItems(context),

      drawer: _MyDrawer(),
    );
  }


/*  Widget _DeliveriesList() {

    return FutureBuilder(
      future: title == "Entregas Pendientes"
          ? _deliveries
          : _deliveries,
      //initialData: [],

      builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
        if(!snapshot.hasData)
          return SizedBox(height: 10,);
        else
          return ListView(
            children: _listaItems(snapshot.data.value, context),
          );
      },
    );
  }
*/
  Widget _getItems(BuildContext context){

    if(_deliveries == null || _deliveried == null) {

      return SizedBox(height: 10,);

    }else if (_deliveries != null && title == 'Entregas Pendientes' ){

      return ListView(children: _listaItems(_deliveries, context, false));

    }else if (_deliveried != null && title == 'Paquetes Entregados'){

      return ListView(children: _listaItems(_deliveried, context, true) );

    }else{
      return SizedBox(height: 10,);
    }

  }

  List<Widget> _listaItems(Map<dynamic, dynamic> data, BuildContext context, bool entregado) {
    final List<Widget> opciones = [];

    data.forEach((k,v) {
      final widgetTemp = _statusDeliveryCard(k,v['direccion_entrega'],entregado);
      print(k );
      opciones..add(widgetTemp); //..add(Divider());
    });

    return opciones;
  }

  Widget _statusDeliveryCard(String guia, String direccion, bool entregado) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Guia: ' + guia, style: TextStyle(color: Colors.grey),),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text(
              'Direccion: ' + direccion, style: TextStyle(fontSize: 20),),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              entregado ? 'entregado' : 'Marcar Como Entregado', style: TextStyle(color: Colors.grey),),
          ),
          Center(
            child: IconButton(
              icon: Icon( Icons.check_circle, color: entregado ? Colors.green :Colors.grey, size: 40,),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _ConfirmASDeliveredDialog(guia);
                    });
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _MyDrawer() {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,

        children: <Widget>[
          DrawerHeader(
            child: ListView(children: <Widget>[
              //Icon(Icons.directions_car, size: 100, color: Colors.red,),
              Image.asset('lib/src/assets/truck.png',height: 100,fit: BoxFit.fitHeight,),
              Center(
                child: Text(
                  'Entregas APP',
                  style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              Center(
                child: Text(
                  nombre,
                  style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                ),
              ),
            ]),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
          ),
          ListTile(
            title: Text('Entregas Pendientes'),
            onTap: () {
              title = 'Entregas Pendientes';
              setState(() {});
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Paquetes Entregados'),
            onTap: () {
              title = 'Paquetes Entregados';
              setState(() {});
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _ConfirmASDeliveredDialog(String guia) {
    return AlertDialog(
      title: Text('¿Desea Marcar Como Entregado?'),
      actions: <Widget>[
        FlatButton(
          child: new Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text("Aceptar"),
          onPressed: () {

            FirebaseDatabase().reference().child('class_paquete').child(guia).update({
              'estado' : 'entregado'
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()
      ..forceAndroidLocationManager;



    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        //_currentPosition = position;

        print("${position.latitude} - ${position.longitude}");
      });
    }).catchError((e) {
      print(e);
    });
  }

}
