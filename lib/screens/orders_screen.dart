import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/completed_orders_screen.dart';
import 'package:sales_app/screens/order_detail_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/order_fiter_dialog.dart';
import 'package:sales_app/widgets/order_item.dart';
import 'package:intl/intl.dart';

import '../base_state.dart';




///------------with out future builder-----------------------

class OrdersScreen extends StatefulWidget {

  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();

}

class _OrdersScreenState extends BaseState<OrdersScreen>{

  var _isInit = true;
  var _isLoading = false;
  Map<String, dynamic> filters = Map();
  int pageCount = 1;


  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchAndSetOrders(filters,pageCount).then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  getData(Map<String,dynamic> filters){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context,listen: false).fetchAndSetOrders(filters,pageCount).then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
  }

  String convert12(String str) {
    String finalTime;
    int h1 = int.parse(str.substring(0, 1)) - 0;
    int h2 = int.parse(str.substring(1, 2));
    int hh = h1 * 10 + h2;

    String Meridien;
    if (hh < 12) {
      Meridien = " AM";
    } else
      Meridien = " PM";
    hh %= 12;
    if (hh == 0 && Meridien == ' PM') {
      finalTime = '12' + str.substring(2);
    } else {
      finalTime = hh.toString() + str.substring(2);
    }
    finalTime = finalTime + Meridien;
    return finalTime;
  }

  Future<Map<String, dynamic>> _orderFilterDialog() async {
    return showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => OrderFilterDialog(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pending orders'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (val) async {
                switch (val) {
                  case 'COMPLETED_ORDERS':
                    Navigator.of(context).pushNamed(CompletedOrdersScreen.routeName);
                    break;
                  case 'FILTER':
                    var newFilter = await _orderFilterDialog();
                    if(newFilter != null){
                      setState(() {
                        filters = newFilter;
                        _isInit = true;
                      });
                    }
                    getData(filters);
                    break;

                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'COMPLETED_ORDERS',
                  child: Text('Completed orders'),
                ),
                PopupMenuItem<String>(
                  value: 'FILTER',
                  child: Text('Filter'),
                ),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(),
        body:
        _isLoading?
        Center(child: CircularProgressIndicator(),)
            : Consumer<Orders>(builder: (context,orderData,child) =>
        orderData.orders.length >0 ?ListView.builder(
          itemCount: orderData.orders.length,
//                  itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
          itemBuilder: (context,i){
            return Dismissible(
//                      key:Key(orderData.orders[i].id.toString()),
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
//                        setState(() {
//                          _isLoading = true;
//                        });
                await Provider.of<Orders>(context,listen: false).cancelOrder(orderData.orders[i].id.toString(),'test');
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
                      title: Text(
                        DateFormat('EEEE, MMM d, ').format(orderData.orders[i].dateTime) +
                            convert12(DateFormat('hh:mm').format(orderData.orders[i].dateTime)),
                      ),
                      subtitle: Text('Total amount: ' +'\$${orderData.orders[i].invoiceAmount}'),

                      onTap: (){
                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
                            arguments: orderData.orders[i].id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ):Center(child: Text('No pending order'),),
        )
    );
  }

}

