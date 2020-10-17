import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/order_detail_screen.dart';


class OrderItemWidget extends StatelessWidget {
  final OrderItem order;

  OrderItemWidget(this.order);

//  @override
//  _OrderItemState createState() => _OrderItemState();
//}
//
//class _OrderItemState extends State<OrderItemWidget> {


  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key:ValueKey(order.id),
//      key:UniqueKey(),
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
      onDismissed: (direction) {
        Provider.of<Orders>(context,listen: false).cancelOrder(order.id.toString(),'test');
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${order.invoiceAmount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(order.invoiceDate),
              ),
              onTap: (){
                Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
                    arguments: order.id);
              },
            ),
          ],
        ),
      ),
    );








//    return Card(
//      margin: EdgeInsets.all(10),
//      child: Column(
//        children: <Widget>[
//          ListTile(
//            title: Text('\$${widget.order.invoiceAmount}'),
//            subtitle: Text(
//              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
//            ),
//            onTap: (){
//              Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
//                  arguments: widget.order.id);
//            },
//          ),
//        ],
//      ),
//    );
  }
}
