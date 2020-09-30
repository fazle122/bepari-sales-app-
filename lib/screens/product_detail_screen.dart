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

                              loadedProduct.description.isNotEmpty?Text(
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



///----------------------- test code ----------------------------------



//LinearGradient kGradient = LinearGradient(
//  begin: Alignment.topLeft,
//  end: Alignment.bottomCenter,
//  stops: [0.1, 0.3, 0.5, 0.9],
//  colors: [
//    Color(0xFF82AE55),
//    Color(0xFF65A34E),
//    Color(0xFF39874B),
//    Color(0xFF307B40),
//  ],
//);
//
//Color kStarsColor = Color(0xFFFEB67C);
//Color kGreen = Color(0xFF307B40);



//class ProductDetailScreen extends StatelessWidget {
//  static const routeName = '/product-detail';
//
////  final Perfume perfume;
//
////  Detail({@required this.perfume});
//
////  @override
////  _ProductDetailScreenState createState() => _ProductDetailScreenState();
////}
////
////class _ProductDetailScreenState extends State<ProductDetailScreen> {
//
//  int _currentImage = 0;
//
//  List<Widget> buildPageIndicator(Product loadedProduct){
//    List<Widget> list = [];
//    for (var i = 0; i < loadedProduct.imageUrl.length; i++) {
//      list.add(i == _currentImage ? buildIndicator(true) : buildIndicator(false));
//    }
//    return list;
//  }
//
//  Widget buildIndicator(bool isActive){
//    return AnimatedContainer(
//      duration: Duration(milliseconds: 150),
//      margin: EdgeInsets.symmetric(horizontal: 6.0),
//      height: 8.0,
//      width: isActive ? 20.0 : 8.0,
//      decoration: BoxDecoration(
//        color: isActive ? Colors.white : Colors.grey[400],
//        borderRadius: BorderRadius.all(
//          Radius.circular(12),
//        ),
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final productId = ModalRoute.of(context).settings.arguments as String;
//    final loadedProduct = Provider.of<Products>(context,listen:false).findById(productId);
//    final cart = Provider.of<Cart>(context);
//    Map<String,dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);
//
//    Size size = MediaQuery.of(context).size;
//    return Scaffold(
//      extendBodyBehindAppBar: true,
//      appBar: AppBar(
//        backgroundColor: Colors.transparent,
//        elevation: 0,
//        leading: GestureDetector(
//          onTap: () {
//            Navigator.pop(context);
//          },
//          child: Icon(
//            Icons.keyboard_arrow_left,
//            size: 32,
//            color: Colors.black,
//          ),
//        ),
//        actions: <Widget>[
////          Padding(
////            padding: EdgeInsets.only(right: 16.0),
////            child: GestureDetector(
////              onTap: () {
////                setState(() {
////                  widget.perfume.favorite = !widget.perfume.favorite;
////                });
////              },
////              child: Icon(
////                widget.perfume.favorite ? Icons.favorite : Icons.favorite_border,
////                size: 32,
////                color: Colors.black,
////              ),
////            ),
////          ),
//        ],
//      ),
//      body: Container(
//        decoration: BoxDecoration(
//          gradient: kGradient,
//        ),
//        child: SafeArea(
//          child: Column(
//            children: <Widget>[
//              Container(
//              padding: EdgeInsets.all(10),
//              height: 320,width:250,child: Hero(
//              tag:loadedProduct.id,
//              child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,),
//            ),),
////              Expanded(
////                child: Hero(
////                  tag: loadedProduct.title,
////                  child: Image.asset(
////                    loadedProduct.imageUrl,
////                    fit: BoxFit.fitHeight,
////                  ),
////                ),
////              ),
//
//
//////              Expanded(
//////                child: PageView(
//////                  physics: BouncingScrollPhysics(),
//////                  onPageChanged: (int page){
//////                    setState(() {
//////                      _currentImage = page;
//////                    });
//////                  },
//////                  children: widget.perfume.images.map((path) {
//////                    return Container(
//////                      child: Hero(
//////                        tag: widget.perfume.name,
//////                        child: Image.asset(
//////                          path,
//////                          fit: BoxFit.fitHeight,
//////                        ),
//////                      ),
//////                    );
//////                  }).toList(),
//////                ),
//////              ),
////
////              loadedProduct.imageUrl.length > 0
////                  ? Container(
////                height: size.height * 0.1,
////                child: Row(
////                  mainAxisAlignment: MainAxisAlignment.center,
////                  children: buildPageIndicator(loadedProduct),
////                ),
////              )
////                  : Container(
////                height: size.height * 0.05,
////              ),
//
//              Container(
//                height: size.height * 0.4,
//                decoration: BoxDecoration(
//                    color: Colors.white,
//                    borderRadius: BorderRadius.only(
//                      topLeft: Radius.circular(40),
//                      topRight: Radius.circular(40),
//                    )
//                ),
//                child: Column(
//                  children: <Widget>[
//
//                    Container(
//                      height: size.height * 0.3,
//                      padding: EdgeInsets.all(32),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//
//                          Text(
//                            loadedProduct.title,
//                            style: TextStyle(
//                              fontSize: 20,
//                              color: Colors.black,
//                              fontWeight: FontWeight.bold,
//                            ),
//                          ),
//
//                          SizedBox(
//                            height: 8,
//                          ),
//
//
//
//
//                          Expanded(
//                            child: Container(),
//                          ),
//
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            crossAxisAlignment: CrossAxisAlignment.end,
//                            children: <Widget>[
//
//                              Text(
//                                "€ " + '22',
//                                style: TextStyle(
//                                  fontSize: 28,
//                                  color: kGreen,
//                                  fontWeight: FontWeight.bold,
//                                ),
//                              ),
//
//                              Column(
//                                crossAxisAlignment: CrossAxisAlignment.end,
//                                children: <Widget>[
//
//                                  Text(
//                                    "48 reviews",
//                                    style: TextStyle(
//                                      fontSize: 16,
//                                      color: Colors.grey[400],
//                                    ),
//                                  ),
//
//                                  Row(
//                                    children: <Widget>[
//
//                                      Icon(
//                                        Icons.star,
//                                        size: 28,
//                                        color: kStarsColor,
//                                      ),
//
//                                      Icon(
//                                        Icons.star,
//                                        size: 28,
//                                        color: kStarsColor,
//                                      ),
//
//                                      Icon(
//                                        Icons.star,
//                                        size: 28,
//                                        color: kStarsColor,
//                                      ),
//
//                                      Icon(
//                                        Icons.star,
//                                        size: 28,
//                                        color: kStarsColor,
//                                      ),
//
//                                      Icon(
//                                        Icons.star_half,
//                                        size: 28,
//                                        color: kStarsColor,
//                                      ),
//
//                                    ],
//                                  )
//
//                                ],
//                              ),
//
//                            ],
//                          ),
//
//                          loadedProduct.description.isNotEmpty?Text(
//                            loadedProduct.description,
//                            textAlign: TextAlign.center,
//                            softWrap: true,
//                            style: TextStyle(fontSize: 15.0),
//                          ):Text('No description found'),
//                        ],
//                      ),
//                    ),
//
//                    Container(
//                      height: size.height * 0.1,
//                      width: MediaQuery.of(context).size.width,
//                      decoration: BoxDecoration(
//                          color: Colors.black,
//                          borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(40),
//                            topRight: Radius.circular(40),
//                          )
//                      ),
////                      child: Row(
////                        mainAxisAlignment: MainAxisAlignment.center,
////                        children: <Widget>[
//
//                          child:newCartItem.keys.contains(loadedProduct.id) ? Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                IconButton(
//                  icon: Icon(Icons.add,size: 30,color:Colors.white,),
//                  onPressed: (){
//                    cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price,loadedProduct.isNonInventory,loadedProduct.discount,loadedProduct.discountId,loadedProduct.discountType,);
//                  },
//                ),
//                Text(cart.items.firstWhere((d) => d.productId == loadedProduct.id).quantity.toString(),style: TextStyle(fontSize: 25.0,color: Colors.white),),
//                IconButton(
//                  icon: Icon(Icons.remove,size: 30,color: Colors.white,),
//                  onPressed: (){
//                    cart.removeSingleItem(loadedProduct.id, loadedProduct.title, loadedProduct.price,loadedProduct.isNonInventory,loadedProduct.discount,loadedProduct.discountId,loadedProduct.discountType,);
//                  },
//                ),
//              ],
//            ):IconButton(
//              color: Theme.of(context).accentColor,
//              icon: Icon(Icons.shopping_cart,size: 30,),
//              onPressed: () {
//                cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price,loadedProduct.isNonInventory,loadedProduct.discount,loadedProduct.discountId,loadedProduct.discountType);
//              },
//            ),
//
////                        ],
////                      ),
//                    ),
//
//                  ],
//                ),
//              ),
//
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}


