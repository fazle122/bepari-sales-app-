import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';


class ConfirmInvoiceDialog extends StatefulWidget {
  final FormData invoiceData;
  final invoiceStatus;
  final invoiceId;
  ConfirmInvoiceDialog(this.invoiceData,this.invoiceStatus,this.invoiceId);

  @override
  _ConfirmInvoiceDialogState createState() => _ConfirmInvoiceDialogState();
}

class _ConfirmInvoiceDialogState extends State<ConfirmInvoiceDialog>{


  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return AlertDialog(
      title: Center(child: Text('Confirm Invoice'),),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.invoiceStatus ==  null? Text('Are you sure to create invoice only?'):
              widget.invoiceStatus == 5 ? Text('Are you sure to create invoice with full payment?'):
                Text('Are you sure to create invoice with partial payment?'),
            SizedBox(height: 25.0,),
            Container(
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Confirm".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.grey)),
                onPressed: () async{
                  var response;
                  if(widget.invoiceId == null){
                    if(widget.invoiceStatus == null ) {
                      response = await Provider.of<Orders>(context, listen: false).createInvoice(widget.invoiceData);
                    }else{
                      response = await Provider.of<Orders>(context, listen: false).createInvoiceWithPayment(widget.invoiceData);
                    }
                  }else{
                    response = await Provider.of<Orders>(context, listen: false).updateInvoice(widget.invoiceData,widget.invoiceId);
                  }
                  if (response != null) {
                    await cart.clearCartTable();
                    Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
                    Flushbar(
                      duration: Duration(seconds: 10),
                      margin: EdgeInsets.only(bottom: 2),
                      padding: EdgeInsets.all(10),
                      borderRadius: 8,
                      backgroundColor: Colors.green.shade400,
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(3, 3),
                          blurRadius: 3,
                        ),
                      ],
                      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                      title: 'Order confirmation',
                      message: response['msg'],
                      mainButton: FlatButton(
                        child: Text('view order'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(OrderListScreen.routeName);
                        },
                      ),

                    )..show(context);
                  } else {
                    Flushbar(
                      duration: Duration(seconds: 5),
                      margin: EdgeInsets.only(bottom: 2),
                      padding: EdgeInsets.all(10),
                      borderRadius: 8,
                      backgroundColor: Colors.red.shade400,
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(3, 3),
                          blurRadius: 3,
                        ),
                      ],
                      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                      title: 'Order confirmation',
                      message: 'Something wrong. Please try again',
                    )..show(context);
                  }
                  Navigator.of(context).pop();
                },

              ),
            )
          ],
        ),
      ),
    );
  }

}