import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/auth.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/products.dart';
import 'package:sales_app/providers/profile.dart';
import 'package:sales_app/providers/shipping_address.dart';
import 'package:sales_app/screens/auth_screen.dart';
import 'package:sales_app/screens/cart_screen.dart';
import 'package:sales_app/screens/due_orders_screen.dart';
import 'package:sales_app/screens/order_detail_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/order_update_screen.dart';
import 'package:sales_app/screens/pending_order_list_screen.dart';
import 'package:sales_app/screens/product_detail_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/screens/create_invoice_screen.dart';
import 'package:sales_app/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),

          ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previousOrders) => Products(
              auth.token,
              auth.userId,
            ),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            ),
          ),
          ChangeNotifierProxyProvider<Auth, ShippingAddress>(
            update: (ctx, auth, previousAddress) => ShippingAddress(
              auth.token,
              auth.userId,
              previousAddress == null ? [] : previousAddress.allShippingAddress,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bepari',
            theme: ThemeData(
                primarySwatch: Colors.teal, accentColor: Colors.blueGrey),
            home: auth.isAuth
                ? PendingOrderListScreen()
                : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
              authResultSnapshot.connectionState ==
                  ConnectionState.waiting
                  ? SplashScreen()
                  : AuthScreen(),
            ),
//            home: SplashScreen(),
            routes: {
              AuthScreen.routeName: (context) => AuthScreen(),
              ProductsOverviewScreen.routeName: (context) => ProductsOverviewScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              // OrderListScreen.routeName: (context) => OrderListScreen(),
              PendingOrderListScreen.routeName: (context) => PendingOrderListScreen(),
              DueOrderListScreen.routeName: (context) => DueOrderListScreen(),
              OrderDetailScreen.routeName:(context) => OrderDetailScreen(),
              // OrderUpdateScreen.routeName:(context) => OrderUpdateScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              CreateOrderScreen.routeName: (context) => CreateOrderScreen(),


            },
          ),
        ));
  }
}


