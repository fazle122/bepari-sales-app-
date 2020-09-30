import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/data_helper/api_service.dart';
import 'package:sales_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Product with ChangeNotifier {
  final String id;
  final String title;
  final String productCategoryId;
  final String description;
  final double price;
  final String unit;
  final String imageUrl;
  final int isNonInventory;
  final String salesAccountsGroupId;
  final double discount;
  final String discountId;
  final String discountType;
  final double perUnitDiscount;
  final double vatRate;

  Product({
    @required this.id,
    @required this.title,
    @required this.productCategoryId,
    @required this.description,
    @required this.price,
    @required this.unit,
    @required this.imageUrl,
    @required this.isNonInventory,
    @required this.salesAccountsGroupId,
    @required this.discount,
    @required this.discountId,
    @required this.discountType,
    @required this.perUnitDiscount,
    @required this.vatRate,

  });

}

class Products with ChangeNotifier {


  final String authToken;
  final String userid;

  Products(this.authToken,this.userid);

  List<Product> _items = [];
  int lastPageCount;
  var _showFavoritesOnly = false;

  List<Product> get items {
//    return [..._items];
    return [..._items];
  }

  int get lastPageNo{
    return lastPageCount;
  }



  Future<List<Product>> fetchAndSetProducts(int pageCount,int catId) async {
    // var url = 'http://new.bepari.net/demo/api/V1.1/product-catalog/product/list?page_size=30&page=$pageCount&category_id=$catId';
    var url = 'http://new.bepari.net/demo/api/V1.1/product-catalog/product/dropdown-transaction-sales-app?page_size=30&page=$pageCount&category_id=$catId';
    // product-catalog/product/dropdown-transaction-sales-app

    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(url,);
      final data = response.data;
      if (data == null) {
        return null;
      }

      final List<Product> loadedProducts = [];
      var allProduct = data['data']['data'];
      for (int i = 0; i < allProduct.length; i++) {
        final Product product = Product(
          id: allProduct[i]['id'].toString(),
          title: allProduct[i]['name'],
//          category: allProduct[i]['category_name'],
          productCategoryId: allProduct[i]['product_category_id'].toString(),
          description: allProduct[i]['description'],
          unit: allProduct[i]['unit_name'],
         price: allProduct[i]['unit_price'].toDouble(),
          // price: double.parse(allProduct[i]['unit_price']),
          vatRate: allProduct[i]['vat_rate'].toDouble(),
          isNonInventory: allProduct[i]['is_non_inventory'],
          salesAccountsGroupId: allProduct[i]['sales_accounts_group_id'].toString(),
//          discount: allProduct[i]['discount_amount'].toDouble(),
          discount: allProduct[i]['discount_amount']!=null ? double.parse(allProduct[i]['discount_amount']): 0,
          discountType: allProduct[i]['discount_type'],
          discountId: allProduct[i]['discount_id'],
          imageUrl: allProduct[i]['thumb_image']!= null ? ApiService.CDN_URl + 'product-catalog-images/product/' +allProduct[i]['thumb_image']:
          'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
//          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      lastPageCount = data['data']['last_page'];
      _items = loadedProducts;
      notifyListeners();
      return  _items;
    } catch (error) {
      throw (error);
    }
  }

  Future<List<Product>> searchAndSetProducts({String keyword}) async {
    print('test');
    var url =
        'http://new.bepari.net/demo/api/V1.0/product-catalog/product/list-product?page_size=100&keyword=$keyword';
    try {
      final response = await http.get(url);
      if(response.statusCode != 200){return null;}
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return null;
      }
      final List<Product> loadedProducts = [];
      var allProduct = data['data']['data'];
      for (int i = 0; i < allProduct.length; i++) {
        final Product product = Product(
          id: allProduct[i]['id'].toString(),
          title: allProduct[i]['name'],
          productCategoryId: allProduct[i]['product_category_id'].toString(),
          description: allProduct[i]['description'],
          unit: allProduct[i]['unit_name'],
//          price: allProduct[i]['unit_price'].toDouble(),
          price: double.parse(allProduct[i]['unit_price']),
          isNonInventory: allProduct[i]['is_non_inventory'],
//          discount: allProduct[i]['discount_amount'].toDouble(),
          discount: allProduct[i]['discount_amount']!=null ? double.parse(allProduct[i]['discount_amount']): 0,
          discountType: allProduct[i]['discount_type'],
          discountId: allProduct[i]['discount_id'],
          imageUrl: allProduct[i]['thumb_image']!= null ? ApiService.CDN_URl + 'product-catalog-images/product/' +allProduct[i]['thumb_image']:
          'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
//          imageUrl: ApiService.CDN_URl + 'product-catalog-images/product/' +allProduct[i]['thumb_image'],
//          imageUrl: 'https://www.jessicagavin.com/wp-content/uploads/2019/02/honey-1-600x900.jpg',
        );
        loadedProducts.add(product);
      }
      _items = loadedProducts;
      notifyListeners();
      return  _items;
    } catch (error) {
      throw (error);
    }
  }

//  List<Product> get favoriteItems {
//    return _items.where((prodItem) => prodItem.isFavorite).toList();
//  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }


}
