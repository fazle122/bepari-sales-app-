import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/base_state.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/auth.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/products.dart';
import 'package:sales_app/screens/auth_screen.dart';
import 'package:sales_app/screens/create_invoice_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/pending_order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/cart_item.dart';
import 'package:sales_app/widgets/confirm_invoice_dialog.dart';
import 'package:sales_app/widgets/update_quantity_dialog.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<StatefulWidget> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends BaseState<CartScreen> {
  var _isInit = true;
  var _isLoading = false;
  var updatedQuantity;
  bool isUpdateMood = false;
  List<Map<String, dynamic>> cartItemFromOrder = [];
  // double deliveryCharge;
  TextEditingController quantityController;
  TextEditingController _discountController;

  @override
  void initState() {
    quantityController = TextEditingController();
    _discountController = TextEditingController();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final orderId = ModalRoute.of(context).settings.arguments as int;
    final cart = Provider.of<Cart>(context);
    final orders = Provider.of<Orders>(context);
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      getData(cart, orders);
    }
    setState(() {
      _isLoading = false;
    });
    _isInit = false;
    super.didChangeDependencies();
  }

  getData(Cart cart,Orders orders) async{
    await Provider.of<Cart>(context).fetchAndSetCartItems1();
    if(cart.isUpdateMode) {
      for(int i = 0; i<cart.items.length; i++){
        if(cart.items[i].productId == '1'){
          orders.deliveryCharge = cart.items[i].price;
        }
      }
    }
    // else{
    //   if (cart.items.length > 0 && orders.deliveryCharge != null) {
    //     fetchDeliveryCharge(cart.totalAmount - orders.deliveryCharge);
    //   } else {
    //     fetchDeliveryCharge(cart.totalAmount);
    //   }
    // }
  }

  fetchDeliveryCharge(double totalAmount) async {
    final cart = Provider.of<Cart>(context, listen: false);
    final orders = Provider.of<Orders>(context, listen: false);
    bool isChargeApplied = cart.items.any((element) => element.productId == '1');
    if(isChargeApplied) {
      Map<String, dynamic> data = Map();
      // data.putIfAbsent('amount', () => cart.totalAmount.toDouble());
      data.putIfAbsent('amount', () => totalAmount.toDouble());
      FormData formData = FormData.fromMap(data);
      var response = await Provider.of<Orders>(context, listen: false)
          .defaultDeliveryCharge(formData);
      if (response != null) {
        setState(() {
          // deliveryCharge = response['data']['product']['unit_price'].toDouble();
          orders.deliveryCharge = response['data']['product']['unit_price'].toDouble();
        });
      }
    }
  }

  int flagType = 0;
  bool _isAmount = true;
  void handleRadioValue(int value) {
    setState(() {
      flagType = value;
      if(flagType == 0){
        _isAmount = true;
      }else{
        _isAmount = false;
      }
      print(_isAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceId = ModalRoute.of(context).settings.arguments as int;
    final cart = Provider.of<Cart>(context);
    final orders = Provider.of<Orders>(context);
    final auth = Provider.of<Auth>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(cart.isUpdateMode? 'Update cart items':'Cart items',),
          actions: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.all(10.0),
                width: 70.0,
                height: 10.0,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.grey.shade500),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Center(
                    child: Text(
                      'Add Item',
                      style:
                      TextStyle(color: Theme.of(context).primaryColorDark,fontWeight: FontWeight.bold),
                    )),
              ),
              onTap: () {
                Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Consumer<Cart>(
          builder: (context, cartData, child) => cartData.items.length > 0
              ? Column(children: <Widget>[
            cart.isUpdateMode
                ? InkWell(
              child: Chip(
                label: Text(
                  'Cancel Update',
                  style: TextStyle(
                      color: Theme.of(context)
                          .primaryTextTheme
                          .title
                          .color),
                ),
                backgroundColor:
                Theme.of(context).primaryColor,
              ),
              onTap: () async {
                await DBHelper.clearCart();
                // await cart.removeSingleItem('1');
                orders.deliveryCharge = null;
                cart.invoiceIdForUpdate = null;
                setState(() {
                  cart.isUpdateMode = false;
                  // orders.deliveryCharge = null;
                });
                Navigator.pushReplacementNamed(
                    context, PendingOrderListScreen.routeName);
              },
            )
                : SizedBox(
              width: 0.0,
              height: 0.0,
            ),
            Card(
              margin: EdgeInsets.all(15.0),
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Sub Total',
                            style: TextStyle(fontSize: 20),
                          ),
                          Spacer(),
                          Chip(
                            label: cart.items.length > 0  &&  orders.deliveryCharge == null?
                            Text(
                              '\$${(cart.totalAmount).toStringAsFixed(2)}',
                              style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                            )
                                : Text('\$${(cart.totalAmount - orders.deliveryCharge).toStringAsFixed(2)}',
                              style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                            ),
                            backgroundColor:
                            Theme.of(context).primaryColor,
                          ),
                          FlatButton(
                            textColor:
                            Theme.of(context).primaryColor,
                            child: Text('Order now'),
                            onPressed: () {
                              // await cart.
                              cart.invoiceIdForUpdate == null
                                  ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName, arguments: cart)
                              // : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: invoiceId)));
                                  : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: cart.invoiceIdForUpdate)));
                            },
                          )
                        ],
                      ),
                      Consumer<Orders>(
                          builder: (context, orderData, child) =>
                              Text(
                                cart.items.length > 0  && orderData.deliveryCharge == null
                                    ? 'Delivery Charge : 00.00 BDT'
                                    : 'Delivery Charge : ' + orderData.deliveryCharge.toString() + ' BDT',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey),
                              ))
                    ],
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding:EdgeInsets.only(top:0.0,left:10.0,right: 0.0,bottom:0.0),
              child:Column(
                children: [
                  // Row(
                  //   children: [
                  //     Text('Discount type: '),
                      Row(
                        children: <Widget>[
                          Text('Discount type: '),

                          Row(
                            children: <Widget>[
                              Radio<int>(
                                activeColor: Theme.of(context).primaryColorDark,
                                value: 0,
                                groupValue: flagType,
                                onChanged: handleRadioValue,
                              ),
                              Text('Amount',style: TextStyle(fontSize: 10.0),),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Radio<int>(
                                activeColor: Theme.of(context).primaryColorDark,
                                value: 1,
                                groupValue: flagType,
                                onChanged: handleRadioValue,
                              ),
                              Text('Percentage',style: TextStyle(fontSize: 10.0)),
                            ],
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Container(
                              width:50.0,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1.0, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                                ),
                              ),
                              child:Center(
                                  child:TextField(
                                    textAlign: TextAlign.center,
                                    controller: _discountController,
                                  )
                              )
                          )
                        ],
                      ),
                    // ],
                  // ),
                ],
              )
            ),
            Consumer<Orders>(
                builder: (context, data, child) =>
                data.deliveryCharge == null ?
                InkWell(
                  child: Chip(
                    label: Text('Add Delivery Charge',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .title
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () async {
                    if (orders.deliveryCharge == null) {
                      Map<String, dynamic> data = Map();
                      data.putIfAbsent('amount',
                              () => cartData.totalAmount.toDouble());
                      FormData formData = FormData.fromMap(data);
                      var response = await Provider.of<Orders>(context, listen: false).defaultDeliveryCharge(formData);
                      if (response != null) {
                        Map<String, dynamic> product = response['data']['product'];
                        await cart.addItem(
                            product['id'].toString(),
                            product['name'],
                            product['unit_name'],
                            product['unit_price'].toDouble(),
                            product['is_non_inventory'],
                            product['sales_accounts_group_id'].toString(),
                            product['discount'],
                            product['discount_id'].toString(),
                            product['discount_type'],
                            0.0,
                            product['vat_rate'] != null ? product['vat_rate'] : 0.0);
                      }
                    }
                    // }
                  },
                ):
                InkWell(
                  child: Chip(
                    label: Text('Remove Delivery Charge',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .title
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () async {
                    cart.removeCartItemRow('1');
                    if (!mounted) return;
                    setState(() {
                      data.deliveryCharge = null;
                      // _isInit = true;
                    });
                  },
                )
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartData.items.length,
                itemBuilder: (context, i) {
                  return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).errorColor,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        margin: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                      ),
                      confirmDismiss: (direction) {
                        return showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('Are you sure?'),
                              content: Text(
                                  'Do you want to cancel this order?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true);
                                  },
                                ),
                              ],
                            ));
                      },
                      onDismissed: (direction) async {
//                          setState(() {
//                            _isLoading = true;
//                          });
//                          await Provider.of<Orders>(context,listen: false).cancelOrder(cartData.items[i].id.toString(),'test');
                        cart.removeCartItemRow(
                            cartData.items[i].productId);
                        if (!mounted) return;
                        setState(() {
                          _isInit = true;
                        });
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            cartData.items[i].productId == '1'?
                            SizedBox(width: 0.0,height: 0.0,):
                            ListTile(
                              leading: CircleAvatar(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: FittedBox(
                                    child: Text(
                                        '\$$cartData.items[i].price'),
                                  ),
                                ),
                              ),
                              title: Text(cartData.items[i].title),
                              // subtitle: Text('Total : \$${(cart.items[i].price.toDouble() * cart.items[i].quantity)}'),
                              // subtitle: Text(cartData.items[i].orderId),
                              trailing: Container(
                                width: 130.0,
                                child: cartData.items[i].quantity !=
                                    null
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      cartData
                                          .items[i].quantity
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 20.0),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        var newQuantity = showDialog(
                                            context: context,
                                            barrierDismissible:
                                            false,
                                            builder: (context) =>

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
                                                                child: Text(cartData.items[i].title,
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold, fontSize: 13.0),
                                                                )),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              // padding: EdgeInsets.only(left: 8.0, right: 8.0),
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
                                                                            hintText: cartData.items[i].quantity.toString(),
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

                                                    FlatButton(
                                                      child: Text('Update'),
                                                      onPressed: () async{
                                                        await DBHelper.updateItemQuantity('cartTable', cartData.items[i].productId, double.parse(quantityController.text));
                                                        if (!mounted) return;
                                                        setState(() {
                                                          _isInit = true;
                                                        });
                                                        await Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
                                                        setState(() {
                                                          _isInit = false;
                                                        });
                                                        if(cart.items.length>0 && orders.deliveryCharge != null) {
                                                          await fetchDeliveryCharge(cart.totalAmount - orders.deliveryCharge);
                                                        }else{
                                                          await fetchDeliveryCharge(cart.totalAmount);
                                                        }
                                                        // Future.delayed(Duration(milliseconds: 500)).then((_) async{
                                                        //   if (!mounted) return;
                                                        //   setState(() {
                                                        //     _isInit = true;
                                                        //   });
                                                        //   var amount = await cart.totalAmount;
                                                        //
                                                        //   if(cart.items.length>0 && orders.deliveryCharge != null) {
                                                        //     await fetchDeliveryCharge(amount - orders.deliveryCharge);
                                                        //   }else{
                                                        //     await fetchDeliveryCharge(amount);
                                                        //   }
                                                        //
                                                        // } );
                                                        quantityController.clear();
                                                        Navigator.of(context).pop(true);},),
                                                    FlatButton(child: Text('Cancel'), onPressed: (){Navigator.of(context).pop(false);},),
                                                  ],
