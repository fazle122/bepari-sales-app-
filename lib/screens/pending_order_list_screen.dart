import 'package:sales_app/base_state.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/cart_screen.dart';
import 'package:sales_app/screens/order_detail_screen.dart';
import 'package:sales_app/screens/order_update_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/widgets/order_fiter_dialog.dart';
import 'package:toast/toast.dart';

class PendingOrderListScreen extends StatefulWidget {
  static const routeName = '/pending-orders';

  @override
  _PendingOrderListScreenState createState() => _PendingOrderListScreenState();
}

class _PendingOrderListScreenState extends BaseState<PendingOrderListScreen> {
  var _isInit = true;
  var _isLoading = false;
  Map<String,dynamic> filters = Map();


  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int lastPage;
  int oldPageCount;
  List<OrderItem> finalOrders = [];
  int lastItemId = 0;
  bool isPerformingRequest = false;

  TextEditingController cancelCommentController;
  TextEditingController deliveryCommentController;
  TextEditingController amountController;
  var pageTitle = 'Pending';

  @override
  void initState() {
    cancelCommentController = TextEditingController();
    deliveryCommentController = TextEditingController();
    amountController = TextEditingController();
    filters['status_array'] = [0];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final orders = Provider.of<Orders>(context, listen: false);
    if (pageCount == 1) {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<Cart>(context,listen: false).fetchAndSetCartItems1();
        Provider.of<Orders>(context, listen: false)
            .fetchAndSetOrdersTest(filters,pageCount)
            .then((data) {
          setState(() {
            finalOrders = data;
            lastPage = orders.lastPageNo;
            oldPageCount = 0;
            _isLoading = false;
          });
        });
      }
      _isInit = false;
    }

    _scrollController.addListener(() {
//      if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1) {
      _isInit = true;
      if (pageCount <= lastPage) if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          pageCount += 1;
        });
        getOrderData(filters,pageCount);
      }
//      }
    });

    super.didChangeDependencies();
  }

  List<OrderItem> getOrderData(Map<String,dynamic> filters,int pageCount) {
    if (_isInit) {
      if (!isPerformingRequest) {
        setState(() {
          isPerformingRequest = true;
        }
        );
      }
      Provider.of<Orders>(context, listen: false)
          .fetchAndSetOrdersTest(filters,pageCount)
          .then((data) {
        isPerformingRequest = false;
        if (data == null || data.isEmpty) {
          if (finalOrders.isNotEmpty) animateScrollBump();
          if (finalOrders.isEmpty) {
            setState(() {});
          }
        } else {
          setState(() {
            oldPageCount += 1;
            finalOrders.addAll(data);
            lastItemId = data.last.id;
          });
        }

      });
//      }
    }
    _isInit = false;
    return finalOrders;
  }

  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  Future<Map<String, dynamic>> _orderFilterDialog() async {
    return showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => OrderFilterDialog(),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  setPageTitle(Map<String,dynamic> data){
    if(data.containsKey('status_array') && data['status_array'] != null){
      if(data['status_array'][0] == 0){
        setState(() {
          pageTitle = "Pending";
        });
      }
      if(data['status_array'][0] == 1){
        setState(() {
          pageTitle = "Full due";
        });
      }
      if(data['status_array'][0] == 4){
        setState(() {
          pageTitle = "Partial paid";
        });
      }
      if(data['status_array'][0] == 5){
        setState(() {
          pageTitle = "Full paid";
        });
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle + ' orders'),
          actions: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.all(10.0),
                width: 80.0,
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
                      'New Order',
                      style:
                      TextStyle(color: Theme.of(context).primaryColorDark,fontWeight: FontWeight.bold),
                    )),
              ),
              onTap: () {
                Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () async{
                var newFilter = await _orderFilterDialog();
                if(newFilter != null && newFilter.length>0){
                  setState(() {
                    pageCount = 1;
                    finalOrders = [];
                    filters = newFilter;
                    _isInit = true;
                  });
                  setPageTitle(filters);
                }
                getOrderData(filters,1);
              },
            ),
