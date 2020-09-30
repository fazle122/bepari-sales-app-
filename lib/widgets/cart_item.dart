// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sales_app/providers/cart.dart';
// import 'package:sales_app/providers/product.dart';
//
// class CartItemWidget extends StatefulWidget {
//   final String id;
//   final String productId;
//   final double price;
//   final int quantity;
//   final String title;
//   final int isNonInventory;
//   final double discount;
//   final String discountId;
//   final String discountType;
// //  final double perUnitDiscount;
//
//
//   CartItemWidget(this.id, this.productId, this.price, this.quantity,
//       this.title,this.isNonInventory,this.discount,this.discountId,this.discountType);
//
//   _CartItemWidgetState createState() => _CartItemWidgetState();
// }
//
// class _CartItemWidgetState extends State<CartItemWidget>{
//
//   @override
//   Widget build(BuildContext context) {
// //    final product = Provider.of<Product>(context, listen: false);
//     final cart = Provider.of<Cart>(context,listen: false);
//
//     return Dismissible(
//       key:ValueKey(widget.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         color: Theme.of(context).errorColor,
//         child: Icon(Icons.delete,color: Colors.white,size: 40,),
//         alignment: Alignment.centerRight,
//         padding: EdgeInsets.only(right: 20),
//         margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//       ),
//       confirmDismiss: (direction){
//         return   showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (context) => AlertDialog(
//               title: Text('Are you sure?'),
//               content: Text('Do you want to remove the item form the cart?'),
//               actions: <Widget>[
//                 FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
//                 FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);},),
//               ],
//             )
//         );
//       },
//       onDismissed: (direction){
//         Provider.of<Cart>(context,listen: false).removeCartItemRow(widget.productId);
//       },
//       child: Card(
//         margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//         child: Padding(
//           padding: EdgeInsets.all(8),
//           child: ListTile(
//             leading: CircleAvatar(
//               child: Padding(
//                 padding: EdgeInsets.all(5),
//                 child: FittedBox(
//                   child: Text('\$$widget.price'),
//                 ),
//               ),
//             ),
//             title: Text(widget.title),
//             subtitle: Text('Total : \$${(widget.price * widget.quantity)}'),
// //            trailing: Text('${(widget.quantity)}' + 'xx'),
//             trailing: Container(
//               width: 110.0,
//               child: widget.quantity != null ? Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.add),
//                     onPressed: (){
//                       cart.addItem(widget.productId, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
//                       Scaffold.of(context).hideCurrentSnackBar();
//                       if(cart.items.length> 0)
//                         Scaffold.of(context).showSnackBar(SnackBar(
//                           backgroundColor: cart.totalAmount > 500
//                               ? Theme.of(context).primaryColor
//                               : Colors.red[300],
//                           content: cart.totalAmount > 500
//                               ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                               child:Text('Delievry charge free'))
//                               : Row(
//                             children: <Widget>[
//                               Container(
//                                   decoration: BoxDecoration(
//                                       border: Border(
//                                           right: BorderSide(
//                                               color: Colors.white,
//                                               width: 1.0))),
//                                   width:
//                                   MediaQuery.of(context).size.width *
//                                       1 /
//                                       7,
//                                   child:
//                                   Text('Delivery charge \n50 BDT')),
//                               SizedBox(
//                                 width: 5.0,
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width *
//                                     4 /
//                                     7,
//                                 child: Text(
//                                     'Shop more for free delivery charge.'),
//                               )
//                             ],
//                           ),
//                           duration: Duration(seconds: 2),
//                         ));
//                     },
//                   ),
//                   Text(widget.quantity.toString(),style: TextStyle(fontSize: 20.0),),
//                   IconButton(
//                     icon: Icon(Icons.remove),
//                     onPressed: (){
//                       cart.removeSingleItem(widget.productId, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
//                       Scaffold.of(context).hideCurrentSnackBar();
//                       if(cart.items.length> 0)
//                         Scaffold.of(context).showSnackBar(SnackBar(
//                           backgroundColor: cart.totalAmount > 500
//                               ? Theme.of(context).primaryColor
//                               : Colors.red[300],
//                           content: cart.totalAmount > 500
//                               ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                               child:Text('Delievry charge free'))
//                               : Row(
//                             children: <Widget>[
//                               Container(
//                                   decoration: BoxDecoration(
//                                       border: Border(
//                                           right: BorderSide(
//                                               color: Colors.white,
//                                               width: 1.0))),
//                                   width:
//                                   MediaQuery.of(context).size.width *
//                                       1 /
//                                       7,
//                                   child:
//                                   Text('Delivery charge \n50 BDT')),
//                               SizedBox(
//                                 width: 5.0,
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width *
//                                     4 /
//                                     7,
//                                 child: Text(
//                                     'Shop more for free delivery charge.'),
//                               )
//                             ],
//                           ),
//                           duration: Duration(seconds: 2),
//                         ));
//                     },
//                   ),
//                 ],
//               ):IconButton(
//                 color: Theme.of(context).accentColor,
//                 icon: Icon(Icons.shopping_cart),
//                 onPressed: () {
//                   cart.addItem(widget.id, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
