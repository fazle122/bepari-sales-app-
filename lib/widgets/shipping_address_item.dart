import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/shipping_address.dart';


class ShippingAddressItemWidget extends StatefulWidget {
  final AddressItem address;

  ShippingAddressItemWidget(this.address);

  @override
  _ShippingAddressItemState createState() => _ShippingAddressItemState();
}

class _ShippingAddressItemState extends State<ShippingAddressItemWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(widget.address.shippingAddress),
            subtitle: Text(widget.address.phoneNumber),
          ),

        ],
      ),
    );
  }
}
