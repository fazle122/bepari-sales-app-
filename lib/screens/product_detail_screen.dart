import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/products.dart';


class ProductDetailScreen extends StatelessWidget {

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(context,listen:false).findById(productId);
    final cart = Provider.of<Cart>(context);
    Map<String,dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: double.infinity,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Padding(
              padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0, top: 48.0),
              child: Row(
                children: <Widget>[

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.black,
                          size: 28,
                        )
                    ),
                  ),

                ],
              ),
            ),

            Center(
              child: SizedBox(
                height: 170,
                child: Hero(
                  tag: loadedProduct.title,
                  child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,),
                ),
              ),
            ),

            SizedBox(
              height: 10.0,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Text(
                        loadedProduct.title ,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        loadedProduct.price.toString() + '/' + loadedProduct.unit,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(
                        height: 24.0,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              child: newCartItem.keys.contains(loadedProduct.id) ?
                              Row(
                                children: <Widget>[
                                  Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                      ),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.black,
                                        ),
                                        onTap: (){
                                          cart.addItem(
                                              loadedProduct.id,
                                              loadedProduct.title,
                                              // loadedProduct.productCategoryId,
                                              loadedProduct.unit,
                                              loadedProduct.price,
                                              loadedProduct.isNonInventory,
                                              loadedProduct.salesAccountsGroupId,
                                              loadedProduct.discount,
                                              loadedProduct.discountId,
                                              loadedProduct.discountType,
                                              loadedProduct.perUnitDiscount,
                                              loadedProduct.vatRate
                                          );

                                        },
                                      )
                                  ),

                                  Container(
                                    color: Colors.grey[200],
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child:Text(cart.items.firstWhere((d) => d.productId == loadedProduct.id).quantity.toString(),style: TextStyle(fontSize: 25.0),),
                                    ),
                                  ),

                                  Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.black,
                                        ),
                                        onTap: (){
                                          cart.removeSingleItem(loadedProduct.id);
                                        },
                                      )
                                  ),

                                ],
                              ):
                              Row(
                                children: <Widget>[
                                  Container(
                                      width: 70,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: (){
                                          cart.addItem(
                                              loadedProduct.id,
                                              loadedProduct.title,
                                              // loadedProduct.productCategoryId,
                                              loadedProduct.unit,
                                              loadedProduct.price,
                                              loadedProduct.isNonInventory,
                                              loadedProduct.salesAccountsGroupId,
                                              loadedProduct.discount,
                                              loadedProduct.discountId,
                                              loadedProduct.discountType,
                                              loadedProduct.perUnitDiscount,
                                              loadedProduct.vatRate
                                          );
                                        },
                                      )
                                  ),
                                ],
                              )
                          ),


                          Container(
                              child: Text(
                                newCartItem.keys.contains(loadedProduct.id) ?
                                '\$ ' + (loadedProduct.price.toDouble() * (cart.items.firstWhere((d) => d.productId == loadedProduct.id).quantity.toDouble())).toString() : '\$ 0.00',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                          ),

                        ],
                      ),

                      SizedBox(
                        height: 24.0,
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[

                              Text(
                                "Product description",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              loadedProduct.description != null ?Text(
                                loadedProduct.description,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(fontSize: 15.0),
                              ):Text('No description found'),

                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 24.0,
                      ),

//                      Row(
//                        children: <Widget>[
//
//                          Container(
//                            child: Container(
//                              height: 72,
//                              width: 72,
//                              decoration: BoxDecoration(
//                                color: Colors.white,
//                                borderRadius: BorderRadius.all(
//                                  Radius.circular(20),
//                                ),
//                                border: Border.all(
////                                  color: item.color,
//                                  width: 2,
//                                ),
//                              ),
//                              child: Icon(
//                                Icons.favorite,
////                                color: item.color,
//                                size: 36,
//                              ),
//                            ),
//                          ),
//
//                          SizedBox(
//                            width: 16,
//                          ),
//
//                          Expanded(
//                            child: Container(
//                              height: 72,
//                              decoration: BoxDecoration(
////                                color: item.color,
//                                borderRadius: BorderRadius.all(
//                                  Radius.circular(20),
//                                ),
//                              ),
//                              child: Center(
//                                child: Text(
//                                    "Add to cart",
//                                    style: TextStyle(
//                                      color: Colors.black,
//                                      fontWeight: FontWeight.bold,
//                                      fontSize: 18,
//                                    )
//                                ),
//                              ),
//                            ),
//                          )
//
//                        ],
//                      )

                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


