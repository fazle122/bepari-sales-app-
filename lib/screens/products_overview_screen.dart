import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
//import 'package:sales_app/providers/productCategories.dart';
import 'package:sales_app/providers/products.dart';
//import 'package:sales_app/providers/shipping_address.dart';
import 'package:sales_app/screens/cart_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/badge.dart';
import 'package:sales_app/widgets/filter_item.dart';
import 'package:sales_app/widgets/product_item_grid_view.dart';
import 'package:sales_app/widgets/product_item_list_view.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../base_state.dart';
import 'package:toast/toast.dart';



class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = 'all-products';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends BaseState<ProductsOverviewScreen> {
  var _showList = false;
  var _isInit = true;
  var _isLoading = false;

  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int lastPage;
  String keyword = '';
  int oldPageCount;
  DateTime currentBackPressTime;
  int lastItemId = 0;
  List<Product> finalProduct = [];
  bool isPerformingRequest = false;


  @override
  void didChangeDependencies() {
    final products = Provider.of<Products>(context, listen: false);
    final cat = ModalRoute.of(context).settings.arguments as String;
    if (pageCount == 1) {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        if (cat != null) {
          Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(pageCount, int.parse(cat))
              .then((data) {
            setState(() {
              finalProduct = data;
              lastPage = products.lastPageNo;
              oldPageCount = 0;
              _isLoading = false;
            });
          });
        } else {
          Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(pageCount, 0)
              .then((data) {
            setState(() {
              finalProduct = data;
              lastPage = products.lastPageNo;
              oldPageCount = 0;
              _isLoading = false;
            });
          });
        }
      }
      _isInit = false;
    }

    _scrollController.addListener(() {
      if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1) {
        _isInit = true;
        if (pageCount < lastPage) if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount += 1;
          });
          getData();
        }
      }
    });

    super.didChangeDependencies();
  }


  List<Product> getData() {
    final cat = ModalRoute.of(context).settings.arguments as String;
    if (_isInit) {
      if (!isPerformingRequest) {
        setState(() => isPerformingRequest = true);
      }
      if (cat != null) {
        Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(pageCount, int.parse(cat))
            .then((data) {
          isPerformingRequest = false;
          if (data == null || data.isEmpty) {
            if (finalProduct.isNotEmpty) animateScrollBump();
            if (finalProduct.isEmpty) {
              setState(() {});
            }
          } else {
            setState(() {
              oldPageCount += 1;
              finalProduct.addAll(data);
              lastItemId = int.parse(data.last.id);
            });
          }

        });
      } else {
        Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(pageCount, 0)
            .then((data) {
          isPerformingRequest = false;
          if (data == null || data.isEmpty) {
            if (finalProduct.isNotEmpty) animateScrollBump();
            if (finalProduct.isEmpty) {
              setState(() {});
            }
          } else {
            setState(() {
              oldPageCount += 1;
              finalProduct.addAll(data);
              lastItemId = int.parse(data.last.id);
            });
          }

        });
      }
    }
    _isInit = false;
    return finalProduct;
  }

  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Press back again to exit the app", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//      Fluttertoast.showToast(msg: exit_warning);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final products = finalProduct;
    final cart = Provider.of<Cart>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text('Create order'),
          actions: <Widget>[
            IconButton(
              icon: !_showList
                  ? Icon(
                Icons.list,
                size: 25.0,
              )
                  : Icon(
                Icons.grid_on,
                size: 20.0,
              ),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _showList = !_showList;
                });
              },
            ),
            Consumer<Cart>(
              builder: (context, cart, ch) => Badge(
                child: ch,
                value: cart.itemCount.toString(),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch(_showList));
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
//      body: ProductsView(_showOnlyFavorites, _showList),
        body:WillPopScope(
            onWillPop: onWillPop,
            child:  _isLoading
                ? Center(child: CircularProgressIndicator())
                :
            Container(
//          height: MediaQuery.of(context).size.height * 7/10,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: queryItemListDataWidget(context)),

                  Consumer<Cart>(
                    builder: (context, cartData, child) =>
                    cart.items.length > 0
                        ?
                    Container(
                        height: 50.0,
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width *
                                    5 /
                                    7,
                                padding:
                                EdgeInsets.only(left: 20.0, top: 2.0),
                                color: Theme.of(context).primaryColor,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text('SubTotal: ' +
                                        cartData.totalAmount
                                            .toStringAsFixed(2)),
                                    cartData.totalAmount > 500
                                        ? Text('Delivery charge: 00.00 BDT')
                                        : Text(
                                        'Delivery charge: 50.00 BDT'),
                                    cartData.totalAmount > 500
                                        ? Text(
                                      'Total amount : ' +
                                          cartData.totalAmount
                                              .toStringAsFixed(2),
                                      style: TextStyle(
                                          color: Colors.white),
                                    )
                                        : Text(
                                      'Total amount : ' +
                                          (cartData.totalAmount + 50.00)
                                              .toStringAsFixed(2),
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ],
                                )),
                            Container(
                              height: MediaQuery.of(context).size.height,
                              width:
                              MediaQuery.of(context).size.width * 2 / 7,
                              color: Theme.of(context).primaryColorDark,
                              child: InkWell(
                                child: Center(
                                  child: Text(
                                    'Check out',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(CartScreen.routeName);
                                },
                              ),
                            ),
                          ],
                        )): SizedBox(
                      width: 0.0,
                      height: 0.0,
                    ),
                  )

                ],
              ),
            )
        )
    );
  }

  Widget queryItemListDataWidget(BuildContext context) {
    if (finalProduct.isNotEmpty) //has data & performing/not performing
      return ProductItemList(
        productListItems: finalProduct,
        scrollController: _scrollController,
        isPerformingRequest: isPerformingRequest,
        showList: _showList,
      );
    if (isPerformingRequest)
      return Center(
        child: CircularProgressIndicator(),
      );

    return Center(
      child: Text('no product found'),
    );
  }


}


