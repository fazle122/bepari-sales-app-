import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/products.dart';
import 'package:sales_app/screens/product_detail_screen.dart';
import 'package:flushbar/flushbar.dart';


class ProductItemListView extends StatefulWidget {

//  final int quantity;
//  ProductItemListView(this.quantity);

  @override
  _ProductItemListViewState createState() => _ProductItemListViewState();

}

class _ProductItemListViewState extends State<ProductItemListView>{

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context);
    Map<String,dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);

    return Card(
        // shape: BeveledRectangleBorder(
        //   borderRadius:
        //   BorderRadius.all(Radius.circular(2.0)),
        // ),
        child:ListTile(
          leading: Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.imageUrl),
              width: MediaQuery.of(context).size.width * 0.6/5,
              fit: BoxFit.contain,
              placeholder: AssetImage('assets/products.png'),
            ),
          ),
          title:Text(
            product.title,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 15.0),
          ),
          subtitle: Text('BDT ' + product.price.toString(),style: TextStyle(fontSize: 12.0,color: Colors.red,fontWeight: FontWeight.bold),),
          trailing:
          Container(
            width: MediaQuery.of(context).size.width * 1.6/5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(product.unit,style: TextStyle(fontSize: 14.0,color: Colors.grey,)),
                ),
                newCartItem.keys.contains(product.id) ?
                Expanded(
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,size: 25.0,),
                          color:Colors.red,
                          onPressed: (){
                            cart.addItem(
                                product.id,
                                product.title,
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
                          },
                        ),
                        Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold,color:Colors.red),),
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,size: 25.0,),
                          color: Colors.red,
                          onPressed: (){
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ],
                    )
                ) :
                Container(
                    margin: EdgeInsets.only(top:5.0),
                    width: MediaQuery.of(context).size.width * 1/5,
                    height: MediaQuery.of(context).size.height * 1.2/30,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    child: InkWell(
                      child: Center(child:Text('Add to cart',style: TextStyle(fontSize: 12.0,color: Colors.white,fontWeight: FontWeight.bold),),),
                      onTap: () {
                        cart.addItem(
                            product.id,
                            product.title,
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
                      },
                    )
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
        ));
  }
}
