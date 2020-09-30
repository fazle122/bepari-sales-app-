import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flushbar/flushbar.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:sales_app/base_state.dart';
import 'package:sales_app/data_helper/local_db_helper.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/shipping_address.dart';
import 'package:sales_app/screens/orders_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/create_shippingAddress_dialog.dart';
import 'package:sales_app/widgets/order_item.dart';
import 'package:sales_app/widgets/shipping_address_item.dart';
import 'package:sales_app/widgets/update_shippingAddress_dialog.dart';
//import 'package:shoptempdb/widgets/update_shippingAddress_dialog_test.dart';


class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/shipping_address';


  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends BaseState<CreateOrderScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressItem selectedAddress;
  String selectedAddressId;
  String selectedBranchId;
  TextEditingController _commentController = TextEditingController();
  DateTime deliveryDate = DateTime.now();
  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  var shipToCustomerAddress = 1;
  final format = DateFormat('yyyy-MM-dd');
  var _isInit = true;
  var _isLoading = false;


  String selectedCustomerId;
  int salesSource = 6;
  int overAllDiscount = 0;





//  @override
//  void initState() {
//    super.initState();
//    data = FormData();
//  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchCustomers().then((_) {
        Provider.of<Orders>(context,listen: false).fetchBranchInfo();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  setSelectedAddress(AddressItem address) {
    setState(() {
      selectedAddress = address;
      selectedAddressId = address.id;
    });
  }



  List<DropdownMenuItem> _addCustomerMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: value['name']!=null? Text(value['name']):Text('NA'),
      ));
    });
    return itemWidgets;
  }

  List<DropdownMenuItem> _addBranchMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: value['name']!=null? Text(value['name']):Text('NA'),
      ));
    });
    return itemWidgets;
  }

  Widget _snackBar(String text) {
    return SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: Text(text)),
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
   final customerInfo = Provider.of<Orders>(context);
    final cart = ModalRoute.of(context).settings.arguments as Cart;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Confirm order'),
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 30.0,
                color: Colors.grey[300],
                child: Center(child: Text('Delivery date')),
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
//                      padding: EdgeInsets.only(left: 5.0,right: 5.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        height: 48.0,
                        width: MediaQuery.of(context).size.width * 1/5,
                        color: Theme.of(context).primaryColor,
                        child:IconButton(
                          icon:Icon(Icons.date_range),
                          color: Colors.white,
                          onPressed: (){

                          },
                        )
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 4/5,
                      child: DateTimeField(
                        textAlign: TextAlign.start,
                        format: format,
                        onChanged: (dt) {
                          setState(() {
                            deliveryDate = dt;
                            invoiceDate = dt;
                            dueDate = dt;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: 'Select date',
                            contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal(left: Radius.zero))
                        ),
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                        },
                      ),
                    )
                  ],
                ),
              ),


              SizedBox(
                height: 10.0,
              ),
              Container(
                child: DropdownButton(
                  isExpanded: true,
                  hint: Text('Select Customer'),
                  value: selectedCustomerId,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCustomerId = newValue;
                      print(newValue);

                    });
                  },
                  items: _addCustomerMenuItems(customerInfo.getCustomersId),
                )


                // DropdownButtonFormField(
                //
                //   isExpanded: true,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(
                //       Icons.person,
                //       color: Theme.of(context).primaryColor,
                //     ),
                //     border: OutlineInputBorder(),
                //
                //   ),
                //   hint: Text('Add customer'),
                //   value: customerInfo.customers,
                //   onSaved: (value){
                //     // customerInfo.customers = value;
                //   },
                //   validator: (value){
                //     if (value == null) {
                //       return 'please choose district';
                //     }
                //     return null;
                //   },
                //   onChanged: (newValue) {
                //
                //   },
                //   items: _addCustomerMenuItems(customerInfo),
                // ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  child: DropdownButton(
                    isExpanded: true,
                    hint: Text('Select Branch'),
                    value: selectedBranchId,
                    onChanged: (newValue) {
                      setState(() {
                        selectedBranchId = newValue;
                        print(newValue);

                      });
                    },
                    items: _addBranchMenuItems(customerInfo.getBranchId),
                  )
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  child: TextField(
                    controller: _commentController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        // hintText: data,

                      )
                  )
              ),
              Container(
                height: 40.0,
                width: 150.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.grey)),
                  onPressed: () async{

                    print('customer_id --' + selectedCustomerId);
                    print('branch_id --' + selectedBranchId);
                    print('sub_total --' + cart.totalAmount.toString());
                    print('invoice_amount --' + 'NA');
                    print('invoice_vat --' + 'NA');
                    print('total_before_vat --' + 'NA');
                    print('total_discount --' + 'NA');
                    print('delivery_date --' + deliveryDate.toString());
                    print('due_date --' + dueDate.toString());
                    print('invoice_date --' + invoiceDate.toString());
                    print('overall_discount --' + overAllDiscount.toString());
                    print('sales_source --' + salesSource.toString());
                    print('invoice_date --' + invoiceDate.toString());
                    print('invoice_date --' + invoiceDate.toString());

                    if(cart.items.length > 0) {
                      List<Cart> ct = [];
                      ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
                      Map<String,dynamic>  data = Map();
                     for (int i = 0; i < ct.length; i++) {
                       data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
                       data.putIfAbsent('quantity[$i]', () =>ct[i].cartItem.quantity);
                       data.putIfAbsent('unit_price[$i]', () =>ct[i].cartItem.price);
                       data.putIfAbsent('is_non_inventory[$i]', () =>ct[i].cartItem.isNonInventory);

                       data.putIfAbsent('vat_rate[$i]', () =>ct[i].cartItem.vatRate.toString());
                       data.putIfAbsent('total_vat[$i]', () =>(ct[i].cartItem.vatRate * ct[i].cartItem.quantity).toString());
                       data.putIfAbsent('item_total_discount[$i]', () =>(ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity).toString());
                       data.putIfAbsent('total_amount[$i]', () =>0);
                       data.putIfAbsent('account_group_id[$i]', () =>0);
                       data.putIfAbsent('total_price[$i]', () =>0);
                       data.putIfAbsent('discount_id[$i]', () =>ct[i].cartItem.discount.toString());
                       data.putIfAbsent('per_unit_discount[$i]', () =>0);
                       data.putIfAbsent('discount_type[$i]', () =>ct[i].cartItem.discountType);
                     }

                      data.putIfAbsent('comment', () => _commentController.text);
                      data.putIfAbsent('ship_to_customer_address', () => shipToCustomerAddress);

                      print(data.toString());
                    }else{
                      _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                    }
                  },
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Create Order".toUpperCase(),
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
//              SizedBox(
//                height: 20.0,
//              ),
//              Container(
//                height: 40.0,
//                width: 150.0,
//                child: RaisedButton(
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.circular(25.0),
//                      side: BorderSide(color: Colors.grey)),
//                  onPressed: () async {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                    if (cart.items.length > 0) {
//                      List<Cart> ct = [];
//                      ct = cart.items
//                          .map((e) => Cart(id: e.id, cartItem: e))
//                          .toList();
//                      Map<String,dynamic>  data = Map();
//                      for (int i = 0; i < ct.length; i++) {
//                        data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
//                        data.putIfAbsent('quantity[$i]', () =>ct[i].cartItem.quantity);
//                        data.putIfAbsent('unit_price[$i]', () =>ct[i].cartItem.price);
//                        data.putIfAbsent('is_non_inventory[$i]', () =>ct[i].cartItem.isNonInventory);
//                        data.putIfAbsent('discount[$i]', () =>ct[i].cartItem.discount);
//                      }
//                      data.putIfAbsent('customer_shipping_address_id', () =>selectedAddressId);
//                    FormData formData = FormData.fromMap(data);
//
//                    if (selectedAddressId != null) {
//                        setState(() {
//                          _isLoading = true;
//                        });
//                        final response = await Provider.of<Orders>(
//                            context,
//                            listen: false)
//                            .addOrder(formData);
//                        if (response != null) {
//                          setState(() {
//                            _isLoading = false;
//                          });
//                          await cart.clearCartTable();
//                          Navigator.of(context).pushNamed(
//                              ProductsOverviewScreen
//                                  .routeName);
//                          Flushbar(
//                            duration: Duration(seconds: 10),
//                            margin: EdgeInsets.only(bottom: 2),
//                            padding: EdgeInsets.all(10),
//                            borderRadius: 8,
//                            backgroundColor: Colors.green.shade400,
//                            boxShadows: [
//                              BoxShadow(
//                                color: Colors.black45,
//                                offset: Offset(3, 3),
//                                blurRadius: 3,
//                              ),
//                            ],
//                            // All of the previous Flushbars could be dismissed by swiping down
//                            // now we want to swipe to the sides
//                            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//                            // The default curve is Curves.easeOut
//                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
//                            title: 'Order confirmation',
//                            message: response['msg'],
//                            mainButton: FlatButton(
//                              child: Text('view order'),
//                              onPressed: () {
//                                Navigator.of(context).pushNamed(
//                                    OrdersScreen.routeName);
//                              },
//                            ),
//
//                          )..show(context);
////                          showDialog(
////                              context: context,
////                              barrierDismissible: false,
////                              builder: (ctx) => AlertDialog(
////                                title: Text('Order confirmation'),
////                                content: Text(response['msg']),
////                                actions: <Widget>[
////                                  FlatButton(
////                                    child: Text('view order'),
////                                    onPressed: () {
////                                      Navigator.of(context).pushNamed(
////                                          OrdersScreen.routeName);
////                                    },
////                                  ),
////                                  FlatButton(
////                                    child: Text('create another'),
////                                    onPressed: () {
////                                      Navigator.of(context).pushNamed(
////                                          ProductsOverviewScreen
////                                              .routeName);
////                                    },
////                                  )
////                                ],
////                              ));
//                        } else {
//                          Flushbar(
//                            duration: Duration(seconds: 5),
//                            margin: EdgeInsets.only(bottom: 2),
//                            padding: EdgeInsets.all(10),
//                            borderRadius: 8,
//                            backgroundColor: Colors.red.shade400,
//                            boxShadows: [
//                              BoxShadow(
//                                color: Colors.black45,
//                                offset: Offset(3, 3),
//                                blurRadius: 3,
//                              ),
//                            ],
//                            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
//                            title: 'Order confirmation',
//                            message: 'Something wrong. Please try again',
//                          )..show(context);
//                        }
//                      } else {
//                        _scaffoldKey.currentState.showSnackBar(_snackBar(
//                            'Please select a delivery address or create new one'));
//                      }
//                    }else{
//                      _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
//                    }
//                  },
//                  color: Theme.of(context).primaryColor,
//                  textColor: Colors.white,
//                  child: Text("CONFIRM ORDER".toUpperCase(),
//                      style: TextStyle(fontSize: 14)),
//                ),
//              ),
            ],
          ),
        ));
  }
}

