import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:sales_app/screens/orders_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:flushbar/flushbar.dart';




class UpdateQuantityDialog extends StatefulWidget {
  final CartItem cartItem;

  UpdateQuantityDialog({this.cartItem});

  @override
  _updateQuantityDialogState createState() => _updateQuantityDialogState();
}

class _updateQuantityDialogState extends State<UpdateQuantityDialog> {
  final _form = GlobalKey<FormState>();
  TextEditingController quantityController;
  var _isInit = true;



  @override
  void initState() {
    quantityController = TextEditingController();
    quantityController.text = widget.cartItem.quantity.toString();
    super.initState();
  }

  @override
  void didChangeDependencies(){
    if(_isInit) {
      Provider.of<Cart>(context).fetchAndSetCartItems1();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);

    Map<String, dynamic> district = shippingAddress.allDistricts;
    Map<String, dynamic> areas = Map();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child:
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Container(
          child: Center(
            child: Text(
              'Update quantity',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(3.0),
                      child: Text(widget.cartItem.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.0),
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 1/3,
                          child: Text('Quantity'),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 1/3,
                            child: TextField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  // hintText: data,

                                ))
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(child: Text('Cancel'), onPressed: (){Navigator.of(context).pop(false);},),
          FlatButton(
            child: Text('Update'),
            onPressed: () async{
              await DBHelper.updateItemQuantity('cartTable', widget.cartItem.productId, double.parse(quantityController.text));
              quantityController.clear();
              if (!mounted) return;
              setState(() {
                _isInit = true;
              });
              Navigator.of(context).pop(true);},),
        ],
//      ),
      )
    );
  }

  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(

          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: Text('Select district'),
          value: shippingAddress.selectedDistrict,
          onSaved: (value){
            shippingAddress.selectedDistrict = value;
          },
          validator: (value){
            if (value == null) {
              return 'please choose district';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedDistrict = newValue;
            shippingAddress.selectedArea = null;
          },
          items: _districtMenuItems(district),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//
//                  isExpanded: true,
////                icon: Icon(Icons.location_city),
//                  hint: Text('Select district'),
//                  value: shippingAddress.selectedDistrict,
//                  onSaved: (value){
//                    shippingAddress.selectedDistrict = value;
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose district';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedDistrict = newValue;
//                    shippingAddress.selectedArea = null;
//                  },
//                  items: _districtMenuItems(district),
//                )),
//            Container(
//              padding: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.location_city,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }

  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: Text('Select area'),
          value: shippingAddress.selectedArea,
          onSaved: (value){
            shippingAddress.selectedArea = value;

          },
          validator: (value){
            if (value == null) {
              return 'please choose area';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          items: _areaMenuItems(areas),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//                  isExpanded: true,
////                icon: Icon(Icons.local_gas_station),
//                  hint: Text('Select area'),
//                  value: shippingAddress.selectedArea,
//                  onSaved: (value){
//                    shippingAddress.selectedArea = value;
//
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose area';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedArea = newValue;
//                  },
//                  items: _areaMenuItems(areas),
//                )),
//            Container(
//              margin: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.local_gas_station,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }
}

