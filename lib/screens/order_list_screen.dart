//
// import 'package:sales_app/base_state.dart';
// import 'package:sales_app/data_helper/local_db_helper.dart';
// import 'package:sales_app/providers/cart.dart';
// import 'package:sales_app/providers/orders.dart';
// import 'package:sales_app/screens/cart_screen.dart';
// import 'package:sales_app/screens/order_detail_screen.dart';
// import 'package:sales_app/screens/order_update_screen.dart';
// import 'package:sales_app/screens/products_overview_screen.dart';
// import 'package:sales_app/widgets/app_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:sales_app/widgets/order_fiter_dialog.dart';
//
//
//
// class OrderListScreen extends StatefulWidget {
//   static const routeName = '/orders';
//
//   @override
//   _OrderListScreenState createState() => _OrderListScreenState();
// }
//
// class _OrderListScreenState extends BaseState<OrderListScreen> {
//   var _isInit = true;
//   var _isLoading = false;
//   Map<String,dynamic> filters = Map();
//
//
//   ScrollController _scrollController = new ScrollController();
//   int pageCount = 1;
//   int lastPage;
//   int oldPageCount;
//   List<OrderItem> finalOrders = [];
//   int lastItemId = 0;
//   bool isPerformingRequest = false;
//
//   TextEditingController cancelCommentController;
//   TextEditingController deliveryCommentController;
//   TextEditingController amountController;
//
//   @override
//   void initState() {
//     cancelCommentController = TextEditingController();
//     deliveryCommentController = TextEditingController();
//     amountController = TextEditingController();
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     final orders = Provider.of<Orders>(context, listen: false);
//     if (pageCount == 1) {
//       if (_isInit) {
//         setState(() {
//           _isLoading = true;
//         });
//         Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
//         Provider.of<Orders>(context, listen: false)
//             .fetchAndSetOrders(filters,pageCount)
//             .then((data) {
//           setState(() {
//             finalOrders = data;
//             lastPage = orders.lastPageNo;
//             oldPageCount = 0;
//             _isLoading = false;
//           });
//         });
//       }
//       _isInit = false;
//     }
//
//     _scrollController.addListener(() {
// //      if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1) {
//       _isInit = true;
//       if (pageCount < lastPage) if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         setState(() {
//           pageCount += 1;
//         });
//         getOrderData(filters,pageCount);
//       }
// //      }
//     });
//
//     super.didChangeDependencies();
//   }
//
//   List<OrderItem> getOrderData(Map<String,dynamic> filters,int pageCount) {
//     if (_isInit) {
//       if (!isPerformingRequest) {
//         setState(() {
//           isPerformingRequest = true;
//         }
//         );
//       }
//       Provider.of<Orders>(context, listen: false)
//           .fetchAndSetOrders(filters,pageCount)
//           .then((data) {
//         isPerformingRequest = false;
//         if (data == null || data.isEmpty) {
//           if (finalOrders.isNotEmpty) animateScrollBump();
//           if (finalOrders.isEmpty) {
//             setState(() {});
//           }
//         } else {
//           setState(() {
//             oldPageCount += 1;
//             finalOrders.addAll(data);
//             lastItemId = data.last.id;
//           });
//         }
//
//       });
// //      }
//     }
//     _isInit = false;
//     return finalOrders;
//   }
//
//
//
//   void animateScrollBump() {
//     double edge = 50.0;
//     double offsetFromBottom = _scrollController.position.maxScrollExtent -
//         _scrollController.position.pixels;
//     if (offsetFromBottom < edge) {
//       _scrollController.animateTo(
//           _scrollController.offset - (edge - offsetFromBottom),
//           duration: new Duration(milliseconds: 500),
//           curve: Curves.easeOut);
//     }
//   }
//
//   getData(Map<String,dynamic> filters){
//     if(_isInit) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = true;
//       });
//       Provider.of<Orders>(context,listen: false).fetchAndSetOrders(filters,1).then((_){
//         if (!mounted) return;
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//     _isInit = false;
//   }
//
//   Future<Map<String, dynamic>> _orderFilterDialog() async {
//     return showDialog<Map<String, dynamic>>(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) => OrderFilterDialog(),
//     );
//   }
//
//   String convert12(String str) {
//     String finalTime;
//     int h1 = int.parse(str.substring(0, 1)) - 0;
//     int h2 = int.parse(str.substring(1, 2));
//     int hh = h1 * 10 + h2;
//
//     String Meridien;
//     if (hh < 12) {
//       Meridien = " AM";
//     } else
//       Meridien = " PM";
//     hh %= 12;
//     if (hh == 0 && Meridien == ' PM') {
//       finalTime = '12' + str.substring(2);
//     } else {
//       finalTime = hh.toString() + str.substring(2);
//     }
//     finalTime = finalTime + Meridien;
//     return finalTime;
//   }
//
//   Widget _buildProgressIndicator() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: Opacity(
//           opacity: isPerformingRequest ? 1.0 : 0.0,
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('All Orders'),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.add),
//               onPressed: (){
//                 Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
//               },
//             ),
//             PopupMenuButton<String>(
//               onSelected: (val) async {
//                 switch (val) {
// //                  case 'COMPLETED_ORDERS':
// //                    Navigator.of(context).pushNamed(CompletedOrdersScreen.routeName);
// //                    break;
//                   case 'FILTER':
//                     var newFilter = await _orderFilterDialog();
//                     if(newFilter != null){
//                       setState(() {
//                         pageCount = 1;
//                         finalOrders = [];
//                         filters = newFilter;
//                         _isInit = true;
//                       });
//                     }
//                     getOrderData(filters,1);
//                     break;
//
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
// //                PopupMenuItem<String>(
// //                  value: 'COMPLETED_ORDERS',
// //                  child: Text('Completed orders'),
// //                ),
//                 PopupMenuItem<String>(
//                   value: 'FILTER',
//                   child: Text('Filter'),
//                 )
//               ],
//             ),
//           ],
//         ),
//         drawer: AppDrawer(),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator(),)
//             : Container(
// //          height: MediaQuery.of(context).size.height * 7/10,
//           child: Column(
//             children: <Widget>[
//               Expanded(
//                   child: queryItemListDataWidget(context)
//               ),
//
//             ],
//           ),
//         )
//
//     );
//   }
//
//   Widget queryItemListDataWidget(BuildContext context) {
//     if (finalOrders.isNotEmpty) //has data & performing/not performing
//       return Container(
//         child:  finalOrders != null && finalOrders.length > 0
//             ? ListView.builder(
//           controller: _scrollController,
//           itemCount: finalOrders.length +1,
//           itemBuilder: (context, i) {
//             if(i == finalOrders.length){
//               return _buildProgressIndicator();
//             }else{
// //            return ChangeNotifierProvider.value(value: null,child:Text(''));
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 child: Column(
//                   children: <Widget>[
//                     ListTile(
//                       title: Text(
//                         DateFormat('EEEE, MMM d, ').format(
//                             finalOrders[i].dateTime) +
//                             convert12(DateFormat('hh:mm').format(
//                                 finalOrders[i].dateTime)),
//                       ),
//                       subtitle: Text('Total amount: ' +
//                           '\$${finalOrders[i].invoiceAmount}'),
//                       trailing: Container(
//                         width: 150,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             finalOrders[i].status != null ?SizedBox(width: 0.0,height: 0.0,):
//                             IconButton(
//                               icon: Icon(Icons.done),
//                               onPressed: () async {
//                                 showDialog(
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder: (context) =>
//                                         AlertDialog(
//                                           title: Center(child:Text(
//                                               'Confirm order')),
//                                           content:
//                                           Container(
//                                             height: 150,
//                                             child: Column(
//                                               children: <Widget>[
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Amount'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.number,
//                                                         controller: amountController,
//                                                         decoration: InputDecoration(hintText: 'enter order amount'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Comment'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.multiline,
//                                                         maxLines: 2,
//                                                         controller: deliveryCommentController,
//                                                         decoration: InputDecoration(hintText: 'write a comment'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             FlatButton(
//                                               child: Text('Continue'),
//                                               onPressed: () async{
//                                                 // await Provider.of<Orders>(context, listen: false).receivePartialPayment(finalOrders[i].id.toString(), deliveryCommentController.text,double.parse(amountController.text),null);
//                                                 if (!mounted) return;
//                                                 setState(() {
//                                                   _isInit = true;
//                                                   _isLoading = true;
//
//                                                 });
//                                                 Provider.of<Orders>(context, listen: false)
//                                                     .fetchAndSetOrders(filters,pageCount)
//                                                     .then((data) {
//                                                   setState(() {
//                                                     finalOrders = data;
//                                                     _isLoading = false;
//                                                   });
//                                                 });
//                                                 _isInit = false;
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(true);
//                                               },
//                                             ),
//                                             FlatButton(
//                                               child: Text('Cancel'),
//                                               onPressed: () {
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(true);
//                                               },
//                                             ),
//                                           ],
//                                         ));
//                               },
//                             ),
//                             finalOrders[i].status != null ?SizedBox(width: 0.0,height: 0.0,):
//                             IconButton(
//                               icon: Icon(Icons.cancel),
//                               onPressed: () async {
//                                 showDialog(
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder: (context) =>
//                                         AlertDialog(
//                                           title: Center(child: Text('Cancel order')),
//                                           content: Container(
//                                             height: 70,
//                                             child: Column(
//                                               children: <Widget>[
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Comment'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.multiline,
//                                                         maxLines: 2,
//                                                         controller: cancelCommentController,
//                                                         decoration: InputDecoration(hintText: 'write a comment'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             FlatButton(
//                                               child: Text('Cancel'),
//                                               onPressed: () {
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(false);
//                                               },
//                                             ),
//                                             FlatButton(
//                                               child: Text('Confirm'),
//                                               onPressed: () async{
//                                                 await Provider.of<Orders>(context, listen: false).cancelOrder(finalOrders[i].id.toString(), cancelCommentController.text);
//                                                 if (!mounted) return;
//                                                 setState(() {
//                                                   _isInit = true;
//                                                   _isLoading = true;
//
//                                                 });
//                                                 Provider.of<Orders>(context, listen: false)
//                                                     .fetchAndSetOrders(filters,pageCount)
//                                                     .then((data) {
//                                                   setState(() {
//                                                     finalOrders = data;
//                                                     _isLoading = false;
//                                                   });
//                                                 });
//                                                 _isInit = false;
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(true);
//                                               },
//                                             ),
//                                           ],
//                                         ));
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit),
//                               onPressed: () async{
//                                 List<Map<String,dynamic>> cartItemFromOrder;
//                                 await DBHelper.clearCart();
//                                 await Provider.of<Orders>(context,listen: false).fetchOrderForCart(finalOrders[i].id).then((data){
//                                   setState(() {
//                                     cartItemFromOrder = data;
//                                   });
//                                   cartItemFromOrder.map((cartData) async{
//                                     await DBHelper.createCartFromOrder(CartItem.fromJson(cartData));
//                                   }).toList();
//                                 });
//                                 final cart = Provider.of<Cart>(context,listen: false);
//
//                                   setState(() {
//                                     cart.isUpdateMode = true;
//                                   });
//
//                                 await Provider.of<Cart>(context, listen: false).fetchAndSetCartItems1();
//
//                                 // Navigator.of(context).pushNamed(OrderUpdateScreen.routeName, arguments: finalOrders[i].id);
//                                 Navigator.of(context).pushNamed(CartScreen.routeName, arguments: finalOrders[i].id);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       onTap: () async {
//                         Navigator.of(context).pushNamed(
//                             OrderDetailScreen.routeName,
//                             arguments: finalOrders[i].id);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         )
//             : Center(
//           child: Text('No pending order'),
//         ),
//
//       );
//     if (isPerformingRequest)
//       return Center(
//         child: CircularProgressIndicator(),
//       );
//
//     return Center(
//       child: Text('no order found'),
//     );
//   }
//
//
// }
//
//
//
// class OrderItemList extends StatelessWidget {
//
//   final List<OrderItem> orderListItems;
//   final ScrollController scrollController;
//   final bool isPerformingRequest;
//
//
//
//   OrderItemList(
//       {this.orderListItems, this.scrollController, this.isPerformingRequest});
// //
// //  @override
// //  _OrderItemListState createState() => _OrderItemListState();
// //
// //}
// //
// //class _OrderItemListState extends State<OrderItemList>{
//   var _isInit = true;
//
// //  TextEditingController commentController;
// //  TextEditingController deliveryCommentController;
// //  TextEditingController amountController;
// //
// //  @override
// //  void initState() {
// //    commentController = TextEditingController();
// //    deliveryCommentController = TextEditingController();
// //    amountController = TextEditingController();
// //    super.initState();
// //  }
//
//   String convert12(String str) {
//     String finalTime;
//     int h1 = int.parse(str.substring(0, 1)) - 0;
//     int h2 = int.parse(str.substring(1, 2));
//     int hh = h1 * 10 + h2;
//
//     String Meridien;
//     if (hh < 12) {
//       Meridien = " AM";
//     } else
//       Meridien = " PM";
//     hh %= 12;
//     if (hh == 0 && Meridien == ' PM') {
//       finalTime = '12' + str.substring(2);
//     } else {
//       finalTime = hh.toString() + str.substring(2);
//     }
//     finalTime = finalTime + Meridien;
//     return finalTime;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Container(
//         child:  orderListItems != null && orderListItems.length > 0
//             ? ListView.builder(
//           controller: scrollController,
//           itemCount: orderListItems.length +1,
//           itemBuilder: (context, i) {
//             if(i == orderListItems.length){
//               return _buildProgressIndicator();
//             }else{
// //            return ChangeNotifierProvider.value(value: null,child:Text(''));
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 child: Column(
//                   children: <Widget>[
//                     ListTile(
//                       title: Text(
//                         DateFormat('EEEE, MMM d, ').format(
//                             orderListItems[i].dateTime) +
//                             convert12(DateFormat('hh:mm').format(
//                                 orderListItems[i].dateTime)),
//                       ),
//                       subtitle: Text('Total amount: ' +
//                           '\$${orderListItems[i].invoiceAmount}'),
//                       trailing: Container(
//                         width: 180,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
// //                              orderData.orders[i].status != null ?SizedBox(width: 0.0,height: 0.0,):
//                             IconButton(
//                               icon: Icon(Icons.done),
//                               onPressed: () async {
// //                                              Navigator.pushReplacement(context, MaterialPageRoute(
// //                                                  builder: (context) =>SignaturePage(id:orderData.orders[i].id.toString())
// //                                              ));
//                                 showDialog(
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder: (context) =>
//                                         AlertDialog(
//                                           title: Center(child:Text(
//                                               'Confirm order')),
//                                           content:
//                                           Container(
//                                             height: 150,
//                                             child: Column(
//                                               children: <Widget>[
//                                                 Row(
// //                                                                mainAxisAlignment: MainAxisAlignment.start,
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Amount'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.number,
// //                                                      controller: amountController,
//                                                         decoration: InputDecoration(hintText: 'enter order amount'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                                 Row(
// //                                                                mainAxisAlignment: MainAxisAlignment.start,
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Comment'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.multiline,
//                                                         maxLines: 2,
// //                                                      controller: deliveryCommentController,
//                                                         decoration: InputDecoration(hintText: 'write a comment'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             FlatButton(
//                                               child: Text('Continue'),
//                                               onPressed: () async{
// //                                                              Navigator.pushReplacement(context, MaterialPageRoute(
// //                                                                builder: (context) =>SignaturePage(id:orderData.orders[i].id.toString(), comment:deliveryCommentController.text,amount:double.parse(amountController.text))
// //                                                              ));
// //                                              await Provider.of<Orders>(context, listen: false).deliverOrder(orderData.orders[i].id.toString(), deliveryCommentController.text,double.parse(amountController.text),null);
// //                                              if (!mounted) return;
// //                                              setState(() {
// //                                                _isInit = true;
// //                                              });
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(true);
//                                               },
//                                             ),
// //                                                          FlatButton(
// //                                                            child: Text('Back'),
// //                                                            onPressed: () {
// //                                                              Navigator.of(
// //                                                                  context)
// //                                                                  .pop(false);
// //                                                            },
// //                                                          ),
//                                             FlatButton(
//                                               child: Text('Cancel'),
//                                               onPressed: () {
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(true);
//                                               },
//                                             ),
//                                           ],
//                                         ));
//                               },
//                             ),
//                              // orderData.orders[i].status != null ?SizedBox(width: 0.0,height: 0.0,):
//
//                             IconButton(
//                               icon: Icon(Icons.cancel),
//                               onPressed: () async {
//                                 showDialog(
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder: (context) =>
//                                         AlertDialog(
//                                           title: Center(child: Text('Cancel order')),
//                                           content: Container(
//                                             height: 70,
//                                             child: Column(
//                                               children: <Widget>[
//                                                 Row(
// //                                                                mainAxisAlignment: MainAxisAlignment.start,
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: <Widget>[
//                                                     Text('Comment'),
//                                                     SizedBox(width: 10,),
//                                                     Container(
//                                                       width: 150,
//                                                       child: TextFormField(
//                                                         keyboardType: TextInputType.multiline,
//                                                         maxLines: 2,
// //                                                      controller: commentController,
//                                                         decoration: InputDecoration(hintText: 'write a comment'),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           actions: <Widget>[
//                                             FlatButton(
//                                               child: Text('Cancel'),
//                                               onPressed: () {
//                                                 Navigator.of(
//                                                     context)
//                                                     .pop(false);
//                                               },
//                                             ),
//                                             FlatButton(
//                                               child: Text('Confirm'),
//                                               onPressed: () async{
//                                               },
//                                             ),
//                                           ],
//                                         ));
//                               },
//                             ),
//
//                           ],
//                         ),
//                       ),
//                       onTap: () {
// //                          Navigator.of(context).pushNamed(
// //                              OrderDetailScreen.routeName,
// //                              arguments: orderData.orders[i].id);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         )
//             : Center(
//           child: Text('No pending order'),
//         ),
//
//       );
//   }
//
//   Widget _buildProgressIndicator() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: Opacity(
//           opacity: isPerformingRequest ? 1.0 : 0.0,
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressIndicator1() {
//     return Padding(
//       padding: const EdgeInsets.only(top:50,left:160),
//       child: Center(
//         child: Opacity(
//           opacity: isPerformingRequest ? 1.0 : 0.0,
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
//
// }
