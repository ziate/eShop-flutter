import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop/Home.dart';
import 'package:flutter/services.dart';

class ForgotPassWord extends StatefulWidget {


  @override
  _ForgetPassPageState createState() => new _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgotPassWord> {
  final dataKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 150.0),
                child: Center(
                  child:
                      new Image.asset('assets/images/sublogo.png', width: 200),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 120.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.only(
                              top: 70.0, left: 20.0, right: 20.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: new Text(
                              "Forgot Password",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                      Container(
                        padding:
                            EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
                        child: Center(
                          child: TextField(
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                hintText: 'Mobile number or Email',
                                contentPadding:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            bottom: 80, left: 20.0, right: 20.0, top: 50.0),
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.lightBlue, Colors.blue],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: width * 0.90, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Get Password",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
