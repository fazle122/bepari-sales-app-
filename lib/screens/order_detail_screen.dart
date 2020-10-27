import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/due_orders_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import 'pending_order_list_screen.dart';


class OrderDetailScreen extends StatefulWidget {

  static const routeName = '/order-detail';

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

  class _OrderDetailScreenState extends State<OrderDetailScreen>{
  TextEditingController commentController;
  TextEditingController deliveryCommentController;
  TextEditingController cancelCommentController;
  TextEditingController dueAmountController;
  TextEditingController paidAmountController;
  TextEditingController receiveAmountController;
  TextEditingController amountController;

  double _receiptAmount = 0.0;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {

    commentController = TextEditingController();
    deliveryCommentController = TextEditingController();
    cancelCommentController = TextEditingController();
    dueAmountController = TextEditingController();
    paidAmountController = TextEditingController();
    receiveAmountController = TextEditingController();
    amountController = TextEditingController();
    // amountController.text = _receiptAmount.toString();
    super.initState();
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


  Widget _soldWithDue(var orderId,var invoiceData){
    return AlertDialog(
      title: Center(child:Text('Confirm order')),
      content:
      Container(
        height: 100,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Invoice amount : '),
                SizedBox(width: 10,),
                Text(invoiceData.invoiceAmount.toString())
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Current payment'),
                SizedBox(width: 10,),
                Container(
                  width: 130,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    onChanged: (text) => {},
                    decoration: InputDecoration(prefixIcon: Icon(Icons.attach_money),hintText: '0.0'),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Pay later'),
          onPressed: () async{
            var response = await Provider.of<Orders>(context, listen: false).confirmOrder(orderId.toString());
            if(response != null){
              Toast.show(response['msg'], context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
            }else{
              Toast.show('Something went wrong, please try again', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
            }
            Navigator.of(context).pop(true);
            Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
          },
        ),
        FlatButton(
          child: Text('Sold with due'),
          onPressed: () async{
            Map<String,dynamic> data = Map();
            data.putIfAbsent('receipt_date', () => DateTime.now());
            data.putIfAbsent('invoice_status', () => 4);
            data.putIfAbsent('receipt_amount', () => amountController.text);
            data.putIfAbsent('comment', () => '');

            FormData formData = FormData.fromMap(data);
            var response;
            if(amountController.text == '' || amountController.text == null) {
              Toast.show('Please enter amount', context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
            }else if(double.parse(amountController.text)>double.parse(invoiceData.invoiceAmount)){
              Toast.show('Please enter amount not higher than invoice amount', context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
            }else{
              print(amountController.text);
              response = await Provider.of<Orders>(context, listen: false).payOrderWithDue(orderId.toString(),formData);
              amountController.text = null;
              if(response != null){
                Toast.show(response['msg'], context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
              }else{
                Toast.show('Something went wrong, please try again', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
              }
            }


          },
        ),
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final orderId = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
        appBar: AppBar(title: Text('Order detail'),),
        body: FutureBuilder(
          future:Provider.of<Orders>(context,listen:false).fetchSingleOrder(orderId),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }else{
              if(snapshot.error != null){
                return Center(child: Text('error occurred'),);
              }else{
                return Consumer<Orders>(builder: (context,orderDetailData,child) =>
//                    Text(orderDetailData.singOrderItem.totalDue.toString()),);
                Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15.0),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListTile(

                          title:Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Total invoice amount: ' + orderDetailData.singOrderItem.invoiceAmount + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                Text('Due: ' +orderDetailData.singOrderItem.totalDue.toString() + ' BDT'),

                              ],
                            ) ,
                          ),

                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Customer name: ' +orderDetailData.singOrderItem.customerName),
                              Text('Address: ' +orderDetailData.singOrderItem.customerAddress),
                              Text('Mobile no: ' +orderDetailData.singOrderItem.customerMobileNo),

                  ],
                        )
                          // subtitle: Text(
                          //   DateFormat('EEEE, MMM d, ').format(orderDetailData.singOrderItem.dateTime) +
                          //       convert12(DateFormat('hh:mm').format(orderDetailData.singOrderItem.dateTime)),
                          // ),
                        )
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: orderDetailData.singOrderItem.invoiceItem.length,
                          itemBuilder: (context, i) =>

                              Card(
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(15.0),
                                // ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.grey[200],
                                    width: 2.0,
                                  ),
                                ),
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    orderDetailData.singOrderItem.invoiceItem[i].productID == 1 ?
                                    ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(orderDetailData.singOrderItem.invoiceItem[i].productName),
                                            SizedBox(width: 20.0,),
                                            Text('\$${(double.parse(orderDetailData.singOrderItem.invoiceItem[i].unitPrice))}'),
                                          ],
                                        )
                                    ):
                                    ListTile(
                                      title: Center(child:Text(orderDetailData.singOrderItem.invoiceItem[i].productName)),
                                      subtitle: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Quantity : ' + orderDetailData.singOrderItem.invoiceItem[i].quantity),
                                          SizedBox(width: 30.0,),
                                          Text('Total : \$${(double.parse(orderDetailData.singOrderItem.invoiceItem[i].unitPrice) * double.parse(orderDetailData.singOrderItem.invoiceItem[i].quantity))}'),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              )
                        )
                    ),
                    orderDetailData.singOrderItem.status == '5' ? SizedBox(width: 0.0,height: 0.0,):
                    Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: orderDetailData.singOrderItem.status == null? MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                        children: <Widget>[
                          orderDetailData.singOrderItem.status != '4' ?
                          Container(
                            height: 40.0,
                            width: 140.0,
                            child: RaisedButton(
                              child: Text("Sold".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.grey)),
                              onPressed: () async{
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Center(child: Text('Order confirmation')),
                                          content: Container(
                                            height: 70,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Invoice amount : '),
                                                    SizedBox(width: 10,),
                                                    Text(orderDetailData.singOrderItem.invoiceAmount.toString())
                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Flexible(child:Text('Are you sure, you want to sold this order with full payment?'),)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[

                                            FlatButton(
                                              child: Text('Paid & Finished'),
                                              onPressed: () async{
                                                var response = await Provider.of<Orders>(context, listen: false).payOrder(orderId.toString());
                                                if(response != null){
                                                  Toast.show(response['msg'], context,
                                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                }else{
                                                  Toast.show('something went wrong, please try again', context,
                                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                }
                                                if(orderDetailData.singOrderItem.status == '1' || orderDetailData.singOrderItem.status == '4'){
                                                  Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
                                                }else{
                                                  Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
                                                }

                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                          ],
                                        ));
                              },
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                            ),
                          ):SizedBox(width: 0.0,height: 0.0,),
                          SizedBox(width: 20.0,),
                          orderDetailData.singOrderItem.status == '4' || orderDetailData.singOrderItem.status == '1' ?SizedBox(width: 0.0,height: 0.0,):
                          Container(
                            height: 40.0,
                            width: 140.0,
                            child: RaisedButton(
                              child: Text("Sold with due".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.grey)),
                              onPressed: () async{

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>_soldWithDue(orderId.toString(),orderDetailData.singOrderItem));
                              },
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    orderDetailData.singOrderItem.status == '5' ? SizedBox(width: 0.0,height: 0.0,):
                    Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: orderDetailData.singOrderItem.status == null? MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                        children: <Widget>[
                          orderDetailData.singOrderItem.status == '0'?SizedBox(width: 0.0,height: 0.0,):
                          Container(
                            height: 40.0,
                            width: 140.0,
                            child: RaisedButton(
                              child: Text("Receive".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.grey)),
                              onPressed: () async{

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Center(child:Text('Receive payment')),
                                          content:
                                          Container(
                                            height: 130,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Invoice amount : '),
                                                    SizedBox(width: 10,),
                                                    Text(orderDetailData.singOrderItem.invoiceAmount.toString())
                                                  ],
                                                ),
                                                SizedBox(height: 20.0,),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Due amount : '),
                                                    SizedBox(width: 10,),
                                                    Text(orderDetailData.singOrderItem.totalDue.toString())
                                                  ],
                                                ),
                                                SizedBox(height: 20.0,),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Received amount'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 120,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: receiveAmountController,
                                                        decoration: InputDecoration(hintText: '0.0',prefixIcon: Icon(Icons.attach_money)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Confirm'),
                                              onPressed: () async{
                                                if(receiveAmountController.text == '' || receiveAmountController.text == null){
                                                  Toast.show('Please enter received amount', context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                                                }else if(double.parse(receiveAmountController.text)>double.parse(orderDetailData.singOrderItem.totalDue)){
                                                  Toast.show('Please enter amount not higher than due amount', context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                                                }else{
                                                Map<String,dynamic> data = Map();
                                                // data.putIfAbsent('id', () => orderId.toString());
                                                data.putIfAbsent('accounts_group_id[0]', () => 16);
                                                data.putIfAbsent('amount[0]', () => receiveAmountController.text);
                                                data.putIfAbsent('receipt_amount', () => receiveAmountController.text);
                                                data.putIfAbsent('receipt_date', () => DateTime.now());
                                                data.putIfAbsent('comment', () => null);
                                                FormData formData = FormData.fromMap(data);
                                                var response = await Provider.of<Orders>(context, listen: false).receivePartialPayment(orderId.toString(),formData);
                                                receiveAmountController.text = '';
                                                if(response != null){
                                                  Toast.show(response['msg'], context,
                                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                }else{
                                                  Toast.show('something went wrong, please try again', context,
                                                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                }
                                                if(orderDetailData.singOrderItem.status == '1' || orderDetailData.singOrderItem.status == '4'){
                                                  Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
                                                }else{
                                                  Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
                                                }
                                                }
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        ));
                              },
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 20.0,),
                          orderDetailData.singOrderItem.status == '4' ? SizedBox(width: 0.0,height: 0.0,):
                          Container(
                            height: 40.0,
                            width: 140.0,
                            child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              child: Text("Cancel".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.grey)),
                              onPressed: () async{
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
                                                if(cancelCommentController.text == '' || cancelCommentController.text == null){
                                                  Toast.show('Please write your comment', context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                                                }else{
                                                var response = await Provider.of<Orders>(context, listen: false).cancelOrder(orderId.toString(), cancelCommentController.text);
                                                cancelCommentController.text = null;

                                                if(response != null){
                                                  Toast.show(response['msg'], context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                                }else{
                                                  Toast.show('Something went wrong, please try again.', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                                }
                                                if(orderDetailData.singOrderItem.status == '1' || orderDetailData.singOrderItem.status == '4'){
                                                  Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
                                                }else{
                                                  Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
                                                }
                                                }
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                          ],
                                        ));
                              },

                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ));
              }
            }
          },
        )
    );
  }


}

