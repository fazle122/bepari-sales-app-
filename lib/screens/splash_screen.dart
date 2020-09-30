import 'package:sales_app/providers/auth.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

//  @override
//  void initState() {
//    super.initState();
//    Future.delayed(Duration(seconds: 2), () {
//      Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
//    });
//  }
//
//  @override
//  void didChangeDependencies() {
//    Provider.of<Auth>(context).tryAutoLogin();
//    super.didChangeDependencies();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bepari',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
    );
  }
}
