import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/product.dart';
import 'package:sales_app/providers/products.dart';
import 'package:sales_app/screens/product_detail_screen.dart';
import 'package:flushbar/flushbar.dart';

class ProductItemGridView extends StatefulWidget {


  @override
  _ProductItemGridView createState() => _ProductItemGridView();
}

class _ProductItemGridView extends State<ProductItemGridView> {
  var _isInit = true;
  var _isLoading = false;

//  @override
//  void didChangeDependencies(){
//    if(_isInit) {
//      if (!mounted) return;
//      setState(() {
//        _isLoading = true;
//      });
//      Provider.of<Cart>(context).fetchAndSetCartItems().then((_){
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }



  Widget _showFlushbar(BuildContext context,Cart cart) {
          Flushbar(
          duration: Duration(seconds: 3),
          margin: EdgeInsets.only(bottom: 50),
          padding: EdgeInsets.all(10),
          borderRadius: 8,
          backgroundColor: cart.totalAmount > 500 ? Colors.green.shade400:Colors.red.shade300,
//              backgroundGradient: LinearGradient(
//              colors: [Colors.green.shade400, Colors.greenAccent.shade700],
//              stops: [0.6, 1],
//              ),
          boxShadows: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(3, 3),
              blurRadius: 3,
            ),
          ],
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
          title: cart.totalAmount > 500 ? 'Delivery charge free' : 'Delivery charge \n50 BDT',
          message: cart.totalAmount > 500 ? ' ' : 'Shop more for free delivery charge.',
        )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    var cart = Provider.of<Cart>(context);
    Map<String, dynamic> newCartItem = Map.fromIterable(cart.items,
        key: (v) => v.productId, value: (v) => v.quantity);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                product.title,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    r"$ " + product.price.toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    '/' + product.unit,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                  child: Hero(
                tag: product.id,
                child: FadeInImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/products.png'),
                ),
              )),
              SizedBox(
                height: 8.0,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: newCartItem.keys.contains(product.id)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  child: Icon(
                                    Icons.add,
                                    size: 22,
                                  ),
                                  onTap: () async{
                                    await cart.addItem(
                                        product.id,
                                        product.title,
                                        // product.productCategoryId,
                                        product.unit,
                                        product.price,
                                        product.isNonInventory,
                                        product.salesAccountsGroupId,
                                        product.discount,
                                        product.discountId,
                                        product.discountType,
                                        product.perUnitDiscount,
                                        product.vatRate

                                    );

                                    Future.delayed(Duration(milliseconds: 200)).then((_) {
                                      if(cart.items.length>0)
                                        _showFlushbar(context,cart);
                                    } );







//                                      _showFlushbar(
//                                        context
//                                        cart.totalAmount > 500
//                                            ? 'Delivery charge free'
//                                            : 'Delivery charge \n50 BDT',
//                                        cart.totalAmount > 500
//                                            ? ' '
//                                            : 'Shop more for free delivery charge.',
//                                        cart.totalAmount > 500
//                                            ? Colors.green.shade400
//                                            : Colors.red.shade300,
//                                      );



//                              Scaffold.of(context).hideCurrentSnackBar();
//                                Scaffold.of(context).showSnackBar(SnackBar(
//                                  backgroundColor: cart.totalAmount > 500
//                                      ? Theme
//                                      .of(context)
//                                      .primaryColor
//                                      : Colors.red[300],
//                                  content: cart.totalAmount > 500
//                                      ? Container(
//                                      padding: EdgeInsets.only(
//                                          top: 5.0, bottom: 5.0),
//                                      child: Text('Delievry charge free'))
//                                      : Row(
//                                    children: <Widget>[
//                                      Container(
//                                          decoration: BoxDecoration(
//                                              border: Border(
//                                                  right: BorderSide(
//                                                      color: Colors.white,
//                                                      width: 1.0))),
//                                          width: MediaQuery
//                                              .of(context)
//                                              .size
//                                              .width *
//                                              1 /
//                                              7,
//                                          child: Text(
//                                              'Delivery charge \n50 BDT')),
//                                      SizedBox(
//                                        width: 5.0,
//                                      ),
//                                      Container(
//                                        width: MediaQuery
//                                            .of(context)
//                                            .size
//                                            .width *
//                                            4 /
//                                            7,
//                                        child: Text(
//                                            'Shop more for free delivery charge.'),
//                                      )
//                                    ],
//                                  ),
//                                  duration: Duration(seconds: 2),
//                                ));
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
//                          padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                      cart.items
                                          .firstWhere(
                                              (d) => d.productId == product.id)
                                          .quantity
                                          .toString(),
                                      style: TextStyle(fontSize: 20.0)),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.remove,
                                    size: 22,
                                  ),
                                  onTap: () async{
                                    await cart.removeSingleItem(product.id);

                                    Future.delayed(Duration(milliseconds: 200)).then((_) {
                                      if(cart.items.length>0)
                                        _showFlushbar(context,cart);
                                    } );

//                                    Scaffold.of(context).hideCurrentSnackBar();
//                                Scaffold.of(context).showSnackBar(SnackBar(
//                                  backgroundColor: cart.totalAmount > 500
//                                      ? Theme.of(context).primaryColor
//                                      : Colors.red[300],
//                                  content: cart.totalAmount > 500
//                                      ? Container(
//                                      padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                                      child:Text('Delievry charge free'))
//                                      : Row(
//                                    children: <Widget>[
//                                      Container(
//                                          decoration: BoxDecoration(
//                                              border: Border(
//                                                  right: BorderSide(
//                                                      color: Colors.white,
//                                                      width: 1.0))),
//                                          width: MediaQuery.of(context).size.width *
//                                              1 /
//                                              7,
//                                          child: Text('Delivery charge \n50 BDT')),
//                                      SizedBox(
//                                        width: 5.0,
//                                      ),
//                                      Container(
//                                        width: MediaQuery.of(context).size.width *
//                                            4 /
//                                            7,
//                                        child: Text(
//                                            'Shop more for free delivery charge.'),
//                                      )
//                                    ],
//                                  ),
//                                  duration: Duration(seconds: 2),
//                                ));
                                  },
                                )
                              ],
                            )
                          : InkWell(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Add to cart",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Icon(
                                    Icons.add_shopping_cart,
                                    color: Theme.of(context).accentColor,
                                    size: 22,
                                  )
                                ],
                              ),
                              onTap: () async{
                                await cart.addItem(
                                    product.id,
                                    product.title,
                                    // product.productCategoryId,
                                    product.unit,
                                    product.price,
                                    product.isNonInventory,
                                    product.salesAccountsGroupId,
                                    product.discount,
                                    product.discountId,
                                    product.discountType,
                                    product.perUnitDiscount,
                                    product.vatRate
                                );

                                    Future.delayed(Duration(milliseconds: 200)).then((_) {
                                      if(cart.items.length>0)
                                        _showFlushbar(context,cart);
                                } );
                              },
                            )))
            ],
          ),
        ),
      ),
    );
  }