/// ------------------------ main code --------------------------------
//class ProductDetailScreen extends StatelessWidget{
//
//  static const routeName = '/product-detail';
//
//  @override
//  Widget build(BuildContext context) {
//    final productId = ModalRoute.of(context).settings.arguments as String;
//    final loadedProduct = Provider.of<Products>(context,listen:false).findById(productId);
//    final cart = Provider.of<Cart>(context,);
//
//    return Scaffold(
//      appBar: AppBar(title: Text(loadedProduct.title),),
//      body: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            Container(height: 300,width:double.infinity,child: Hero(
//              tag:loadedProduct.id,
//              child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,),
//            ),),
//            SizedBox(height: 10,),
////            Text('\$${loadedProduct.price}',style: TextStyle(color: Colors.grey,fontSize: 20),),
//            Text('BDT ' + loadedProduct.price.toString() + '/' + loadedProduct.unit,style: TextStyle(color: Colors.grey,fontSize: 20),),
////            cart.items.keys.contains(loadedProduct.id) ? Row(
////              mainAxisAlignment: MainAxisAlignment.center,
////              children: <Widget>[
////                IconButton(
////                  icon: Icon(Icons.add),
////                  onPressed: (){
////                    cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price,loadedProduct.isNonInventory,loadedProduct.discount,loadedProduct.discountId,loadedProduct.discountType,);
////                  },
////                ),
////                Text(cart.items[loadedProduct.id].quantity.toString(),style: TextStyle(fontSize: 15.0),),
////                IconButton(
////                  icon: Icon(Icons.remove),
////                  onPressed: (){
////                    cart.removeSingleItem(loadedProduct.id);
////                  },
////                ),
////              ],
////            ):IconButton(
////              color: Theme.of(context).accentColor,
////              icon: Icon(Icons.shopping_cart),
////              onPressed: () {
////                cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price,loadedProduct.isNonInventory,loadedProduct.discount,loadedProduct.discountId,loadedProduct.discountType);
////              },
////            ),
//            SizedBox(height: 10,),
//            Container(
//              padding: EdgeInsets.symmetric(horizontal:10),
//              width: double.infinity,
//              child:Column(
//                children: <Widget>[
//                  Text(
//                    loadedProduct.title,
//                    textAlign: TextAlign.start,
//                    softWrap: true,
//                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
//                  ),
//                  SizedBox(height: 10.0,),
//                  loadedProduct.description.isNotEmpty?Text(
//                    loadedProduct.description,
//                    textAlign: TextAlign.start,
//                    softWrap: true,
//                    style: TextStyle(fontSize: 15.0),
//                  ):Text('No description found'),
//                ],
//              )
//            )
////            Container(
////              padding: EdgeInsets.symmetric(horizontal:10),
////              width: double.infinity,
////              child: Text(
////                loadedProduct.description,
////                textAlign: TextAlign.center,
////                softWrap: true,
////              ),
////            )
//
//          ],
//        ),
//      )
//    );
//  }
//
//
//}