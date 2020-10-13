import 'dart:convert';

import 'package:sales_app/providers/auth.dart';
import 'package:sales_app/screens/auth_screen.dart';
import 'package:sales_app/screens/due_orders_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/pending_order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  PageStorageKey _key;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
              height: 140.0,
              width: MediaQuery.of(context).size.width,
              child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        top: 20.0,
                        left: 30.0,
                        child: Column(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 30.0,
//                  backgroundImage: NetworkImage(),
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            auth.userId != null
                                ? Text(auth.userId)
                                : Text('Guest User'),
                          ],
                        )),
                    auth.token == null
                        ? Positioned(
                            top: 20.0,
                            right: 30.0,
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.exit_to_app,
                                    color: Colors.white,
                                    size: 25.0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(AuthScreen.routeName);
                                  },
                                ),
//                    SizedBox(height: 5.0,),
                                Text(
                                  'Login',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                              ],
                            ))
                        : SizedBox(
                            width: 0.0,
                            height: 0.0,
                          ),
                  ]))),
//          AppBar(title: Text('Hello'),automaticallyImplyLeading: false,),
          Divider(),
          Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('New order'),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(ProductsOverviewScreen.routeName);
                },
              )
            ],
          ),
          Divider(),
          Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Orders'),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(PendingOrderListScreen.routeName);
                },
              )
            ],
          ),
          Divider(),

          Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Due orders'),
                onTap: () async {
                  Navigator.of(context)
                      .pushReplacementNamed(DueOrderListScreen.routeName);
                },
              )
            ],
          ),
          Divider(),

          Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.power_settings_new),
                title: Text('Logout'),
                onTap: () async {
                  await Provider.of<Auth>(context, listen: false).logout();
                  final auth = Provider.of<Auth>(context, listen: false);
//                  auth.otp = null;
                  Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
