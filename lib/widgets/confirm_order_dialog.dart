import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';


class ConfirmOrderDialog extends StatefulWidget {

  @override
  _ConfirmOrderDialogState createState() => _ConfirmOrderDialogState();
}

class _ConfirmOrderDialogState extends State<ConfirmOrderDialog>{

  TextEditingController _phoneEditController;
  TextEditingController _mailEditController;
  TextEditingController _addressEditController;

  @override
  void initState(){
//    _phoneEditController.text = '+88-01797512457';
    super.initState();
  }


  Widget phoneField(data) {
    return TextField(
      controller: _phoneEditController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.phone),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }

  Widget mailField(data) {
    return TextField(
      controller: _mailEditController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.mail),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }

  Widget addressField(data) {
    return TextField(
      controller: _addressEditController,
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.home),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return AlertDialog(
      title: Center(child: Text('Confirm Address'),),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
//            ListTile(
//              leading: Icon(Icons.phone),
//              title: Text('+88-01797512457'),
//              onTap: (){
//              },
//            ),
            phoneField('+88-01797512457'),
            SizedBox(height: 15.0,),
            mailField('test@gmail.com'),
            SizedBox(height: 15.0,),
            addressField('76/3, Block-g, Road-2 \nUttora, Dhaka'),
            SizedBox(height: 25.0,),
            Container(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.grey)),
                onPressed: () {
//                  Provider.of<Orders>(context, listen: false).addOrder(
//                      cart.items.values.toList(), cart.totalAmount);
//                  cart.clear();
                  Navigator.of(context).pop();
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Confirm".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
              ),
            )
          ],
        ),
      ),
    );
  }

}