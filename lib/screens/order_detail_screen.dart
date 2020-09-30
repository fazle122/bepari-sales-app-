import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


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

  @override
  void initState() {

    commentController = TextEditingController();
    deliveryCommentController = TextEditingController();
    cancelCommentController = TextEditingController();
    dueAmountController = TextEditingController();
    paidAmountController = TextEditingController();
    receiveAmountController = TextEditingController();
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
//                          title: Text('Total amount:  ' + 'BDT\$${(orderDetailData.singOrderItem.totalDue.toString())}'),
                          title: Text('Total amount:  ' + orderDetailData.singOrderItem.totalDue.toString() + ' BDT'),
                          subtitle: Text(
                            DateFormat('EEEE, MMM d, ').format(orderDetailData.singOrderItem.dateTime) +
                                convert12(DateFormat('hh:mm').format(orderDetailData.singOrderItem.dateTime)),
                          ),
                        )
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: orderDetailData.singOrderItem.invoiceItem.length,
                          itemBuilder: (context, i) => ListTile(
                            title: Text('Item name:' + orderDetailData.singOrderItem.invoiceItem[i].productName),
                            subtitle: ListTile(
                              title: Text('Quantity:'  + orderDetailData.singOrderItem.invoiceItem[i].quantity.toString()),
//                              subtitle: Text(
//                                  'price:' + orderDetailData.singOrderItem.invoiceItem[i].quantity.toString() + 'x'
//                                      + orderDetailData.singOrderItem.invoiceItem[i].unitPrice.toString()  + ' = '
//                                      + (orderDetailData.singOrderItem.invoiceItem[i].quantity * orderDetailData.singOrderItem.invoiceItem[i].unitPrice).toString()
//                                      + ' BDT'
//
//                              ),
                            ),
                          ),
                        )
                    ),
                    Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: orderDetailData.singOrderItem.status == null? MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                        children: <Widget>[
                          orderDetailData.singOrderItem.status == '0' ?
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
                                              child: Text('Paid'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(false);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Finished'),
                                              onPressed: () async{
                                                await Provider.of<Orders>(context, listen: false).cancelOrder(orderId.toString(), cancelCommentController.text);
                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                    builder: (context) => OrderListScreen()
                                                ));
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
                          orderDetailData.singOrderItem.status == '0' ?
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
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Center(child:Text(
                                              'Sold with due')),
                                          content:
                                          Container(
                                            height: 150,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Amount'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 150,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: paidAmountController,
                                                        decoration: InputDecoration(hintText: 'enter order amount'),
                                                      ),
                                                    )
                                                  ],
                                                ),
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
                                                        controller: deliveryCommentController,
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
                                              child: Text('Paid'),
                                              onPressed: () async{
                                                await Provider.of<Orders>(context, listen: false).deliverOrder(orderId.toString(), deliveryCommentController.text,double.parse(paidAmountController.text),null);
                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                  builder: (context) => OrderListScreen()
                                                ));
                                                },
                                            ),
                                            FlatButton(
                                              child: Text('Finished'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(true);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Save'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(true);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Pay later'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(true);
                                              },
                                            ),
                                          ],
                                        ));
                              },
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                            ),
                          ):SizedBox(width: 0.0,height: 0.0,),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: orderDetailData.singOrderItem.status == null? MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                        children: <Widget>[
                          orderDetailData.singOrderItem.status == '0' || orderDetailData.singOrderItem.status == '2'?
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
                                            height: 150,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Due amount'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 150,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: dueAmountController,
                                                        decoration: InputDecoration(hintText: 'enter due amount'),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Paid amount'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 150,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: paidAmountController,
                                                        decoration: InputDecoration(hintText: 'enter paid amount'),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Receive amount'),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      width: 150,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: receiveAmountController,
                                                        decoration: InputDecoration(hintText: 'enter receive amount'),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Continue'),
                                              onPressed: () async{
                                                await Provider.of<Orders>(context, listen: false).deliverOrder(orderId.toString(), deliveryCommentController.text,double.parse(receiveAmountController.text),null);
                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                    builder: (context) => OrderListScreen()
                                                ));
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(true);
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
                          orderDetailData.singOrderItem.status == '0' || orderDetailData.singOrderItem.status == '2'?
                          Container(
                            height: 40.0,
                            width: 140.0,
                            child: RaisedButton(
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
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop(false);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Confirm'),
                                              onPressed: () async{
                                                await Provider.of<Orders>(context, listen: false).cancelOrder(orderId.toString(), cancelCommentController.text);
                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                    builder: (context) => OrderListScreen()
                                                ));
                                              },
                                            ),
                                          ],
                                        ));
                              },
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              child: Text("Cancel".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ):SizedBox(width: 0.0,height: 0.0,),
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

