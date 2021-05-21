import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'main.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('ESP32_Device');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: new IconButton(
            icon: Icon(Icons.reorder), onPressed: handleLoginOutPopup),
      ),
      body: StreamBuilder(
        stream: databaseReference.onValue,
           builder:  (context, snapshot){
          if(snapshot.hasData && !snapshot.hasError &&  snapshot.data.snapshot.value != null){
            print(snapshot.data.snapshot.value.toString());
            return Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Temperature: ${snapshot.data.snapshot.value["Temperature"]["Data"].toString()}", style: TextStyle(
                       fontSize: 40
                     ),),
                     Text("Humidity: ${snapshot.data.snapshot.value["Humidity"]["Data"].toString()}",style: TextStyle(
                         fontSize: 40
                     )),
                   ],
                ),
              ),
            );
          }
          else{
            return Center(child: Text("Oups, something went wrong "),);
          };}
      ),
    );
  }

  handleLoginOutPopup() {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Login Out",
      desc: "Do you want to login out now?",
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.teal,
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: handleSignOut,
          color: Colors.teal,
        )
      ],
    ).show();
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false);
  }
}