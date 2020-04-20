import 'package:entregas_app/src/Routes/Routes.dart';
import 'package:entregas_app/src/Routes/delivery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        primaryColor: Color(0xFFD50000),
        primaryColorDark: Color(0xFF9B0000),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'login',
      routes: getApplicationsRoutes(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  final cedulaFormFielController = TextEditingController();
  final passwordFormFieldController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF9B0000), //or set color with: Color(0xFF0000FF)
    ));

    _sendToServer() {

      var ref =  FirebaseDatabase().reference().child('class_persona').orderByChild('password').equalTo( passwordFormFieldController.text);

      try{
        ref.once().then( (snapshot) {
            if(snapshot.value != null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  DeliveryPage(cedula: cedulaFormFielController.text)));

              Fluttertoast.showToast(
                  msg: "Login Exitoso",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            }else
              Fluttertoast.showToast(
                  msg: "Error de usuario o contraseña",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

        });
      }catch(e){
        Fluttertoast.showToast(
            msg: "Error de usuario o contraseña",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }

      //Navigator.pushNamed(context,'entregas',arguments: ceedulaFormFielController.text);

    }

    return Scaffold(


      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(

              children: <Widget>[
                //Icon(Icons.directions_car,size: 200,color: Colors.red,),
                Image.asset('lib/src/assets/truck.png',height: 200,fit: BoxFit.fitHeight,),
                Text("Entregas APP Login",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                SizedBox(height: 10),
                TextFormField(
                  controller: cedulaFormFielController,
                  decoration: InputDecoration(
                    hintText: "Cedula",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),),
                  validator: (input){},
                  onSaved: (input){},),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordFormFieldController,
                  autofocus: false,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Contraseña",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        semanticLabel:
                        _obscureText ? 'show password' : 'hide password',
                      ),
                    ),

                  ),
                  validator: (input){},
                  onSaved: (input){},),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: _sendToServer,
                    padding: EdgeInsets.all(12),
                    color: Colors.grey,
                    child: Text('Log In', style: TextStyle(color: Colors.white)),
                  ),
                ),

              ],),
          ),
        ),
      ),
    );
  }
}