//    return ClipRRect(
//        borderRadius: BorderRadius.circular(10),
//        child: GridTile(
//          child: GestureDetector(
//              onTap: () {
//                Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
//                    arguments: product.id);
//              },
//              child: Hero(
//                tag: product.id,
//                child: FadeInImage(
//                  image: NetworkImage(product.imageUrl),
//                  fit: BoxFit.cover,
//                  placeholder: AssetImage('assets/products.png'),
//                ),
//              )),
//          footer: Container(
//            height: 80,
//            color: Colors.black54,
//            child:
//            Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//
//               Flexible(child: Container(
//                 padding: EdgeInsets.all(5.0),
//                 child: Text(product.title,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15.0,color: Colors.white),),
//               ),),
//
//                Container(
//                  child:Text(
//                    'BDT ' + product.price.toString() + '/' + product.unit,
//                    textAlign: TextAlign.start,
//                    style: TextStyle(fontSize: 12.0,color: Colors.white),
//                  ),
//                ),
//                    Container(height: 30,
//                    padding: EdgeInsets.only(bottom: 5),
//                    child:newCartItem.keys.contains(product.id)?
//                    Row(
//                      mainAxisSize: MainAxisSize.min,
//                      children: <Widget>[
//                        IconButton(
//                          icon: Icon(Icons.add,color: Colors.white,),
//                          onPressed: (){
//                            cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//                            Scaffold.of(context).hideCurrentSnackBar();
//                            if(cart.items.length> 0)
//                              Scaffold.of(context).showSnackBar(SnackBar(
//                                backgroundColor: cart.totalAmount > 500
//                                    ? Theme.of(context).primaryColor
//                                    : Colors.red[300],
//                                content: cart.totalAmount > 500
//                                    ? Container(
//                                    padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                                    child:Text('Delievry charge free'))
//                                    : Row(
//                                  children: <Widget>[
//                                    Container(
//                                        decoration: BoxDecoration(
//                                            border: Border(
//                                                right: BorderSide(
//                                                    color: Colors.white,
//                                                    width: 1.0))),
//                                        width: MediaQuery.of(context).size.width *
//                                            1 /
//                                            7,
//                                        child: Text('Delivery charge \n50 BDT')),
//                                    SizedBox(
//                                      width: 5.0,
//                                    ),
//                                    Container(
//                                      width: MediaQuery.of(context).size.width *
//                                          4 /
//                                          7,
//                                      child: Text(
//                                          'Shop more for free delivery charge.'),
//                                    )
//                                  ],
//                                ),
//                                duration: Duration(seconds: 2),
//                              ));
//                          },
//                        ),
//
//                        Container(
//                          padding: EdgeInsets.only(top: 7),
//                          child: Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),
//                              style: TextStyle(
//                                fontSize: 20.0,color: Colors.white
//                              )),
//                        ),
//
//                        IconButton(
//                          icon: Icon(Icons.remove,color: Colors.white,),
//                          onPressed: () {
//                            cart.removeSingleItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//                            Scaffold.of(context).hideCurrentSnackBar();
//                            if(cart.items.length> 0)
//                              Scaffold.of(context).showSnackBar(SnackBar(
//                                backgroundColor: cart.totalAmount > 500
//                                    ? Theme.of(context).primaryColor
//                                    : Colors.red[300],
//                                content: cart.totalAmount > 500
//                                    ? Container(
//                                    padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                                    child:Text('Delievry charge free'))
//                                    : Row(
//                                  children: <Widget>[
//                                    Container(
//                                        decoration: BoxDecoration(
//                                            border: Border(
//                                                right: BorderSide(
//                                                    color: Colors.white,
//                                                    width: 1.0))),
//                                        width: MediaQuery.of(context).size.width *
//                                            1 /
//                                            7,
//                                        child: Text('Delivery charge \n50 BDT')),
//                                    SizedBox(
//                                      width: 5.0,
//                                    ),
//                                    Container(
//                                      width: MediaQuery.of(context).size.width *
//                                          4 /
//                                          7,
//                                      child: Text(
//                                          'Shop more for free delivery charge.'),
//                                    )
//                                  ],
//                                ),
//                                duration: Duration(seconds: 2),
//                              ));
//                          },
//                        ),
//                      ],):
//                    Container(
////                  padding: EdgeInsets.only(bottom: 5),
//                      height: 40,
//                      child: IconButton(
//                        color: Theme.of(context).accentColor,
//                        icon: Icon(Icons.shopping_cart),
//                        onPressed: () {
//                          cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//                          Scaffold.of(context).hideCurrentSnackBar();
//                          if(cart.items.length> 0)
//                            Scaffold.of(context).showSnackBar(SnackBar(
//                              backgroundColor: cart.totalAmount > 500
//                                  ? Theme.of(context).primaryColor
//                                  : Colors.red[300],
//                              content: cart.totalAmount > 500
//                                  ? Container(
//                                  padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                                  child:Text('Delievry charge free'))
//                                  : Row(
//                                children: <Widget>[
//                                  Container(
//                                      decoration: BoxDecoration(
//                                          border: Border(
//                                              right: BorderSide(
//                                                  color: Colors.white,
//                                                  width: 1.0))),
//                                      width: MediaQuery.of(context).size.width *
//                                          1 /
//                                          7,
//                                      child: Text('Delivery charge \n50 BDT')),
//                                  SizedBox(
//                                    width: 5.0,
//                                  ),
//                                  Container(
//                                    width: MediaQuery.of(context).size.width *
//                                        4 /
//                                        7,
//                                    child: Text(
//                                        'Shop more for free delivery charge.'),
//                                  )
//                                ],
//                              ),
//                              duration: Duration(seconds: 2),
////              action: SnackBarAction(
////                label: 'undo',
////                onPressed: (){
////                  cart.removeSingleItem(product.id);
////                },
////              ),
//                            ));
//                        },
//                      ),
//                    ))
//                ,
//
//              ],
//            ),
//          )
//
////          GridTileBar(
////
////            backgroundColor: Colors.black54,
////            title:
////            Column(
////              mainAxisAlignment: MainAxisAlignment.center,
////              crossAxisAlignment: CrossAxisAlignment.center,
////              children: <Widget>[
//////                Text(
//////                  product.title,
//////                  textAlign: TextAlign.start,
//////                  style: TextStyle(fontSize: 15.0),
//////                ),
////
//////                !newCartItem.keys.contains(product.id)
//////                    ? Text(
//////                        'BDT ' + product.price.toString() + '/' + product.unit,
//////                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
//////                      )
//////                    : SizedBox(
//////                        width: 0.0,
//////                        height: 0.0,
//////                      ),
////////                newCartItem.keys.contains(product.id)
////////                    ? Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),
////////                    style: TextStyle(
////////                      fontSize: 15.0,
////////                    ))
////////                    : SizedBox(
////////                  width: 0.0,
////////                  height: 0.0,
////////                ),
////                newCartItem.keys.contains(product.id)?
////                Row(
////                  mainAxisSize: MainAxisSize.min,
////                  children: <Widget>[
////                    IconButton(
////                      icon: Icon(Icons.add),
////                      onPressed: (){
////                        cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
////                        Scaffold.of(context).hideCurrentSnackBar();
////                        if(cart.items.length> 0)
////                          Scaffold.of(context).showSnackBar(SnackBar(
////                            backgroundColor: cart.totalAmount > 500
////                                ? Theme.of(context).primaryColor
////                                : Colors.red[300],
////                            content: cart.totalAmount > 500
////                                ? Container(
//////                                padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
////                                child:Text('Delievry charge free'))
////                                : Row(
////                              children: <Widget>[
////                                Container(
////                                    decoration: BoxDecoration(
////                                        border: Border(
////                                            right: BorderSide(
////                                                color: Colors.white,
////                                                width: 1.0))),
////                                    width: MediaQuery.of(context).size.width *
////                                        1 /
////                                        7,
////                                    child: Text('Delivery charge \n50 BDT')),
////                                SizedBox(
////                                  width: 5.0,
////                                ),
////                                Container(
////                                  width: MediaQuery.of(context).size.width *
////                                      4 /
////                                      7,
////                                  child: Text(
////                                      'Shop more for free delivery charge.'),
////                                )
////                              ],
////                            ),
////                            duration: Duration(seconds: 2),
////                          ));
////                      },
////                    ),
////
////                    Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),
////                        style: TextStyle(
////                          fontSize: 15.0,
////                        )),
////
////                    IconButton(
////                      icon: Icon(Icons.remove),
////                      onPressed: () {
////                        cart.removeSingleItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
////                        Scaffold.of(context).hideCurrentSnackBar();
////                        if(cart.items.length> 0)
////                          Scaffold.of(context).showSnackBar(SnackBar(
////                            backgroundColor: cart.totalAmount > 500
////                                ? Theme.of(context).primaryColor
////                                : Colors.red[300],
////                            content: cart.totalAmount > 500
////                                ? Container(
//////                                padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
////                                child:Text('Delievry charge free'))
////                                : Row(
////                              children: <Widget>[
////                                Container(
////                                    decoration: BoxDecoration(
////                                        border: Border(
////                                            right: BorderSide(
////                                                color: Colors.white,
////                                                width: 1.0))),
////                                    width: MediaQuery.of(context).size.width *
////                                        1 /
////                                        7,
////                                    child: Text('Delivery charge \n50 BDT')),
////                                SizedBox(
////                                  width: 5.0,
////                                ),
////                                Container(
////                                  width: MediaQuery.of(context).size.width *
////                                      4 /
////                                      7,
////                                  child: Text(
////                                      'Shop more for free delivery charge.'),
////                                )
////                              ],
////                            ),
////                            duration: Duration(seconds: 2),
////                          ));
////                      },
////                    ),
////                  ],):IconButton(
////                  color: Theme.of(context).accentColor,
////                  icon: Icon(Icons.shopping_cart),
////                  onPressed: () {
////                    cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
////                    Scaffold.of(context).hideCurrentSnackBar();
////                    if(cart.items.length> 0)
////                      Scaffold.of(context).showSnackBar(SnackBar(
////                        backgroundColor: cart.totalAmount > 500
////                            ? Theme.of(context).primaryColor
////                            : Colors.red[300],
////                        content: cart.totalAmount > 500
////                            ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
////                            child:Text('Delievry charge free'))
////                            : Row(
////                          children: <Widget>[
////                            Container(
////                                decoration: BoxDecoration(
////                                    border: Border(
////                                        right: BorderSide(
////                                            color: Colors.white,
////                                            width: 1.0))),
////                                width: MediaQuery.of(context).size.width *
////                                    1 /
////                                    7,
////                                child: Text('Delivery charge \n50 BDT')),
////                            SizedBox(
////                              width: 5.0,
////                            ),
////                            Container(
////                              width: MediaQuery.of(context).size.width *
////                                  4 /
////                                  7,
////                              child: Text(
////                                  'Shop more for free delivery charge.'),
////                            )
////                          ],
////                        ),
////                        duration: Duration(seconds: 2),
//////              action: SnackBarAction(
//////                label: 'undo',
//////                onPressed: (){
//////                  cart.removeSingleItem(product.id);
//////                },
//////              ),
////                      ));
////                  },
////                ),
////
////              ],
////            )
////
//////            leading:
//////            newCartItem.keys.contains(product.id)
//////                ?
//////            IconButton(
//////              icon: Icon(Icons.add),
//////              onPressed: (){
//////                cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//////                Scaffold.of(context).hideCurrentSnackBar();
//////                if(cart.items.length> 0)
//////                  Scaffold.of(context).showSnackBar(SnackBar(
//////                    backgroundColor: cart.totalAmount > 500
//////                        ? Theme.of(context).primaryColor
//////                        : Colors.red[300],
//////                    content: cart.totalAmount > 500
//////                        ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//////                    child:Text('Delievry charge free'))
//////                        : Row(
//////                      children: <Widget>[
//////                        Container(
//////                            decoration: BoxDecoration(
//////                                border: Border(
//////                                    right: BorderSide(
//////                                        color: Colors.white,
//////                                        width: 1.0))),
//////                            width: MediaQuery.of(context).size.width *
//////                                1 /
//////                                7,
//////                            child: Text('Delivery charge \n50 BDT')),
//////                        SizedBox(
//////                          width: 5.0,
//////                        ),
//////                        Container(
//////                          width: MediaQuery.of(context).size.width *
//////                              4 /
//////                              7,
//////                          child: Text(
//////                              'Shop more for free delivery charge.'),
//////                        )
//////                      ],
//////                    ),
//////                    duration: Duration(seconds: 2),
//////                  ));
//////              },
//////            ) : SizedBox(
//////                    width: 0.0,
//////                    height: 0.0,
//////                  ),
//////            trailing:
//////            newCartItem.keys.contains(product.id)
//////                ? IconButton(
//////                    icon: Icon(Icons.remove),
//////                    onPressed: () {
//////                      cart.removeSingleItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//////                      Scaffold.of(context).hideCurrentSnackBar();
//////                      if(cart.items.length> 0)
//////                        Scaffold.of(context).showSnackBar(SnackBar(
//////                        backgroundColor: cart.totalAmount > 500
//////                            ? Theme.of(context).primaryColor
//////                            : Colors.red[300],
//////                        content: cart.totalAmount > 500
//////                            ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//////                            child:Text('Delievry charge free'))
//////                            : Row(
//////                                children: <Widget>[
//////                                  Container(
//////                                      decoration: BoxDecoration(
//////                                          border: Border(
//////                                              right: BorderSide(
//////                                                  color: Colors.white,
//////                                                  width: 1.0))),
//////                                      width: MediaQuery.of(context).size.width *
//////                                          1 /
//////                                          7,
//////                                      child: Text('Delivery charge \n50 BDT')),
//////                                  SizedBox(
//////                                    width: 5.0,
//////                                  ),
//////                                  Container(
//////                                    width: MediaQuery.of(context).size.width *
//////                                        4 /
//////                                        7,
//////                                    child: Text(
//////                                        'Shop more for free delivery charge.'),
//////                                  )
//////                                ],
//////                              ),
//////                        duration: Duration(seconds: 2),
//////                      ));
//////                    },
//////                  )
//////                : IconButton(
//////                    color: Theme.of(context).accentColor,
//////                    icon: Icon(Icons.shopping_cart),
//////                    onPressed: () {
//////                      cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
//////                      Scaffold.of(context).hideCurrentSnackBar();
//////                      if(cart.items.length> 0)
//////                        Scaffold.of(context).showSnackBar(SnackBar(
//////                        backgroundColor: cart.totalAmount > 500
//////                            ? Theme.of(context).primaryColor
//////                            : Colors.red[300],
//////                        content: cart.totalAmount > 500
//////                            ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//////                            child:Text('Delievry charge free'))
//////                            : Row(
//////                                children: <Widget>[
//////                                  Container(
//////                                      decoration: BoxDecoration(
//////                                          border: Border(
//////                                              right: BorderSide(
//////                                                  color: Colors.white,
//////                                                  width: 1.0))),
//////                                      width: MediaQuery.of(context).size.width *
//////                                          1 /
//////                                          7,
//////                                      child: Text('Delivery charge \n50 BDT')),
//////                                  SizedBox(
//////                                    width: 5.0,
//////                                  ),
//////                                  Container(
//////                                    width: MediaQuery.of(context).size.width *
//////                                        4 /
//////                                        7,
//////                                    child: Text(
//////                                        'Shop more for free delivery charge.'),
//////                                  )
//////                                ],
//////                              ),
//////                        duration: Duration(seconds: 2),
////////              action: SnackBarAction(
////////                label: 'undo',
////////                onPressed: (){
////////                  cart.removeSingleItem(product.id);
////////                },
////////              ),
//////                      ));
//////                    },
//////                  ),
////          ),
//        ));
//  }
}