//      ),
                                                )

                                          // UpdateQuantityDialog(
                                          //     cartItem:cartData.items[i])



                                        );

                                        // cart.removeSingleItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                      Icon(Icons.delete),
                                      onPressed: () async{

                                        if(orders.deliveryCharge != null && cart.items.length == 2){
                                          // await cart.removeCartItemRow('1');
                                          await cart.clearCartTable();
                                          if (!mounted) return;
                                          setState(() {
                                            orders.deliveryCharge = null;
                                          });
                                        }else {
                                          cart.removeCartItemRow(cartData.items[i].productId);
                                        }

                                        if (!mounted) return;
                                        setState(() {
                                          _isInit = true;
                                        });
                                      },
                                    ),
                                  ],
                                )
                                    : IconButton(
                                  color: Theme.of(context)
                                      .accentColor,
                                  icon: Icon(
                                      Icons.shopping_cart),
                                  onPressed: () {
//                          cart.addItem(widget.id, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
                                  },
                                ),
                              ),
                              onTap: () {
//                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
//                            arguments: orderData.orders[i].id);
                              },
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
            cart.items.length > 0
                ? InkWell(
              child: Container(
                  height: 50.0,
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: <Widget>[
                      Container(
                          width:
                          MediaQuery.of(context).size.width * 5 / 7,
                          padding: EdgeInsets.only(left: 20.0),
                          color: Color(0xffFB0084),
                          child: Center(
                            child: Text('Total invoice amount : ' + cart.totalAmount.toStringAsFixed(2),
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                          )),
                      Container(
                        height:
                        MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 2 / 7,
                        color: Color(0xffB40060),
                        child: Center(
                          child: Text(
                            'Check out',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )),
              onTap: () {
                cart.invoiceIdForUpdate == null
                    ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName, arguments: cart)
                    : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: cart.invoiceIdForUpdate,discountType: _isAmount,discountValue: _discountController.text == null || _discountController.text == ""? 0:int.parse(_discountController.text),)));
                // _discountControlloer.clear();
                // auth.isAuth
                //     ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName,arguments: cart)
                //     : Navigator.of(context).pushNamed(AuthScreen.routeName);
              },
            )
                : SizedBox(
              width: 0.0,
              height: 0.0,
            )
          ])
              : Center(
            child: Text('no item added to cart yet!!!'),
          ),
        ));
  }
}
































// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sales_app/base_state.dart';
// import 'package:sales_app/data_helper/local_db_helper.dart';
// import 'package:sales_app/providers/auth.dart';
// import 'package:sales_app/providers/cart.dart';
// import 'package:sales_app/providers/orders.dart';
// import 'package:sales_app/providers/products.dart';
// import 'package:sales_app/screens/auth_screen.dart';
// import 'package:sales_app/screens/create_invoice_screen.dart';
// import 'package:sales_app/screens/order_list_screen.dart';
// import 'package:sales_app/screens/pending_order_list_screen.dart';
// import 'package:sales_app/screens/products_overview_screen.dart';
// import 'package:sales_app/widgets/app_drawer.dart';
// import 'package:sales_app/widgets/cart_item.dart';
// import 'package:sales_app/widgets/confirm_invoice_dialog.dart';
// import 'package:sales_app/widgets/update_quantity_dialog.dart';
//
// class CartScreen extends StatefulWidget {
//   static const routeName = '/cart';
//
//   @override
//   State<StatefulWidget> createState() {
//     return _CartScreenState();
//   }
// }
//
// class _CartScreenState extends BaseState<CartScreen> {
//   var _isInit = true;
//   var _isLoading = false;
//   var updatedQuantity;
//   bool isUpdateMood = false;
//   List<Map<String, dynamic>> cartItemFromOrder = [];
//   // double deliveryCharge;
//   TextEditingController quantityController;
//
//   @override
//   void initState() {
//     quantityController = TextEditingController();
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     final orderId = ModalRoute.of(context).settings.arguments as int;
//     final cart = Provider.of<Cart>(context);
//     final orders = Provider.of<Orders>(context);
//     if (_isInit) {
//       setState(() {
//         _isLoading = true;
//       });
//       getData(cart, orders);
//     }
//     setState(() {
//       _isLoading = false;
//     });
//     _isInit = false;
//     super.didChangeDependencies();
//   }
//
//   getData(Cart cart,Orders orders) async{
//     await Provider.of<Cart>(context).fetchAndSetCartItems1();
//     if(cart.isUpdateMode) {
//       for(int i = 0; i<cart.items.length; i++){
//         if(cart.items[i].productId == '1'){
//           orders.deliveryCharge = cart.items[i].price;
//         }
//       }
//     }
//     // else{
//     //   if (cart.items.length > 0 && orders.deliveryCharge != null) {
//     //     fetchDeliveryCharge(cart.totalAmount - orders.deliveryCharge);
//     //   } else {
//     //     fetchDeliveryCharge(cart.totalAmount);
//     //   }
//     // }
//   }
//
//   fetchDeliveryCharge(double totalAmount) async {
//     final cart = Provider.of<Cart>(context, listen: false);
//     final orders = Provider.of<Orders>(context, listen: false);
//       bool isChargeApplied = cart.items.any((element) => element.productId == '1');
//       if(isChargeApplied) {
//         Map<String, dynamic> data = Map();
//         // data.putIfAbsent('amount', () => cart.totalAmount.toDouble());
//         data.putIfAbsent('amount', () => totalAmount.toDouble());
//         FormData formData = FormData.fromMap(data);
//         var response = await Provider.of<Orders>(context, listen: false)
//             .defaultDeliveryCharge(formData);
//         if (response != null) {
//           setState(() {
//             // deliveryCharge = response['data']['product']['unit_price'].toDouble();
//             orders.deliveryCharge = response['data']['product']['unit_price'].toDouble();
//           });
//         }
//       }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final invoiceId = ModalRoute.of(context).settings.arguments as int;
//     final cart = Provider.of<Cart>(context);
//     final orders = Provider.of<Orders>(context);
//     final auth = Provider.of<Auth>(context);
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(cart.isUpdateMode? 'Update cart items':'Cart items',),
//           actions: <Widget>[
//             InkWell(
//               child: Container(
//                 margin: EdgeInsets.all(10.0),
//                 width: 70.0,
//                 height: 10.0,
//                 decoration: ShapeDecoration(
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.grey.shade500),
//                     borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                   ),
//                 ),
//                 child: Center(
//                     child: Text(
//                       'Add Item',
//                       style:
//                       TextStyle(color: Theme.of(context).primaryColorDark,fontWeight: FontWeight.bold),
//                     )),
//               ),
//               onTap: () {
//                 Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
//               },
//             ),
//           ],
//         ),
//         drawer: AppDrawer(),
//         body: _isLoading
//             ? Center(
//                 child: CircularProgressIndicator(),
//               )
//             : Consumer<Cart>(
//                 builder: (context, cartData, child) => cartData.items.length > 0
//                     ? Column(children: <Widget>[
//                         cart.isUpdateMode
//                             ? InkWell(
//                                 child: Chip(
//                                   label: Text(
//                                     'Cancel Update',
//                                     style: TextStyle(
//                                         color: Theme.of(context)
//                                             .primaryTextTheme
//                                             .title
//                                             .color),
//                                   ),
//                                   backgroundColor:
//                                       Theme.of(context).primaryColor,
//                                 ),
//                                 onTap: () async {
//                                   await DBHelper.clearCart();
//                                   // await cart.removeSingleItem('1');
//                                   orders.deliveryCharge = null;
//                                   cart.invoiceIdForUpdate = null;
//                                       setState(() {
//                                     cart.isUpdateMode = false;
//                                     // orders.deliveryCharge = null;
//                                   });
//                                   Navigator.pushReplacementNamed(
//                                       context, PendingOrderListScreen.routeName);
//                                 },
//                               )
//                             : SizedBox(
//                                 width: 0.0,
//                                 height: 0.0,
//                               ),
//                         Card(
//                           margin: EdgeInsets.all(15.0),
//                           child: Padding(
//                               padding: EdgeInsets.all(8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text(
//                                         'Sub Total',
//                                         style: TextStyle(fontSize: 20),
//                                       ),
//                                       Spacer(),
//                                       Chip(
//                                         label: cart.items.length > 0  &&  orders.deliveryCharge == null?
//                                             Text(
//                                                 '\$${(cart.totalAmount).toStringAsFixed(2)}',
//                                                 style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
//                                               )
//                                             : Text('\$${(cart.totalAmount - orders.deliveryCharge).toStringAsFixed(2)}',
//                                                 style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
//                                               ),
//                                         backgroundColor:
//                                             Theme.of(context).primaryColor,
//                                       ),
//                                       FlatButton(
//                                         textColor:
//                                             Theme.of(context).primaryColor,
//                                         child: Text('Order now'),
//                                         onPressed: () {
//                                           // await cart.
//                                           cart.invoiceIdForUpdate == null
//                                               ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName, arguments: cart)
//                                               // : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: invoiceId)));
//                                           : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: cart.invoiceIdForUpdate)));
//                                         },
//                                       )
//                                     ],
//                                   ),
//                                   Consumer<Orders>(
//                                       builder: (context, orderData, child) =>
//                                           Text(
//                                             cart.items.length > 0  && orderData.deliveryCharge == null
//                                                 ? 'Delivery Charge : 00.00 BDT'
//                                                 : 'Delivery Charge : ' + orderData.deliveryCharge.toString() + ' BDT',
//                                             style: TextStyle(
//                                                 fontSize: 14.0,
//                                                 color: Colors.grey),
//                                           ))
//                                 ],
//                               )),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Consumer<Orders>(
//                         builder: (context, data, child) =>
//                           data.deliveryCharge == null ?
//                           InkWell(
//                             child: Chip(
//                               label: Text('Add Delivery Charge',
//                                 style: TextStyle(
//                                     color: Theme.of(context)
//                                         .primaryTextTheme
//                                         .title
//                                         .color),
//                               ),
//                               backgroundColor: Theme.of(context).primaryColor,
//                             ),
//                             onTap: () async {
//                               if (orders.deliveryCharge == null) {
//                                 Map<String, dynamic> data = Map();
//                                 data.putIfAbsent('amount',
//                                     () => cartData.totalAmount.toDouble());
//                                 FormData formData = FormData.fromMap(data);
//                                 var response = await Provider.of<Orders>(context, listen: false).defaultDeliveryCharge(formData);
//                                 if (response != null) {
//                                   Map<String, dynamic> product = response['data']['product'];
//                                   await cart.addItem(
//                                       product['id'].toString(),
//                                       product['name'],
//                                       product['unit_name'],
//                                       product['unit_price'].toDouble(),
//                                       product['is_non_inventory'],
//                                       product['sales_accounts_group_id'].toString(),
//                                       product['discount'],
//                                       product['discount_id'].toString(),
//                                       product['discount_type'],
//                                       0.0,
//                                       product['vat_rate'] != null ? product['vat_rate'] : 0.0);
//                                 }
//                               }
//                               // }
//                             },
//                           ):
//                           InkWell(
//                             child: Chip(
//                               label: Text('Remove Delivery Charge',
//                                 style: TextStyle(
//                                     color: Theme.of(context)
//                                         .primaryTextTheme
//                                         .title
//                                         .color),
//                               ),
//                               backgroundColor: Theme.of(context).primaryColor,
//                             ),
//                             onTap: () async {
//                                 cart.removeCartItemRow('1');
//                                 if (!mounted) return;
//                                 setState(() {
//                                   data.deliveryCharge = null;
//                                   // _isInit = true;
//                                 });
//                             },
//                           )
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: cartData.items.length,
//                             itemBuilder: (context, i) {
//                               return Dismissible(
//                                   key: UniqueKey(),
//                                   direction: DismissDirection.endToStart,
//                                   background: Container(
//                                     color: Theme.of(context).errorColor,
//                                     child: Icon(
//                                       Icons.delete,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                     alignment: Alignment.centerRight,
//                                     padding: EdgeInsets.only(right: 20),
//                                     margin: EdgeInsets.symmetric(
//                                         horizontal: 15, vertical: 4),
//                                   ),
//                                   confirmDismiss: (direction) {
//                                     return showDialog(
//                                         context: context,
//                                         barrierDismissible: false,
//                                         builder: (context) => AlertDialog(
//                                               title: Text('Are you sure?'),
//                                               content: Text(
//                                                   'Do you want to cancel this order?'),
//                                               actions: <Widget>[
//                                                 FlatButton(
//                                                   child: Text('No'),
//                                                   onPressed: () {
//                                                     Navigator.of(context)
//                                                         .pop(false);
//                                                   },
//                                                 ),
//                                                 FlatButton(
//                                                   child: Text('Yes'),
//                                                   onPressed: () {
//                                                     Navigator.of(context)
//                                                         .pop(true);
//                                                   },
//                                                 ),
//                                               ],
//                                             ));
//                                   },
//                                   onDismissed: (direction) async {
// //                          setState(() {
// //                            _isLoading = true;
// //                          });
// //                          await Provider.of<Orders>(context,listen: false).cancelOrder(cartData.items[i].id.toString(),'test');
//                                     cart.removeCartItemRow(
//                                         cartData.items[i].productId);
//                                     if (!mounted) return;
//                                     setState(() {
//                                       _isInit = true;
//                                     });
//                                   },
//                                   child: Card(
//                                     margin: EdgeInsets.all(10),
//                                     child: Column(
//                                       children: <Widget>[
//                                         cartData.items[i].productId == '1'?
//                                         SizedBox(width: 0.0,height: 0.0,):
//                                         ListTile(
//                                           leading: CircleAvatar(
//                                             child: Padding(
//                                               padding: EdgeInsets.all(5),
//                                               child: FittedBox(
//                                                 child: Text(
//                                                     '\$$cartData.items[i].price'),
//                                               ),
//                                             ),
//                                           ),
//                                           title: Text(cartData.items[i].title),
//                                           // subtitle: Text('Total : \$${(cart.items[i].price.toDouble() * cart.items[i].quantity)}'),
//                                           // subtitle: Text(cartData.items[i].orderId),
//                                           trailing: Container(
//                                             width: 130.0,
//                                             child: cartData.items[i].quantity !=
//                                                     null
//                                                 ? Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.end,
//                                                     children: <Widget>[
//                                                       Text(
//                                                         cartData
//                                                             .items[i].quantity
//                                                             .toString(),
//                                                         style: TextStyle(
//                                                             fontSize: 20.0),
//                                                       ),
//                                                       IconButton(
//                                                         icon: Icon(Icons.edit),
//                                                         onPressed: () {
//                                                           var newQuantity = showDialog(
//                                                               context: context,
//                                                               barrierDismissible:
//                                                                   false,
//                                                               builder: (context) =>
//
//                                                                   AlertDialog(
//                                                                     shape: RoundedRectangleBorder(
//                                                                         borderRadius: BorderRadius.all(Radius.circular(5.0))),
//                                                                     title: Container(
//                                                                       child: Center(
//                                                                         child: Text(
//                                                                           'Update quantity',
//                                                                           style: TextStyle(fontSize: 20.0),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     content: Container(
//                                                                       child: Column(
//                                                                         mainAxisSize: MainAxisSize.min,
//                                                                         children: <Widget>[
//                                                                           Column(
//                                                                             mainAxisSize: MainAxisSize.min,
//                                                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                                                             children: <Widget>[
//                                                                               Container(
//                                                                                   margin: EdgeInsets.all(3.0),
//                                                                                   child: Text(cartData.items[i].title,
//                                                                                     style: TextStyle(
//                                                                                         fontWeight: FontWeight.bold, fontSize: 13.0),
//                                                                                   )),
//                                                                               Container(
//                                                                                 width: MediaQuery.of(context).size.width,
//                                                                                 // padding: EdgeInsets.only(left: 8.0, right: 8.0),
//                                                                                 child: Row(
//                                                                                   mainAxisSize: MainAxisSize.min,
//                                                                                   children: <Widget>[
//                                                                                     Container(
//                                                                                       width: MediaQuery.of(context).size.width * 1/3,
//                                                                                       child: Text('Quantity'),
//                                                                                     ),
//                                                                                     Container(
//                                                                                         width: MediaQuery.of(context).size.width * 1/3,
//                                                                                         child: TextField(
//                                                                                             controller: quantityController,
//                                                                                             keyboardType: TextInputType.number,
//                                                                                             decoration: InputDecoration(
//                                                                                               hintText: cartData.items[i].quantity.toString(),
//                                                                                               contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                                                                                               // hintText: data,
//
//                                                                                             ))
//                                                                                     )
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                     actions: <Widget>[
//
//                                                                       FlatButton(
//                                                                         child: Text('Update'),
//                                                                         onPressed: () async{
//                                                                           await DBHelper.updateItemQuantity('cartTable', cartData.items[i].productId, double.parse(quantityController.text));
//                                                                           if (!mounted) return;
//                                                                           setState(() {
//                                                                             _isInit = true;
//                                                                           });
//                                                                           await Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
//                                                                           setState(() {
//                                                                             _isInit = false;
//                                                                           });
//                                                                             if(cart.items.length>0 && orders.deliveryCharge != null) {
//                                                                               await fetchDeliveryCharge(cart.totalAmount - orders.deliveryCharge);
//                                                                             }else{
//                                                                               await fetchDeliveryCharge(cart.totalAmount);
//                                                                             }
//                                                                           // Future.delayed(Duration(milliseconds: 500)).then((_) async{
//                                                                           //   if (!mounted) return;
//                                                                           //   setState(() {
//                                                                           //     _isInit = true;
//                                                                           //   });
//                                                                           //   var amount = await cart.totalAmount;
//                                                                           //
//                                                                           //   if(cart.items.length>0 && orders.deliveryCharge != null) {
//                                                                           //     await fetchDeliveryCharge(amount - orders.deliveryCharge);
//                                                                           //   }else{
//                                                                           //     await fetchDeliveryCharge(amount);
//                                                                           //   }
//                                                                           //
//                                                                           // } );
//                                                                           quantityController.clear();
//                                                                           Navigator.of(context).pop(true);},),
//                                                                       FlatButton(child: Text('Cancel'), onPressed: (){Navigator.of(context).pop(false);},),
//                                                                     ],
// //      ),
//                                                                   )
//
//                                                                   // UpdateQuantityDialog(
//                                                                   //     cartItem:cartData.items[i])
//
//
//
//                                                           );
//
//                                                           // cart.removeSingleItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
//                                                         },
//                                                       ),
//                                                       IconButton(
//                                                         icon:
//                                                             Icon(Icons.delete),
//                                                         onPressed: () async{
//
//                                                           if(orders.deliveryCharge != null && cart.items.length == 2){
//                                                             // await cart.removeCartItemRow('1');
//                                                             await cart.clearCartTable();
//                                                             if (!mounted) return;
//                                                             setState(() {
//                                                               orders.deliveryCharge = null;
//                                                             });
//                                                           }else {
//                                                             cart.removeCartItemRow(cartData.items[i].productId);
//                                                           }
//
//                                                           if (!mounted) return;
//                                                           setState(() {
//                                                             _isInit = true;
//                                                           });
//                                                         },
//                                                       ),
//                                                     ],
//                                                   )
//                                                 : IconButton(
//                                                     color: Theme.of(context)
//                                                         .accentColor,
//                                                     icon: Icon(
//                                                         Icons.shopping_cart),
//                                                     onPressed: () {
// //                          cart.addItem(widget.id, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
//                                                     },
//                                                   ),
//                                           ),
//                                           onTap: () {
// //                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
// //                            arguments: orderData.orders[i].id);
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ));
//                             },
//                           ),
//                         ),
//                         cart.items.length > 0
//                             ? InkWell(
//                           child: Container(
//                               height: 50.0,
//                               color: Theme.of(context).primaryColor,
//                               child: Row(
//                                 children: <Widget>[
//                                   Container(
//                                       width:
//                                       MediaQuery.of(context).size.width * 5 / 7,
//                                       padding: EdgeInsets.only(left: 20.0),
//                                       color: Color(0xffFB0084),
//                                       child: Center(
//                                         child: Text('Total invoice amount : ' + cart.totalAmount.toStringAsFixed(2),
//                                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
//                                       )),
//                                   Container(
//                                     height:
//                                     MediaQuery.of(context).size.height,
//                                     width: MediaQuery.of(context).size.width * 2 / 7,
//                                     color: Color(0xffB40060),
//                                     child: Center(
//                                         child: Text(
//                                           'Check out',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                   ),
//                                 ],
//                               )),
//                           onTap: () {
//                             cart.invoiceIdForUpdate == null
//                                 ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName, arguments: cart)
//                                 : Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOrderScreen(cart: cart, invoiceId: cart.invoiceIdForUpdate)));
//                             // auth.isAuth
//                             //     ? Navigator.of(context).pushNamed(CreateOrderScreen.routeName,arguments: cart)
//                             //     : Navigator.of(context).pushNamed(AuthScreen.routeName);
//                           },
//                         )
//                             : SizedBox(
//                                 width: 0.0,
//                                 height: 0.0,
//                               )
//                       ])
//                     : Center(
//                         child: Text('no item added to cart yet!!!'),
//                       ),
//               ));
//   }
// }
