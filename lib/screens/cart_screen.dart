import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/base_state.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/auth.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/auth_screen.dart';
import 'package:sales_app/screens/create_order_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/cart_item.dart';
import 'package:sales_app/widgets/confirm_order_dialog.dart';
import 'package:sales_app/widgets/update_quantity_dialog.dart';



class CartScreen extends StatefulWidget {
  static const routeName = '/cart';


  @override
  State<StatefulWidget> createState() {
    return _CartScreenState();
  }

}

class _CartScreenState extends BaseState<CartScreen>{

  var _isInit = true;
  var _isLoading = false;
  var updatedQuantity;
  bool isUpdateMood = false;
  List<Map<String,dynamic>> cartItemFromOrder = [];




  @override
  void didChangeDependencies(){
    final orderId = ModalRoute.of(context).settings.arguments as int;
    final cart = Provider.of<Cart>(context,listen:false);
    if(orderId == null){
      if(_isInit) {
        Provider.of<Cart>(context).fetchAndSetCartItems1();
      }
      _isInit = false;
    }else{
      setState(() {
        cart.isUpdateMode = true;
      });
      fetchCartFromOrder(orderId);
    }
    super.didChangeDependencies();
  }


  fetchCartFromOrder(var orderId) async{
    print(orderId);
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context,listen:false).fetchOrderForCart(orderId).then((data) {

        setState(() {
          cartItemFromOrder = data;
        });
        cartItemFromOrder.map((cartData) async{
          await DBHelper.clearCart();
          await DBHelper.createCartFromOrder(CartItem.fromJson(cartData));
        }).toList();
      });
    }
    Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
    setState(() {
      _isLoading = false;
      _isInit = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your cart'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body:
       _isLoading?
       Center(child: CircularProgressIndicator(),)
           :
        Consumer<Cart>(builder: (context,cartData,child) =>
        cartData.items.length >0 ?
        Column(
            children: <Widget>[
              cart.isUpdateMode?InkWell(
                child: Chip(
                  label:
                  Text('Cancel Update',
                    style: TextStyle(
                        color:
                        Theme.of(context).primaryTextTheme.title.color),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onTap: () async{
                  await DBHelper.clearCart();
                  setState(() {
                    cart.isUpdateMode = false;
                  });
                  Navigator.pushReplacementNamed(context, OrderListScreen.routeName);

                },
              ):SizedBox(width: 0.0,height: 0.0,),
              Card(
                margin: EdgeInsets.all(15.0),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      Chip(
                        label: cart.totalAmount<500 && cart.items.length >0 ?
//                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
                        Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
                          style: TextStyle(
                              color:
                              Theme.of(context).primaryTextTheme.title.color),
                        ) :
                        Text('\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color:
                              Theme.of(context).primaryTextTheme.title.color),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        child: Text('Order now'),
                        onPressed: () {
                          auth.isAuth?
                          Navigator.of(context).pushNamed(CreateOrderScreen.routeName,arguments: cart)
                              :Navigator.of(context).pushNamed(AuthScreen.routeName);
//                      showDialog(
//                          context: context,
//                          child: _confirmOrderDialog(context, cart)
////                          child: ConfirmOrderDialog()
//                      );
//                      Provider.of<Orders>(context, listen: false).addOrder(
//                          cart.items.values.toList(), cart.totalAmount);
//                      cart.clear();
                        },
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cartData.items.length,
                  itemBuilder: (context,i){
                    return Dismissible(
                        key:UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).errorColor,
                          child: Icon(Icons.delete,color: Colors.white,size: 40,),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        ),
                        confirmDismiss: (direction){
                          return   showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text('Do you want to cancel this order?'),
                                actions: <Widget>[
                                  FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
                                  FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);},),
                                ],
                              )
                          );
                        },
                        onDismissed: (direction) async{
//                          setState(() {
//                            _isLoading = true;
//                          });
//                          await Provider.of<Orders>(context,listen: false).cancelOrder(cartData.items[i].id.toString(),'test');
                          cart.removeCartItemRow(cartData.items[i].productId);
                          if (!mounted) return;
                          setState(() {
                            _isInit = true;
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: FittedBox(
                                      child: Text('\$$cartData.items[i].price'),
                                    ),
                                  ),
                                ),
                                title: Text(cartData.items[i].title),
                                // subtitle: Text('Total : \$${(cart.items[i].price.toDouble() * cart.items[i].quantity)}'),
                                // subtitle: Text(cartData.items[i].orderId),
                                trailing: Container(
                                  width: 130.0,
                                  child: cartData.items[i].quantity != null ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      // IconButton(
                                      //   icon: Icon(Icons.add),
                                      //   onPressed: (){
                                      //     cart.addItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                      //     Scaffold.of(context).hideCurrentSnackBar();
                                      //     if(cart.items.length> 0)
                                      //       Scaffold.of(context).showSnackBar(SnackBar(
                                      //         backgroundColor: cart.totalAmount > 500
                                      //             ? Theme.of(context).primaryColor
                                      //             : Colors.red[300],
                                      //         content: cart.totalAmount > 500
                                      //             ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                                      //             child:Text('Delievry charge free'))
                                      //             : Row(
                                      //           children: <Widget>[
                                      //             Container(
                                      //                 decoration: BoxDecoration(
                                      //                     border: Border(
                                      //                         right: BorderSide(
                                      //                             color: Colors.white,
                                      //                             width: 1.0))),
                                      //                 width:
                                      //                 MediaQuery.of(context).size.width *
                                      //                     1 /
                                      //                     7,
                                      //                 child:
                                      //                 Text('Delivery charge \n50 BDT')),
                                      //             SizedBox(
                                      //               width: 5.0,
                                      //             ),
                                      //             Container(
                                      //               width: MediaQuery.of(context).size.width *
                                      //                   4 /
                                      //                   7,
                                      //               child: Text(
                                      //                   'Shop more for free delivery charge.'),
                                      //             )
                                      //           ],
                                      //         ),
                                      //         duration: Duration(seconds: 2),
                                      //       ));
                                      //   },
                                      // ),
                                      Text(cartData.items[i].quantity.toString(),style: TextStyle(fontSize: 20.0),),
                                      // IconButton(
                                      //   icon: Icon(Icons.remove),
                                      //   onPressed: (){
                                      //     cart.removeSingleItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                      //     Scaffold.of(context).hideCurrentSnackBar();
                                      //     if(cart.items.length> 0)
                                      //       Scaffold.of(context).showSnackBar(SnackBar(
                                      //         backgroundColor: cart.totalAmount > 500
                                      //             ? Theme.of(context).primaryColor
                                      //             : Colors.red[300],
                                      //         content: cart.totalAmount > 500
                                      //             ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                                      //             child:Text('Delievry charge free'))
                                      //             : Row(
                                      //           children: <Widget>[
                                      //             Container(
                                      //                 decoration: BoxDecoration(
                                      //                     border: Border(
                                      //                         right: BorderSide(
                                      //                             color: Colors.white,
                                      //                             width: 1.0))),
                                      //                 width:
                                      //                 MediaQuery.of(context).size.width *
                                      //                     1 /
                                      //                     7,
                                      //                 child:
                                      //                 Text('Delivery charge \n50 BDT')),
                                      //             SizedBox(
                                      //               width: 5.0,
                                      //             ),
                                      //             Container(
                                      //               width: MediaQuery.of(context).size.width *
                                      //                   4 /
                                      //                   7,
                                      //               child: Text(
                                      //                   'Shop more for free delivery charge.'),
                                      //             )
                                      //           ],
                                      //         ),
                                      //         duration: Duration(seconds: 2),
                                      //       ));
                                      //   },
                                      // ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: (){
                                         var newQuantity =   showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) =>
                                              UpdateQuantityDialog(cartItem:cartData.items[i])
                                          );

                                          // cart.removeSingleItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: (){
                                          cart.removeCartItemRow(cartData.items[i].productId);
                                          if (!mounted) return;
                                          setState(() {
                                            _isInit = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ):IconButton(
                                    color: Theme.of(context).accentColor,
                                    icon: Icon(Icons.shopping_cart),
                                    onPressed: () {
//                          cart.addItem(widget.id, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
                                    },
                                  ),
                                ),
                                onTap: (){
//                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
//                            arguments: orderData.orders[i].id);
                                },
                              ),
                            ],
                          ),
                        )
                    );
                  },
                ),
              ),
              cart.items.length > 0
                  ? Container(
                  height: 50.0,
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 5 / 7,
                          padding: EdgeInsets.only(left: 20.0),
                          color: Theme.of(context).primaryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('SubTotal: ' +
                                  cart.totalAmount.toStringAsFixed(2)),
                              cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
                              cart.totalAmount>500 ?
                              Text(
                                'Total amount : ' +
                                    cart.totalAmount.toStringAsFixed(2),
                                style: TextStyle(color: Colors.white),
                              )
                                  :Text(
                                'Total amount : ' +
                                    (cart.totalAmount + 50.00).toStringAsFixed(2),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 2 / 7,
                        color: Theme.of(context).primaryColorDark,
                        child: InkWell(
                          child: Center(
                            child: Text(
                              'Check out',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            auth.isAuth?
                            Navigator.of(context).pushNamed(CreateOrderScreen.routeName,arguments: cart)
                                :Navigator.of(context).pushNamed(AuthScreen.routeName);
//                            showDialog(
//                                context: context,
//                                child: _confirmOrderDialog(context, cart)
////                                child: ConfirmOrderDialog()
//                            );
                          },
                        ),
                      ),
                    ],
                  ))
                  : SizedBox(
                width: 0.0,
                height: 0.0,
              )
            ]
        )

            :Center(child: Text('no item added to cart yet!!!'),),
        )
    );
  }
}