//             PopupMenuButton<String>(
//               onSelected: (val) async {
//                 switch (val) {
//                   case 'FILTER':
//                     var newFilter = await _orderFilterDialog();
//                     if(newFilter != null && newFilter.length>0){
//                       setState(() {
//                         pageCount = 1;
//                         finalOrders = [];
//                         filters = newFilter;
//                         _isInit = true;
//                       });
//                       setPageTitle(filters);
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
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(),)
            : Container(
//          height: MediaQuery.of(context).size.height * 7/10,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: queryItemListDataWidget(context)
              ),

            ],
          ),
        )

    );
  }

  Widget queryItemListDataWidget(BuildContext context) {

    if (finalOrders.isNotEmpty) //has data & performing/not performing
      return Container(
        child:  finalOrders != null && finalOrders.length > 0
            ? ListView.builder(
          controller: _scrollController,
          itemCount: finalOrders.length +1,
          itemBuilder: (context, i) {
            if(i == finalOrders.length){
              return _buildProgressIndicator();
            }else{
//            return ChangeNotifierProvider.value(value: null,child:Text(''));

              return
                Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Invoice amount: ' + '\$${finalOrders[i].invoiceAmount}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
                      subtitle:Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Flexible(child:Text('Customer name: ' + finalOrders[i].customerName,style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold),),),
                          Flexible(child:Text('Invoice date: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].invoiceDate),style: TextStyle(fontSize: 12.0),),),
                          // Flexible(child: Text('Invoice created: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].createdAt) + convert12(DateFormat('hh:mm').format(finalOrders[i].createdAt)),style: TextStyle(fontSize: 10.0),),),
                          Flexible(child: Text('Invoice created: ' + DateFormat('EEEE, MMM d, hh:mm aaa').format(finalOrders[i].createdAt.toLocal()),style: TextStyle(fontSize: 10.0),),),
                        ],
                      ),
                      trailing: Container(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            filters['status_array'][0] == 0 || filters['status_array'][0] == 1 ?
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Center(child: Text('Cancel order')),
                                          content: Container(
                                            height: 70,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Comment'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 150,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: 2,
                                                        controller: cancelCommentController,
                                                        decoration: InputDecoration(hintText: 'write a comment'),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[

                                            FlatButton(
                                              child: Text('Confirm'),
                                              onPressed: () async{
                                                cancelCommentController.text = null;
                                                var response = await Provider.of<Orders>(context, listen: false).cancelOrder(finalOrders[i].id.toString(), cancelCommentController.text);
                                                if(response != null){
                                                  Toast.show(response['msg'], context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                                }else{
                                                  Toast.show('Something went wrong, please try again.', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);

                                                }
                                                if (!mounted) return;
                                                setState(() {
                                                  _isInit = true;
                                                  _isLoading = true;

                                                });
                                                Provider.of<Orders>(context, listen: false).fetchAndSetOrdersTest(filters,pageCount).then((data) {
                                                  setState(() {
                                                    finalOrders = data;
                                                    _isLoading = false;
                                                  });
                                                });
                                                _isInit = false;
                                                Navigator.of(
                                                    context)
                                                    .pop(true);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(false);
                                              },
                                            ),
                                          ],
                                        ));
                              },
                            ):SizedBox(width: 0.0,height: 0.0,),
                            // SizedBox(width: 20.0,),
                            filters['status_array'][0] == 0 || filters['status_array'][0] == 1 ?
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async{
                                final cart = Provider.of<Cart>(context,listen: false);
                                final orders = Provider.of<Orders>(context,listen: false);

                                await DBHelper.clearCart();
                                setState(() {
                                  orders.deliveryCharge = null;

                                });

                                cart.invoiceIdForUpdate = finalOrders[i].id;
                                List<Map<String,dynamic>> cartItemFromOrder;
                                await DBHelper.clearCart();
                                await Provider.of<Orders>(context,listen: false).fetchOrderForCart(finalOrders[i].id).then((data){
                                  setState(() {
                                    cartItemFromOrder = data;
                                  });
                                  cartItemFromOrder.map((cartData) async{
                                    await DBHelper.createCartFromOrder(CartItem.fromJson(cartData));
                                  }).toList();
                                });

                                setState(() {
                                  cart.isUpdateMode = true;
                                });

                                await Provider.of<Cart>(context, listen: false).fetchAndSetCartItems1();

                                Navigator.of(context).pushNamed(CartScreen.routeName, arguments: finalOrders[i].id);
                              },
                            ):SizedBox(width: 0.0,height: 0.0,),
                          ],
                        ),
                      ),
                      onTap: () async {
                        Navigator.of(context).pushNamed(
                            OrderDetailScreen.routeName,
                            arguments: finalOrders[i].id);
                      },
                    ),
                  ],
                ),
              );
            }
          },
        )
            : Center(
          child: Text('No pending order'),
        ),

      );
    if (isPerformingRequest)
      return Center(
        child: CircularProgressIndicator(),
      );

    return Center(
      child: Text('no order found'),
    );
  }

}
