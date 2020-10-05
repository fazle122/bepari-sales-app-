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
import 'package:sales_app/screens/order_list_screen.dart';
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

  final Cart cart;
  final invoiceId;
  CreateOrderScreen({this.cart,this.invoiceId});


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
  double invoiceVat = 0.0;

  double individualDiscount = 0.0;






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
    final cartInfo = ModalRoute.of(context).settings.arguments as Cart;
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

                    });
                  },
                  items: _addCustomerMenuItems(customerInfo.getCustomersId),
                )
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

              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 40.0,
                width: 150.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.grey)),
                  onPressed: () async{
                    Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;

                    if (cart.items.length > 0) {
                      List<Cart> ct = [];
                      ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
                      Map<String,dynamic>  data = Map();
                      for (int i = 0; i < ct.length; i++) {
                        if(widget.invoiceId != null){
                          data.putIfAbsent('invoice_detail_id[$i]', () => ct[i].cartItem.id);
                        }
                        data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
                        data.putIfAbsent('quantity[$i]', () =>ct[i].cartItem.quantity);
                        data.putIfAbsent('vat_rate[$i]', () =>ct[i].cartItem.vatRate.toString());
                        data.putIfAbsent('total_vat[$i]', () =>ct[i].cartItem.vatRate!= null?(ct[i].cartItem.vatRate * ct[i].cartItem.quantity):0.0);
                        data.putIfAbsent('item_total_discount[$i]', () =>ct[i].cartItem.perUnitDiscount !=null ?ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity:0.0);
                        data.putIfAbsent('total_amount[$i]', () =>
                        ct[i].cartItem.perUnitDiscount !=null ?
                        (ct[i].cartItem.price*ct[i].cartItem.quantity)-(ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity):
                        ct[i].cartItem.price*ct[i].cartItem.quantity);
                        data.putIfAbsent('accounts_group_id[$i]', () => ct[i].cartItem.salesAccountsGroupId);
                        data.putIfAbsent('is_non_inventory[$i]', () =>ct[i].cartItem.isNonInventory);
                        data.putIfAbsent('total_price[$i]', () =>
                        ct[i].cartItem.vatRate!= null?
                        (ct[i].cartItem.quantity*ct[i].cartItem.price) + (ct[i].cartItem.vatRate * ct[i].cartItem.quantity)
                            :(ct[i].cartItem.quantity*ct[i].cartItem.price));
                        data.putIfAbsent('unit_price[$i]', () =>ct[i].cartItem.price);
                        data.putIfAbsent('discount_id[$i]', () =>ct[i].cartItem.discountId!= null?ct[i].cartItem.discountId.toString():0);
                        data.putIfAbsent('per_unit_discount[$i]', () =>ct[i].cartItem.perUnitDiscount !=null ?ct[i].cartItem.perUnitDiscount:0.0);
                        data.putIfAbsent('discount_type[$i]', () =>ct[i].cartItem.discountType!= null?ct[i].cartItem.discountType:'amount');
                      }

                      for(int i = 0;i<ct.length; i++){
                        invoiceVat += ct[i].cartItem.vatRate!= null?(ct[i].cartItem.vatRate * ct[i].cartItem.quantity):0.0;
                        individualDiscount += ct[i].cartItem.perUnitDiscount != null ? ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity:0.0;

                      }

                      var totalDiscount = individualDiscount+overAllDiscount;
                      var totalBeforeVat = cart.totalAmount.toDouble() - totalDiscount.toDouble();
                      var invoiceAmount = invoiceVat.toDouble() + totalBeforeVat.toDouble();

                      // print('customer_id --' + selectedCustomerId);
                      // print('branch_id --' + selectedBranchId);
                      // print('sub_total --' + cart.totalAmount.toString());
                      // print('invoice_amount --' + invoiceAmount.toString());
                      // print('invoice_vat --' + invoiceVat.toString());
                      // print('total_before_vat --' +  totalBeforeVat.toString());
                      // print('total_discount --' + totalDiscount.toString());
                      // print('delivery_date --' + deliveryDate.toString());
                      // print('due_date --' + dueDate.toString());
                      // print('invoice_date --' + invoiceDate.toString());
                      // print('overall_discount --' + overAllDiscount.toString());
                      // print('sales_source --' + salesSource.toString());
                      // print(data.toString());


                      data.putIfAbsent('customer_id', () => selectedCustomerId);
                      data.putIfAbsent('branch_id', () => selectedBranchId);
                      data.putIfAbsent('sub_total', () => cart.totalAmount);
                      data.putIfAbsent('invoice_amount', () => invoiceAmount);
                      data.putIfAbsent('invoice_vat', () => invoiceVat);
                      data.putIfAbsent('total_before_vat', () => totalBeforeVat);
                      data.putIfAbsent('total_discount', () => totalDiscount);
                      data.putIfAbsent('delivery_date', () => deliveryDate.toString());
                      data.putIfAbsent('due_date', () => dueDate.toString());
                      data.putIfAbsent('invoice_date', () => invoiceDate.toString());
                      data.putIfAbsent('overall_discount', () => overAllDiscount);
                      data.putIfAbsent('sales_source', () => salesSource);

                      data.putIfAbsent('comment', () => _commentController.text);
                      data.putIfAbsent('ship_to_customer_address', () => shipToCustomerAddress);

                      FormData formData;
                      // if (selectedAddressId != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        var response;
                        if(widget.invoiceId == null){
                          formData = FormData.fromMap(data);
                          response = await Provider.of<Orders>(context, listen: false).createInvoice(formData);
                        }else{
                          data.putIfAbsent('invoice_id', () => widget.invoiceId);
                          formData = FormData.fromMap(data);
                          response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData,widget.invoiceId);
                        }
                        if (response != null) {
                          setState(() {
                            _isLoading = false;
                          });
                          await cart.clearCartTable();
                          Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
                          Flushbar(
                            duration: Duration(seconds: 10),
                            margin: EdgeInsets.only(bottom: 2),
                            padding: EdgeInsets.all(10),
                            borderRadius: 8,
                            backgroundColor: Colors.green.shade400,
                            boxShadows: [
                              BoxShadow(
                                color: Colors.black45,
                                offset: Offset(3, 3),
                                blurRadius: 3,
                              ),
                            ],
                            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                            title: 'Order confirmation',
                            message: response['msg'],
                            mainButton: FlatButton(
                              child: Text('view order'),
                              onPressed: () {
                                Navigator.of(context).pushNamed(OrderListScreen.routeName);
                              },
                            ),

                          )..show(context);
                        } else {
                          Flushbar(
                            duration: Duration(seconds: 5),
                            margin: EdgeInsets.only(bottom: 2),
                            padding: EdgeInsets.all(10),
                            borderRadius: 8,
                            backgroundColor: Colors.red.shade400,
                            boxShadows: [
                              BoxShadow(
                                color: Colors.black45,
                                offset: Offset(3, 3),
                                blurRadius: 3,
                              ),
                            ],
                            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                            title: 'Order confirmation',
                            message: 'Something wrong. Please try again',
                          )..show(context);
                        }
                    }else{
                      _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                    }

                  },
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Create Invoice".toUpperCase(),
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ));
  }
}

