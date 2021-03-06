import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_app/data_helper/api_service.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String productCategoryId;
  final double quantity;
  final String unitName;
  final double price;
  final int isNonInventory;
  final String salesAccountsGroupId;
  final double discount;
  final String discountType;
  final String discountId;
  final double perUnitDiscount;
  final double vatRate;
  final String orderId;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.productCategoryId,
    @required this.quantity,
    @required this.unitName,
    @required this.price,
    @required this.isNonInventory,
    @required this.salesAccountsGroupId,
    @required this.discount,
    @required this.discountType,
    @required this.discountId,
    @required this.perUnitDiscount,
    @required this.vatRate,
    @required this.orderId,
  });

  factory CartItem.fromJson(Map<String, dynamic> data) => new CartItem(
        id: data["id"],
        productId: data["productId"],
        title: data["title"],
        quantity: data["quantity"].toDouble(),
        unitName: data["unitName"],
        price: data['price'].toDouble(),
        isNonInventory: data['isNonInventory'],
        salesAccountsGroupId: data['salesAccountsGroupId'],
        discount: data['discount'] != null ? data['discount'].toDouble() : 0.0,
        discountType: data['discountType'],
        discountId: data['discountId'],
        perUnitDiscount: data['perUnitDiscount'] != null? data['perUnitDiscount'].toDouble():0.0,
        vatRate: data['vatRate'] != null ? data['vatRate'].toDouble():0.0,
        orderId: data['orderId'],
      );

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['productId'] = productId;
    map['title'] = title;
    map['quantity'] = quantity;
    map['unitName'] = unitName;
    map['price'] = price;
    map['isNonInventory'] = isNonInventory;
    map['salesAccountsGroupId'] = salesAccountsGroupId;
    map['discount'] = discount;
    map['discountType'] = discountType;
    map['discountId'] = discountId;
    map['perUnitDiscount'] = perUnitDiscount;
    map['vatRate'] = vatRate;
    map['orderId'] = orderId;
    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'title': title,
        'quantity': quantity,
        'unitName': unitName,
        'price': price,
        'isNonInventory': isNonInventory,
        'salesAccountsGroupId': salesAccountsGroupId,
        'discount': discount,
        'discountType': discountType,
        'discountId': discountId,
        'perUnitDiscount': perUnitDiscount,
        'vatRate': vatRate,
        'orderId': orderId,
      };
}

class Cart with ChangeNotifier {
  String id;
  CartItem cartItem;
  bool _isUpdateMood = false;
  int _invoiceId;
  var _subtotalAmount = 0.0;

  Cart({this.id, this.cartItem});

  List<CartItem> _items = [];

  List<CartItem> get items {
    return [..._items];
  }

  int get itemCount {
    return _items.length;
  }

  bool get isUpdateMode{
    return _isUpdateMood;
  }
  set isUpdateMode(val){
    _isUpdateMood = val;
    notifyListeners();
  }

  int get invoiceIdForUpdate{
    return _invoiceId;
  }
  set invoiceIdForUpdate(val){
    _invoiceId = val;
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((item) {
      total += item.price.toDouble() * item.quantity;
    });
    return total;
   // notifyListeners();
  }


  CartItem findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }




  Future<void> fetchAndSetCartItems() async {
    final dataList = await DBHelper.getData('cartTable');
    _items = dataList
        .map(
          (item) => CartItem(
            id: item['id'].toString(),
            productId: item['productId'],
            title: item['title'],
            quantity: item['quantity'].toDouble(),
            price: item['price'].toDouble(),
            isNonInventory: item['isNonInventory'],
            discount: item['discount'] != null ?item['discount'].toDouble():0.0,
            discountType: item['discountType'],
            discountId: item['discountId'],
            orderId: item['orderId'],
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetCartItems1() async {
    final dataList = await DBHelper.getData('cartTable');
    _items = dataList
        .map(
          (item) => CartItem(
            id: item['id'].toString(),
            productId: item['productId'],
            title: item['title'],
            productCategoryId:item['productCategoryId'],
            quantity: item['quantity'].toDouble(),
            unitName: item['unitName'],
            price: item['price'].toDouble(),
            isNonInventory: item['isNonInventory'],
            salesAccountsGroupId:item['salesAccountsGroupId'],
            discount: item['discount'] != null? item['discount'].toDouble():0.0,
            discountType: item['discountType'],
            discountId: item['discountId'],
            perUnitDiscount: item['perUnitDiscount'] !=null ? item['perUnitDiscount'].toDouble():0.0,
            vatRate: item['vatRate'] != null ? item['vatRate'].toDouble():0.0,
            orderId: item['orderId'],
          ),
        )
        .toList();

    notifyListeners();
  }

  Future<void> addItem(
      String productId,
      String title,
      // String productCategoryId,
      String unitName,
      double price,
      int isNonInventory,
      String salesAccountsGroupId,
      double discount,
      String discountId,
      String discountType,
      double perUnitDiscount,
      double vatRate) async {
    bool item = await DBHelper.isProductExist(productId);

    if (!item) {
      await DBHelper.insert('cartTable', {
//      'id': newPlace.id,
        'productId': productId,
        'title': title,
        'quantity': 1,
        'unitName':unitName,
        'price': price,
        'isNonInventory': isNonInventory,
        'salesAccountsGroupId':salesAccountsGroupId,
        'discount': discount,
        'discountType': discountType,
        'discountId': discountId,
        'perUnitDiscount':perUnitDiscount,
        'vatRate':vatRate,
        'orderId': '',
      });
    } else {
      await DBHelper.increaseItemQuantity('cartTable',productId
      );
    }
    fetchAndSetCartItems1();
  }

  Future<void> removeSingleItem(String productId) async {
    CartItem cartData = await DBHelper.getSingleData(productId);

    if (cartData.quantity == 1) {
      await DBHelper.deleteCartItm(productId);
    } else {
      await DBHelper.decreaseItemQuantity(productId);
    }
//    notifyListeners();

    fetchAndSetCartItems1();
  }

  Future<void> removeCartItemRow(String productId) async {
    await DBHelper.deleteCartItm(productId);
//    notifyListeners();

    fetchAndSetCartItems1();
  }

  void clearCartTable() {
    DBHelper.clearCart();
    _items = [];
    notifyListeners();
  }

  double getDiscount(double discount, String discountType, double unitPrice, int quantity) {
//    double discountAmount;
//    if(discount != 0.0){
//      if(discountType == 'percent'){
//        discountAmount =(discount/100);
//        discountAmount = unitPrice * discountAmount;
//      }
//      else if(discountType == 'amount'){
//        discountAmount = discount*quantity;
//      }
//    }else{
//      discountAmount = 0.0;
//    }
//    return discountAmount;
//  }
//
////  Future<void> fetchAndSetCartItems() async {
////
////    try {
////      final data = db.getAllCartItems();
////      if (data == null) {
////        return;
////      }
////      final List<CartItem> loadedProducts = [];
////
//////      _items = loadedProducts;
////      notifyListeners();
////    } catch (error) {
////      throw (error);
////    }
  }

  void removeItem(String productId) {
//    _items.remove(productId);
//    notifyListeners();
  }
}

