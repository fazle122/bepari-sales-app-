import 'package:sales_app/data_helper/api_service.dart';
import 'package:sales_app/models/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/products.dart';

class OrderItem {
  final int id;
  final String invoiceAmount;
  final String totalDue;
  final List<InvoiceItem> invoiceItem;
  final DateTime dateTime;
  final String status;

  OrderItem({
    @required this.id,
    @required this.invoiceAmount,
    @required this.totalDue,
    @required this.invoiceItem,
    @required this.dateTime,
    @required this.status,
  });
}

class InvoiceItem {
  final int id;
  final int productID;
  final String quantity;
  final String unitPrice;
  final String productName;

  InvoiceItem({
    @required this.id,
    @required this.productID,
    @required this.quantity,
    @required this.unitPrice,
    @required this.productName,
  });
}

class Customer {
  final int id;
  final String name;
  final String address;
  final String mobile;

  Customer({
    @required this.id,
    @required this.name,
    @required this.address,
    @required this.mobile,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<Customer> _customers = [];
  Map<String, dynamic> _customerInfo = Map();
  Map<String, dynamic> _branchInfo = Map();
  final String authToken;
  final String userid;
  double _deliveryCharge;


  Orders(this.authToken, this.userid, this._orders);

  OrderItem _orderItem;
  CartItem _cartItem;
  int lastPageCount;

  OrderItem get singOrderItem {
    return _orderItem;
  }

  CartItem get singCartItem {
    return _cartItem;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  List<Customer> get customers {
    return [..._customers];
  }

  Map<String, dynamic> get getCustomersId {
    return _customerInfo;
  }

  Map<String, dynamic> get getBranchId {
    return _branchInfo;
  }

  int get lastPageNo {
    return lastPageCount;
  }

  double get deliveryCharge{
    return _deliveryCharge;
  }

  set deliveryCharge(value){
    _deliveryCharge = value;
    notifyListeners();
  }

  Future<Map<String,dynamic>> defaultDeliveryCharge(FormData formData) async {
    Dio dioService = new Dio();
    final url =
        ApiService.BASE_URL + 'api/V1.1/accounts/invoice/send-delivery-charge';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Response response = await dioService.post(
      url,
      data: formData,
    );

    final responseData = response.data;
    // print(responseData);
    notifyListeners();
    if (response.statusCode == 200) {
      _deliveryCharge = responseData['data']['del_charge'].toDouble();
      notifyListeners();
      return response.data;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> createInvoice(FormData formData) async {
    Dio dioService = new Dio();
    final url =
        ApiService.BASE_URL + 'api/V1.1/accounts/invoice/create';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Response response = await dioService.post(
      url,
      data: formData,
    );

    final responseData = response.data;
    // print(responseData);
    notifyListeners();
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> createInvoiceWithPayment(FormData formData) async {
    Dio dioService = new Dio();
    final url = ApiService.BASE_URL + 'api/V1.1/accounts/invoice/create-sales-app';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Response response = await dioService.post(
      url,
      data: formData,
    );

    final responseData = response.data;
    // print(responseData);
    notifyListeners();
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateInvoice(FormData formData,var invoiceId) async {
    Dio dioService = new Dio();
    final url =
        ApiService.BASE_URL + 'api/V1.1/accounts/invoice/edit/$invoiceId';

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Response response = await dioService.post(
      url,
      data: formData,
    );

    final responseData = response.data;
    // print(responseData);
    notifyListeners();
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  void commentOrder(String orderId, String comment) async {
    var responseData;
    final url = ApiService.BASE_URL +
        'api/V1.1/accounts/order-delivery/comment-order-delivery/$orderId';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> data = {
      'del_comment': comment,
    };
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(data),
        headers: headers,
      );
      responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void payOrder(String invoiceId) async {
    var responseData;
    final url =
        ApiService.BASE_URL + 'api/V1.1/accounts/invoice/receive-cash/$invoiceId';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: headers,
      );
      responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void cancelOrder(String orderId, String reason) async {
    var responseData;
    final url =
        ApiService.BASE_URL + 'api/V1.1/accounts/invoice/cancelled/$orderId';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> data = {
      'del_cancel_reason': reason,
    };
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(data),
        headers: headers,
      );
      responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void deliverOrder(
      String orderId, String comment, double amount, var image) async {
    var responseData;
    final url = ApiService.BASE_URL +
        'api/V1.3/accounts/order-delivery/delivered-order/$orderId';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> data = {
      'del_delivered_comment': comment,
      'del_received_amount': amount,
      'del_cust_signature': image,
    };
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(data),
        headers: headers,
      );
      responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<List<OrderItem>> fetchAndSetOrders(
      Map<String, dynamic> filters, int pageCount) async {
    String url =
        'http://new.bepari.net/demo/api/V1.1/accounts/invoice/list?page_size=10&page=$pageCount';
    if (filters != null) {
      if (filters.containsKey('status') && filters['status'] != null) {
        url += '&status=' + filters['status'].toString();
      }
//      if (filters.containsKey('invoice_from_date') && filters['invoice_from_date'] != 'null') {
//        url += 'invoice_from_date=' + filters['invoice_from_date'].toString();
//      }
//      if (filters.containsKey('invoice_to_date') && filters['invoice_to_date'] != 'null') {
//        url += '&invoice_to_date=' + filters['invoice_to_date'].toString();
//      }
//      if (currentPage != null) {
//        qString += '&page=$currentPage';
//      }
    }

    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(
        url,
      );
      final List<OrderItem> loadedOrders = [];
      final extractedData = response.data;
      if (extractedData == null) {
        return null;
      }

      if (extractedData['data'].length > 0) {
        var allOrders = extractedData['data']['data'];
        for (int i = 0; i < allOrders.length; i++) {
          final OrderItem orders = OrderItem(
            id: allOrders[i]['id'],
            invoiceAmount: allOrders[i]['invoice_amount'],
            totalDue: allOrders[i]['total_due'],
            dateTime: DateTime.parse(allOrders[i]['invoice_date']),
            status: allOrders[i]['status'].toString(),
          );
          loadedOrders.add(orders);
        }
        lastPageCount = extractedData['data']['last_page'];
        _orders = loadedOrders;
      } else {
        _orders = [];
      }
      notifyListeners();
      return _orders;
    } catch (error) {
       throw (error);
    }
  }

  Future<void> fetchSingleOrder(int orderId) async {
    final url =
        'http://new.bepari.net/demo/api/V1.1/accounts/invoice/view/$orderId';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final http.Response response = await http.get(
      url,
      headers: headers,
    );
    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
    if (extarctedData == null) {
      return;
    }

    var allOrders = extarctedData['data']['invoice'];
    final OrderItem orderItem = OrderItem(
      id: allOrders['id'],
      totalDue: allOrders['total_due'],
      dateTime: DateTime.parse(allOrders['delivery_date']),
      invoiceAmount: allOrders['invoice_amount'],
      status: allOrders['status'].toString(),
      invoiceItem: (allOrders['invoice_details'] as List<dynamic>)
          .map((item) => InvoiceItem(
              id: item['id'],
              productID: item['product_id'],
              unitPrice: item['unit_price'],
              quantity: item['quantity'],
              productName: item['product_name']))
          .toList(),

//          for(int i = 0; i<allOrders['invoice_details'].length; i++){}
    );
    _orderItem = orderItem;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchOrderForCart(int orderId) async {
    final url =
        'http://new.bepari.net/demo/api/V1.1/accounts/invoice/view/$orderId';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final http.Response response = await http.get(
      url,
      headers: headers,
    );
    final extarctedData = json.decode(response.body) as Map<String, dynamic>;
    if (extarctedData == null) {
      return null;
    }

    var orderItem = extarctedData['data']['invoice']['invoice_details'];

    final List<Map<String, dynamic>> cartItems = [];
    Map<String, dynamic> item;

    for (int i = 0; i < orderItem.length; i++) {
      item = new Map();
      item['id'] = orderItem[i]['id'].toString();
      item['productId'] = orderItem[i]['product_id'].toString();
      item['title'] = orderItem[i]['product_name'];
      item['quantity'] = double.parse(orderItem[i]['quantity']);
      item['unitName'] = orderItem[i]['unit_long_name'];
      item['price'] = double.parse(orderItem[i]['unit_price']);
      item['isNonInventory'] = orderItem[i]['is_non_inventory'];
      item['salesAccountsGroupId'] = orderItem[i]['sales_accounts_group_id'].toString();
      item['discount'] = orderItem[i]['discount'];
      item['discountType'] = orderItem[i]['discount_type'];
      item['discountId'] = orderItem[i]['discount_id'].toString();
      item['perUnitDiscount'] = double.parse(orderItem[i]['per_unit_discount']);
      item['vatRate'] = double.parse(orderItem[i]['vat_rate']);
      item['orderId'] = orderId.toString();
      cartItems.add(item);
    }
    return cartItems;
  }

  Future<void> fetchCompletedOrders() async {
    final url =
        'http://new.bepari.net/demo/api/V1.3/accounts/invoice/list-invoice';

    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(
        url,
      );
      final List<OrderItem> loadedOrders = [];
//      final extractedData = json.decode(response.data) as Map<String, dynamic>;
      final extractedData = response.data;
      if (extractedData == null) {
        return;
      }

      if (extractedData['data']['invoices'].length > 0) {
        var allOrders = extractedData['data']['invoices']['data'];
        for (int i = 0; i < allOrders.length; i++) {
          final OrderItem orders = OrderItem(
            id: allOrders[i]['id'],
            invoiceAmount: allOrders[i]['invoice_amount'].toDouble(),
            totalDue: allOrders[i]['total_due'].toDouble(),
            dateTime: DateTime.parse(allOrders[i]['invoice_date']),
          );
          loadedOrders.add(orders);
        }
        _orders = loadedOrders;
      } else {
        _orders = [];
      }
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchCustomers() async {
    final url = 'http://new.bepari.net/demo/api/V1.1/crm/customer/list';

    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(
        url,
      );
      final extractedData = response.data;
      if (extractedData == null) {
        return;
      }

      var info = extractedData['data']['data'];
      for (int i = 0; i < info.length; i++) {
        Map<String, dynamic> tmp = Map();
        tmp['name'] = info[i]['name'];
        tmp['address'] = info[i]['address'];
        _customerInfo[info[i]['id'].toString()] = tmp;
      }

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchBranchInfo() async {
    final url = 'http://new.bepari.net/demo/api/V1.1/admin/branch/list';

    Dio dioService = new Dio();
    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final Response response = await dioService.get(
        url,
      );
      final extractedData = response.data;
      if (extractedData == null) {
        return;
      }

      var info = extractedData['data']['data'];
      for (int i = 0; i < info.length; i++) {
        Map<String, dynamic> tmp = Map();
        tmp['name'] = info[i]['name'];
        tmp['address'] = info[i]['address_line_1'];
        _branchInfo[info[i]['id'].toString()] = tmp;
      }

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