class ProductItemList extends StatelessWidget{

  final List<Product> productListItems;
  final ScrollController scrollController;
  final bool isPerformingRequest;
  final bool showList;

  ProductItemList(
      {this.productListItems, this.scrollController, this.isPerformingRequest,this.showList});

  @override
  Widget build(BuildContext context) {
    return Container
      (child: showList
        ? productListItems != null && productListItems.length > 0
        ? ListView.builder(
        padding: const EdgeInsets.all(10.0),
        controller: scrollController,
        itemCount: productListItems.length+1,
        itemBuilder: (context, i) {
          if (i == productListItems.length) {
            return _buildProgressIndicator();
          } else {
            return ChangeNotifierProvider.value(
              value: productListItems[i],
              child: ProductItemListView(),
            );
          }
        })
        : Center(
      child: Text('No item found'),
    )
        : productListItems != null && productListItems.length > 0
        ?

    GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(10.0),
        itemCount: productListItems.length+1,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          if (i == productListItems.length) {
            return _buildProgressIndicator1();
          } else {
            return ChangeNotifierProvider.value(
              value: productListItems[i],
              child: ProductItemGridView(),
            );
          }
        }
    )
        : Center(
      child: Text('No item found'),
    ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator1() {
    return Padding(
      padding: const EdgeInsets.only(top:50,left:160),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

}

























/// ------------------ perfectly working data -----------------------





//
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shoptempdb/providers/cart.dart';
//import 'package:shoptempdb/providers/product.dart';
//import 'package:shoptempdb/providers/productCategories.dart';
//import 'package:shoptempdb/providers/products.dart';
//import 'package:shoptempdb/providers/shipping_address.dart';
//import 'package:shoptempdb/screens/cart_screen.dart';
//import 'package:shoptempdb/widgets/app_drawer.dart';
//import 'package:shoptempdb/widgets/badge.dart';
//import 'package:shoptempdb/widgets/filter_item.dart';
//import 'package:shoptempdb/widgets/product_item_grid_view.dart';
//import 'package:shoptempdb/widgets/product_item_list_view.dart';
//import 'package:flutter_icons/flutter_icons.dart';
//import '../base_state.dart';
//import 'package:toast/toast.dart';
//
//
//
//class ProductsOverviewScreen extends StatefulWidget {
//  static const routeName = 'all-products';
//
//  @override
//  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
//}
//
//class _ProductsOverviewScreenState extends BaseState<ProductsOverviewScreen> {
//  var _showList = false;
//  var _isInit = true;
//  var _isLoading = false;
//
//  ScrollController _scrollController = new ScrollController();
//  int pageCount = 1;
//  int lastPage;
//  String keyword = '';
//  int oldPageCount;
//  List<Product> finalProduct = [];
//
//  @override
//  void didChangeDependencies() {
//    final products = Provider.of<Products>(context, listen: false);
//    final cat = ModalRoute.of(context).settings.arguments as String;
//    if (pageCount == 1) {
//      if (_isInit) {
//        setState(() {
//          _isLoading = true;
//        });
//        if (cat != null) {
//          Provider.of<Products>(context, listen: false)
//              .fetchAndSetProducts(pageCount, int.parse(cat))
//              .then((data) {
//            setState(() {
//              finalProduct = data;
//              lastPage = products.lastPageNo;
//              oldPageCount = 0;
//              _isLoading = false;
//            });
//          });
//        } else {
//          Provider.of<Products>(context, listen: false)
//              .fetchAndSetProducts(pageCount, 0)
//              .then((data) {
//            setState(() {
//              finalProduct = data;
//              lastPage = products.lastPageNo;
//              oldPageCount = 0;
//              _isLoading = false;
//            });
//          });
//        }
//      }
//      _isInit = false;
//    }
//
//    _scrollController.addListener(() {
//      if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1) {
//        _isInit = true;
//        if (pageCount < lastPage) if (_scrollController.position.pixels ==
//            _scrollController.position.maxScrollExtent) {
//          setState(() {
//            pageCount += 1;
//          });
//          getData('increment');
//        }
//        if (pageCount > 0) if (_scrollController.position.pixels ==
//            _scrollController.position.minScrollExtent) {
//          setState(() {
//            pageCount -= 1;
//          });
//          getData('decrement');
//        }
//      }
//    });
//
//    super.didChangeDependencies();
//  }
//
//  List<Product> getData(String type) {
//    final cat = ModalRoute.of(context).settings.arguments as String;
//    if (_isInit) {
//      setState(() {
//        _isLoading = true;
//      });
//      if (cat != null) {
//        Provider.of<Products>(context, listen: false)
//            .fetchAndSetProducts(pageCount, int.parse(cat))
//            .then((data) {
//          setState(() {
//            finalProduct = data;
//            _isLoading = false;
//            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
//          });
//        });
//      } else {
//        Provider.of<Products>(context, listen: false)
//            .fetchAndSetProducts(pageCount, 0)
//            .then((data) {
//          setState(() {
//            finalProduct = data;
//            _isLoading = false;
//            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
//          });
//        });
//      }
//    }
//    _isInit = false;
//
////    final productsData = Provider.of<Products>(context, listen: false);
//////    List<Product> products = productsData.items;
////
////    List<Product> tempProduct = [];
////    tempProduct = productsData.items;
////
////    if (tempProduct == null || tempProduct.isEmpty) {
////      if (productsData.items.isNotEmpty) {
////        animateScrollBump();
////      }
////    } else {
////      setState(() {
////        _isLoading = false;
////        productsData.items.addAll(tempProduct);
////        finalProduct = productsData.items;
////      });
////    }
////
//    return finalProduct;
//  }
//
////  List<Product> getData1(String type,String catId) {
////    final cat = catId;
////    if(_isInit){
////      setState(() {
////        _isLoading = true;
////      });
////      if(cat != null) {
////        Provider.of<Products>(context, listen: false).fetchAndSetProducts(
////            pageCount, int.parse(cat))
////            .then((data) {
////          setState(() {
////            finalProduct = data;
////            _isLoading = false;
////            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
////          });
////        });
////      }else{
////        Provider.of<Products>(context, listen: false).fetchAndSetProducts(
////            pageCount, 0)
////            .then((data) {
////          setState(() {
////            finalProduct = data;
////            _isLoading = false;
////            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
////          });
////        });
////      }
////    }
////    _isInit = false;
////
//////    final productsData = Provider.of<Products>(context, listen: false);
////////    List<Product> products = productsData.items;
//////
//////    List<Product> tempProduct = [];
//////    tempProduct = productsData.items;
//////
//////    if (tempProduct == null || tempProduct.isEmpty) {
//////      if (productsData.items.isNotEmpty) {
//////        animateScrollBump();
//////      }
//////    } else {
//////      setState(() {
//////        _isLoading = false;
//////        productsData.items.addAll(tempProduct);
//////        finalProduct = productsData.items;
//////      });
//////    }
//////
////    return finalProduct;
////  }
////
////  Widget buildCatRow() {
////    return FutureBuilder(
////        future:
////        Provider.of<ProductCategories>(context, listen: false).fetchProductsCategory(),
////        builder: (context, dataSnapshot) {
////          if (dataSnapshot.connectionState == ConnectionState.waiting) {
////            return Center(
////              child: CircularProgressIndicator(),
////            );
////          } else {
////            if (dataSnapshot.error != null) {
////              return Center(
////                child: Text('no categories found'),
////              );
////            } else {
////              return Consumer<ProductCategories>(
////                builder: (context, catData, child) =>
////                Container(
//////                  width: MediaQuery.of(context).size.width,
//////                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
////                  height: 50,
////                  child: ListView.builder(
////                    shrinkWrap: true,
////                    scrollDirection: Axis.horizontal,
////                    itemCount: catData.getCategories.length,
////                    itemBuilder: (context, i) =>
////
////                        Container(
////                          width: 150,
////                          child: ListTile(
////                            title: Text(catData.getCategories[i].name),
////                            onTap: () {
//////                              Navigator.of(context).pushNamed(
//////                                  ProductsOverviewScreen.routeName,
//////                                  arguments: catData.getCategories[i].id);
////                            setState(() {
////                              _isInit = true;
////                            });
////
////                            final products = Provider.of<Products>(context, listen: false);
////                            final cat = catData.getCategories[i].id;
////                            if (pageCount == 1) {
////                              if (_isInit) {
////                                setState(() {
////                                  _isLoading = true;
////                                });
////                                if(cat != null){
////                                  Provider.of<Products>(context, listen: false).fetchAndSetProducts(
////                                      pageCount,int.parse(cat)).then((data) {
////
////                                    setState(() {
////                                      finalProduct = data;
////                                      lastPage = products.lastPageNo;
////                                      oldPageCount = 0;
////                                      _isLoading = false;
////                                    });
////                                  });
////                                }else {
////                                  Provider.of<Products>(context, listen: false).fetchAndSetProducts(
////                                      pageCount,0).then((data) {
////                                    setState(() {
////                                      finalProduct = data;
////                                      lastPage = products.lastPageNo;
////                                      oldPageCount = 0;
////                                      _isLoading = false;
////                                    });
////                                  });
////                                }
////                              }
////                              _isInit = false;
////                            }
////
////                            _scrollController.addListener(() {
////                              if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1)
////                              {
////                                _isInit = true;
////                                if(pageCount < lastPage)
////                                  if (_scrollController.position.pixels ==
////                                      _scrollController.position.maxScrollExtent) {
////                                    setState(() {
////                                      pageCount += 1;
////                                    });
////                                    getData1('increment',catData.getCategories[i].id);
////                                  }
////                                if (pageCount > 0)
////                                  if (_scrollController.position.pixels ==
////                                      _scrollController.position.minScrollExtent) {
////                                    setState(() {
////                                      pageCount -= 1;
////                                    });
////                                    getData1('decrement',catData.getCategories[i].id);
////                                  }
////                              }
////
////                            });
////                            },
////                          ),
////                        )
////                  ),
////                )
////
////              );
////            }
////          }
////        });
////  }
//
//  DateTime currentBackPressTime;
//
//
//  Future<bool> onWillPop() {
//    DateTime now = DateTime.now();
//    if (currentBackPressTime == null ||
//        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
//      currentBackPressTime = now;
//      Toast.show("Press back again to exit the app", context,
//          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
////      Fluttertoast.showToast(msg: exit_warning);
//      return Future.value(false);
//    }
//    return Future.value(true);
//  }
//
//  @override
//  Widget build(BuildContext context) {
////    final productsData = Provider.of<Products>(context);
////    final cat = ModalRoute.of(context).settings.arguments as String;
////    final products = cat != null ? productsData.items.where((data) => data.category == cat).toList():finalProduct;
//    final products = finalProduct;
//    final cart = Provider.of<Cart>(context, listen: false);
//
//    return Scaffold(
//        appBar: AppBar(
//          title: Text('Bepari'),
//          actions: <Widget>[
//            IconButton(
//              icon: !_showList
//                  ? Icon(
//                Icons.list,
//                size: 25.0,
//              )
//                  : Icon(
//                Icons.grid_on,
//                size: 20.0,
//              ),
//              onPressed: () {
//                if (!mounted) return;
//                setState(() {
//                  _showList = !_showList;
//                });
//              },
//            ),
//            Consumer<Cart>(
//              builder: (context, cart, ch) => Badge(
//                child: ch,
//                value: cart.itemCount.toString(),
//              ),
//              child: IconButton(
//                icon: Icon(Icons.shopping_cart),
//                onPressed: () {
//                  Navigator.of(context).pushNamed(CartScreen.routeName);
//                },
//              ),
//            ),
//            IconButton(
//              icon: Icon(Icons.search),
//              onPressed: () {
//                showSearch(context: context, delegate: DataSearch(_showList));
//              },
//            ),
//          ],
//        ),
//        drawer: AppDrawer(),
////      body: ProductsView(_showOnlyFavorites, _showList),
//        body:WillPopScope(
//          onWillPop: onWillPop,
//          child:       _isLoading
//              ? Center(child: CircularProgressIndicator())
//              : Column(
//            children: <Widget>[
////
////          Container(
////            height: 50,
////            child: buildCatRow(),
////          ),
////
////          SizedBox(
////            height: 20,
////          ),
//
//              Expanded(
//                child: _showList
//                    ? products != null && products.length > 0
//                    ? ListView.builder(
//                    padding: const EdgeInsets.all(10.0),
//                    controller: _scrollController,
//                    itemCount: products.length,
//                    itemBuilder: (context, i) =>
//                        ChangeNotifierProvider.value(
//                          value: products[i],
//                          child: ProductItemListView(),
//                        ))
//                    : Center(
//                  child: Text('No item found'),
//                )
//                    : products != null && products.length > 0
//                    ? GridView.builder(
//                    controller: _scrollController,
//                    padding: const EdgeInsets.all(10.0),
//                    itemCount: products.length,
//                    gridDelegate:
//                    SliverGridDelegateWithFixedCrossAxisCount(
//                      crossAxisCount: 2,
//                      childAspectRatio: 4 / 5,
//                      crossAxisSpacing: 10,
//                      mainAxisSpacing: 10,
//                    ),
//                    itemBuilder: (context, i) =>
//                        ChangeNotifierProvider.value(
//                          value: products[i],
//                          child: ProductItemGridView(),
//                        ))
//                    : Center(
//                  child: Text('No item found'),
//                ),
//              ),
//
//              Consumer<Cart>(
//                builder: (context, cartData, child) =>
//                cart.items.length > 0
//                    ?
//                Container(
//                    height: 50.0,
//                    color: Theme.of(context).primaryColor,
//                    child: Row(
//                      children: <Widget>[
//                        Container(
//                            width: MediaQuery.of(context).size.width *
//                                5 /
//                                7,
//                            padding:
//                            EdgeInsets.only(left: 20.0, top: 2.0),
//                            color: Theme.of(context).primaryColor,
//                            child: Column(
//                              crossAxisAlignment:
//                              CrossAxisAlignment.start,
//                              mainAxisAlignment:
//                              MainAxisAlignment.start,
//                              children: <Widget>[
//                                Text('SubTotal: ' +
//                                    cartData.totalAmount
//                                        .toStringAsFixed(2)),
//                                cartData.totalAmount > 500
//                                    ? Text('Delivery charge: 00.00 BDT')
//                                    : Text(
//                                    'Delivery charge: 50.00 BDT'),
//                                cartData.totalAmount > 500
//                                    ? Text(
//                                  'Total amount : ' +
//                                      cartData.totalAmount
//                                          .toStringAsFixed(2),
//                                  style: TextStyle(
//                                      color: Colors.white),
//                                )
//                                    : Text(
//                                  'Total amount : ' +
//                                      (cartData.totalAmount + 50.00)
//                                          .toStringAsFixed(2),
//                                  style: TextStyle(
//                                      color: Colors.white),
//                                ),
//                              ],
//                            )),
//                        Container(
//                          height: MediaQuery.of(context).size.height,
//                          width:
//                          MediaQuery.of(context).size.width * 2 / 7,
//                          color: Theme.of(context).primaryColorDark,
//                          child: InkWell(
//                            child: Center(
//                              child: Text(
//                                'Check out',
//                                style: TextStyle(
//                                    color: Colors.white,
//                                    fontWeight: FontWeight.bold),
//                              ),
//                            ),
//                            onTap: () {
//                              Navigator.of(context)
//                                  .pushNamed(CartScreen.routeName);
//                            },
//                          ),
//                        ),
//                      ],
//                    )): SizedBox(
//                  width: 0.0,
//                  height: 0.0,
//                ),
//              )
//
//            ],
//          ),
//        )
//    );
//  }
//
//  void animateScrollBump() {
//    double edge = 50.0;
//    double offsetFromBottom = _scrollController.position.maxScrollExtent -
//        _scrollController.position.pixels;
//    if (offsetFromBottom < edge) {
//      _scrollController.animateTo(
//          _scrollController.offset - (edge - offsetFromBottom),
//          duration: new Duration(milliseconds: 500),
//          curve: Curves.easeOut);
//    }
//  }
//}

