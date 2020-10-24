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
              await fetchDeliveryCharge();
              quantityController.clear();
              if (!mounted) return;
              setState(() {
                _isInit = true;
              });
              await Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
              setState(() {
                _isInit = false;
              });
              Navigator.of(context).pop(true);},),
        ],
//      ),
      )
    );
  }

  double deliveryCharge;
  fetchDeliveryCharge() async {
    final cart = Provider.of<Cart>(context, listen: false);
    final orders = Provider.of<Orders>(context, listen: false);
    bool isChargeApplied = cart.items.any((element) => element.productId == '1');
    if(isChargeApplied) {
      Map<String, dynamic> data = Map();
      data.putIfAbsent('amount', () => cart.totalAmount.toDouble());
      FormData formData = FormData.fromMap(data);
      var response = await Provider.of<Orders>(context, listen: false)
          .defaultDeliveryCharge(formData);
      if (response != null) {
        setState(() {
          deliveryCharge = response['data']['product']['unit_price'].toDouble();
          orders.deliveryCharge = response['data']['product']['unit_price'].toDouble();
        });
      }
    }
  }

}