//class CartScreen extends StatelessWidget {
//  static const routeName = '/cart';
//
//  @override
//  Widget build(BuildContext context) {
//    final cart = Provider.of<Cart>(context);
//    final auth = Provider.of<Auth>(context);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Your cart'),
//      ),
//      body: Column(
//        children: <Widget>[
//          Card(
//            margin: EdgeInsets.all(15.0),
//            child: Padding(
//              padding: EdgeInsets.all(8),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Text(
//                    'Total',
//                    style: TextStyle(fontSize: 20),
//                  ),
//                  Spacer(),
//                  Chip(
//                    label: cart.totalAmount<500 && cart.items.length >0 ?
////                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
//                        Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                          Theme.of(context).primaryTextTheme.title.color),
//                    ) :
//                    Text('\$${cart.totalAmount.toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                              Theme.of(context).primaryTextTheme.title.color),
//                    ),
//                    backgroundColor: Theme.of(context).primaryColor,
//                  ),
//                  FlatButton(
//                    textColor: Theme.of(context).primaryColor,
//                    child: Text('Order now'),
//                    onPressed: () {
//                      auth.isAuth?
//                      Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                      :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                      showDialog(
////                          context: context,
////                          child: _confirmOrderDialog(context, cart)
//////                          child: ConfirmOrderDialog()
////                      );
////                      Provider.of<Orders>(context, listen: false).addOrder(
////                          cart.items.values.toList(), cart.totalAmount);
////                      cart.clear();
//                    },
//                  )
//                ],
//              ),
//            ),
//          ),
//          SizedBox(
//            height: 10,
//          ),
//          Expanded(
//              child: ListView.builder(
//            itemCount: cart.itemCount,
//            itemBuilder: (context, i) => CartItemWidget(
//              cart.items.values.toList()[i].id,
//              cart.items.keys.toList()[i],
//              cart.items.values.toList()[i].price,
//              cart.items.values.toList()[i].quantity,
//              cart.items.values.toList()[i].title,
//              cart.items.values.toList()[i].isNonInventory,
//              cart.items.values.toList()[i].discount,
//              cart.items.values.toList()[i].discountId,
//              cart.items.values.toList()[i].discountType,
//            ),
//          )),
//          cart.items.length > 0
//              ? Container(
//                  height: 50.0,
//                  color: Theme.of(context).primaryColor,
//                  child: Row(
//                    children: <Widget>[
//                      Container(
//                          width: MediaQuery.of(context).size.width * 5 / 7,
//                          padding: EdgeInsets.only(left: 20.0,top: 5.0),
//                          color: Theme.of(context).primaryColor,
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            children: <Widget>[
//                              Text('SubTotal: ' +
//                                  cart.totalAmount.toStringAsFixed(2)),
//                              cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
//                              cart.totalAmount>500 ?
//                              Text(
//                                'Total amount : ' +
//                                    cart.totalAmount.toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              )
//                              :Text(
//                                'Total amount : ' +
//                                    (cart.totalAmount + 50.00).toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              ),
//                            ],
//                          )),
//                      Container(
//                        height: MediaQuery.of(context).size.height,
//                        width: MediaQuery.of(context).size.width * 2 / 7,
//                        color: Theme.of(context).primaryColorDark,
//                        child: InkWell(
//                          child: Center(
//                            child: Text(
//                              'Check out',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                          onTap: () {
//                            auth.isAuth?
//                            Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                                :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                            showDialog(
////                                context: context,
////                                child: _confirmOrderDialog(context, cart)
//////                                child: ConfirmOrderDialog()
////                            );
//                          },
//                        ),
//                      ),
//                    ],
//                  ))
//              : SizedBox(
//                  width: 0.0,
//                  height: 0.0,
//                )
//        ],
//      ),
//    );
//  }
//}
