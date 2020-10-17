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
import 'package:sales_app/screens/due_orders_screen.dart';
import 'package:sales_app/screens/order_list_screen.dart';
import 'package:sales_app/screens/orders_screen.dart';
import 'package:sales_app/screens/pending_order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/confirm_invoice_dialog.dart';
import 'package:sales_app/widgets/create_shippingAddress_dialog.dart';
import 'package:sales_app/widgets/order_item.dart';
import 'package:sales_app/widgets/shipping_address_item.dart';
import 'package:sales_app/widgets/update_shippingAddress_dialog.dart';
import 'package:toast/toast.dart';
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
  final _form = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressItem selectedAddress;
  String selectedAddressId;
  String selectedBranchId;
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
  double _receiptAmount = 0.0;
  double individualDiscount = 0.0;
  String comments;



  @override
  void initState() {
    super.initState();
  }

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


  Widget _selectCustomerDropdown(Map<String, dynamic> customerData) {
        return DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
          ),
          hint: Text('select customer'),
          value: selectedCustomerId,
          onSaved: (value) {
          },
          validator: (value) {
            if (value == null) {
              return 'please select customer';
            }
            return null;
          },
          onChanged: (newValue) {
            selectedCustomerId = newValue;
          },
          items: _addCustomerMenuItems(customerData),
        );
  }

  Widget _selectBranchDropdown(Map<String, dynamic> branchData) {
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.outlined_flag,
          color: Theme.of(context).primaryColor,
        ),
        border: OutlineInputBorder(),
      ),
      hint: Text('select branch'),
      value: selectedBranchId,
      onSaved: (value) {
      },
      validator: (value) {
        if (value == null) {
          return 'please select branch';
        }
        return null;
      },
      onChanged: (newValue) {
        selectedBranchId = newValue;
      },
      items: _addBranchMenuItems(branchData),
    );
  }

  Widget invoiceAmountField() {
    return TextFormField(
      initialValue: _receiptAmount.toString(),
      keyboardType: TextInputType.number,
      onChanged: (value){
        setState(() {
          _receiptAmount = double.parse(value);
        });
      },
      // validator: (value) {
      //   if (value.isEmpty) {
      //     return 'please inter amount';
      //   }
      //   return null;
      // },
      onSaved: (value) {
        _receiptAmount = double.parse(value);
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.attach_money,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'user name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget commentsField() {
    return TextFormField(
      maxLines: 5,
      minLines: 3,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter comments';
        }
        return null;
      },
      onSaved: (value) {
        comments = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.comment,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'please enter your comments',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
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

  _confirmInvoice(Cart cart,var invoiceStatus,var partialAmount) async{
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    print(selectedCustomerId.toString());
    print(selectedBranchId.toString());
    print(_receiptAmount.toString());
    print(partialAmount.toString());
    print(comments.toString());

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

    data.putIfAbsent('comment', () => comments);
    data.putIfAbsent('ship_to_customer_address', () => shipToCustomerAddress);

    FormData formData;

    if(widget.invoiceId == null){
      formData = FormData.fromMap(data);
      if(invoiceStatus == null && partialAmount == null) {
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Save invoice')),
              content:
              Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to save invoice only?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Save'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
                    if(response != null){
                      await cart.clearCartTable();
                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));

      }
      else if(invoiceStatus == 5 && partialAmount == null){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Save and pay invoice')),
              content:
              Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to save and pay invoice?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Save and pay'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
                    if(response != null){
                      await cart.clearCartTable();
                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));

      }else if(invoiceStatus == 4 || invoiceStatus == 1){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        data.putIfAbsent('receipt_amount', () => partialAmount);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Save with due invoice')),
              content:
              Container(
                height: 100,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Current payment : '),
                        SizedBox(width: 10,),
                        Text(partialAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to save with due invoice?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Save with due'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
                    if(response != null){
                      await cart.clearCartTable();
                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));
      }
    }else{
      // data.putIfAbsent('invoice_id', () => widget.invoiceId);
      formData = FormData.fromMap(data);

      if(invoiceStatus == null && partialAmount == null) {
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Update invoice')),
              content:
              Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to update invoice only?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Update'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData,widget.invoiceId);
                    if(response != null){
                      await cart.clearCartTable();
                      cart.invoiceIdForUpdate = null;
                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));

      }
      else if(invoiceStatus == 5 && partialAmount == null){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Update and pay invoice')),
              content:
              Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to update and pay invoice?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Update and pay'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData,widget.invoiceId);
                    if(response != null){
                      await cart.clearCartTable();
                      cart.invoiceIdForUpdate = null;
                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));

      }else if(invoiceStatus == 4 || invoiceStatus == 1){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        data.putIfAbsent('receipt_amount', () => partialAmount);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
            // ConfirmInvoiceDialog(formData,null,null)
            AlertDialog(
              title: Center(child:Text('Update with due invoice')),
              content:
              Container(
                height: 100,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Invoice amount : '),
                        SizedBox(width: 10,),
                        Text(invoiceAmount.toString())
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Current payment : '),
                        SizedBox(width: 10,),
                        Text(partialAmount.toString())
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child:Text('Are your sure, you want to update with due invoice?'),)
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Update with due'),
                  onPressed: () async{
                    setState(() {
                      _isLoading = true;
                    });
                    var response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData,widget.invoiceId);
                    if(response != null){
                      await cart.clearCartTable();
                      cart.invoiceIdForUpdate = null;

                      Toast.show(response['msg'], context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
                    }else{
                      Toast.show('Something went wrong, please try again.', context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ));
      }
      // formData = FormData.fromMap(data);
      // showDialog(
      //     barrierDismissible: false,
      //     context: context,
      //     builder: (context) => ConfirmInvoiceDialog(formData,invoiceStatus,widget.invoiceId)
      // );
    }
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
          child: Form(
        key: _form,
          child:

          Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  child: _selectCustomerDropdown(customerInfo.getCustomersId)
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  child: _selectBranchDropdown(customerInfo.getBranchId)
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  child: invoiceAmountField()
              ),

              SizedBox(
                height: 20.0,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  child:  commentsField()
              ),

              SizedBox(
                height: 20.0,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 40.0,
                    width: 120.0,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(widget.invoiceId == null ? "Save \n Invoice".toUpperCase():"Update \n Invoice".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.grey)),
                      onPressed: () async{
                        Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
                        if (cart.items.length > 0) {
                          await _confirmInvoice(cart,null,null);
                        }else{
                          _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                        }
                      },

                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: 120.0,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(widget.invoiceId == null ? "Save \n and paid".toUpperCase():"Update \n and paid".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.grey)),
                      onPressed: () async{
                        Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
                        if (cart.items.length > 0) {
                          await _confirmInvoice(cart,5,null);
                        }else{
                          _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                        }

                      },
                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: 120.0,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(widget.invoiceId == null ? "Save \n with Due".toUpperCase():"Update \n with Due".toUpperCase(),textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.grey)),
                      onPressed: () async{
                        Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
                        if (cart.items.length > 0) {
                          if(_receiptAmount == 0.0){
                            await _confirmInvoice(cart, 1, _receiptAmount);
                          }else {
                            await _confirmInvoice(cart, 4, _receiptAmount);
                          }
                        }else{
                          _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ))
        ));
  }
}





























// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
// import 'package:flushbar/flushbar.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:sales_app/base_state.dart';
// import 'package:sales_app/data_helper/local_db_helper.dart';
// import 'package:sales_app/providers/cart.dart';
// import 'package:sales_app/providers/orders.dart';
// import 'package:sales_app/providers/shipping_address.dart';
// import 'package:sales_app/screens/order_list_screen.dart';
// import 'package:sales_app/screens/orders_screen.dart';
// import 'package:sales_app/screens/pending_order_list_screen.dart';
// import 'package:sales_app/screens/products_overview_screen.dart';
// import 'package:sales_app/widgets/app_drawer.dart';
// import 'package:sales_app/widgets/confirm_invoice_dialog.dart';
// import 'package:sales_app/widgets/create_shippingAddress_dialog.dart';
// import 'package:sales_app/widgets/order_item.dart';
// import 'package:sales_app/widgets/shipping_address_item.dart';
// import 'package:sales_app/widgets/update_shippingAddress_dialog.dart';
// import 'package:toast/toast.dart';
// //import 'package:shoptempdb/widgets/update_shippingAddress_dialog_test.dart';
//
//
// class CreateOrderScreen extends StatefulWidget {
//   static const routeName = '/shipping_address';
//
//   final Cart cart;
//   final invoiceId;
//   CreateOrderScreen({this.cart,this.invoiceId});
//
//
//   @override
//   _CreateOrderScreenState createState() => _CreateOrderScreenState();
// }
//
// class _CreateOrderScreenState extends BaseState<CreateOrderScreen> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   AddressItem selectedAddress;
//   String selectedAddressId;
//   String selectedBranchId;
//   TextEditingController _commentController = TextEditingController();
//   TextEditingController _amountController = TextEditingController();
//   DateTime deliveryDate = DateTime.now();
//   DateTime invoiceDate = DateTime.now();
//   DateTime dueDate = DateTime.now();
//   var shipToCustomerAddress = 1;
//   final format = DateFormat('yyyy-MM-dd');
//   var _isInit = true;
//   var _isLoading = false;
//
//
//   String selectedCustomerId;
//   int salesSource = 6;
//   int overAllDiscount = 0;
//   double invoiceVat = 0.0;
//   double _dueAmount = 0.0;
//   double individualDiscount = 0.0;
//
//
//
//
//
//
//  @override
//  void initState() {
//    super.initState();
//    _amountController.text = _dueAmount.toString();
//  }
//
//   @override
//   void didChangeDependencies() {
//     if (_isInit) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = true;
//       });
//       Provider.of<Orders>(context).fetchCustomers().then((_) {
//         Provider.of<Orders>(context,listen: false).fetchBranchInfo();
//         if (!mounted) return;
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//     _isInit = false;
//     super.didChangeDependencies();
//   }
//
//   setSelectedAddress(AddressItem address) {
//     setState(() {
//       selectedAddress = address;
//       selectedAddressId = address.id;
//     });
//   }
//
//
//
//   List<DropdownMenuItem> _addCustomerMenuItems(Map<String, dynamic> items) {
//     List<DropdownMenuItem> itemWidgets = List();
//     items.forEach((key, value) {
//       itemWidgets.add(DropdownMenuItem(
//         value: key,
//         child: value['name']!=null? Text(value['name']):Text('NA'),
//       ));
//     });
//     return itemWidgets;
//   }
//
//   List<DropdownMenuItem> _addBranchMenuItems(Map<String, dynamic> items) {
//     List<DropdownMenuItem> itemWidgets = List();
//     items.forEach((key, value) {
//       itemWidgets.add(DropdownMenuItem(
//         value: key,
//         child: value['name']!=null? Text(value['name']):Text('NA'),
//       ));
//     });
//     return itemWidgets;
//   }
//
//   Widget _snackBar(String text) {
//     return SnackBar(
//       backgroundColor: Theme.of(context).primaryColor,
//       content: Container(
//           padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: Text(text)),
//       duration: Duration(seconds: 2),
//     );
//   }
//
//   _confirmInvoice(Cart cart,var invoiceStatus,var partialAmount) async{
//     List<Cart> ct = [];
//     ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
//     Map<String,dynamic>  data = Map();
//     for (int i = 0; i < ct.length; i++) {
//       if(widget.invoiceId != null){
//         data.putIfAbsent('invoice_detail_id[$i]', () => ct[i].cartItem.id);
//       }
//       data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
//       data.putIfAbsent('quantity[$i]', () =>ct[i].cartItem.quantity);
//       data.putIfAbsent('vat_rate[$i]', () =>ct[i].cartItem.vatRate.toString());
//       data.putIfAbsent('total_vat[$i]', () =>ct[i].cartItem.vatRate!= null?(ct[i].cartItem.vatRate * ct[i].cartItem.quantity):0.0);
//       data.putIfAbsent('item_total_discount[$i]', () =>ct[i].cartItem.perUnitDiscount !=null ?ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity:0.0);
//       data.putIfAbsent('total_amount[$i]', () =>
//       ct[i].cartItem.perUnitDiscount !=null ?
//       (ct[i].cartItem.price*ct[i].cartItem.quantity)-(ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity):
//       ct[i].cartItem.price*ct[i].cartItem.quantity);
//       data.putIfAbsent('accounts_group_id[$i]', () => ct[i].cartItem.salesAccountsGroupId);
//       data.putIfAbsent('is_non_inventory[$i]', () =>ct[i].cartItem.isNonInventory);
//       data.putIfAbsent('total_price[$i]', () =>
//       ct[i].cartItem.vatRate!= null?
//       (ct[i].cartItem.quantity*ct[i].cartItem.price) + (ct[i].cartItem.vatRate * ct[i].cartItem.quantity)
//           :(ct[i].cartItem.quantity*ct[i].cartItem.price));
//       data.putIfAbsent('unit_price[$i]', () =>ct[i].cartItem.price);
//       data.putIfAbsent('discount_id[$i]', () =>ct[i].cartItem.discountId!= null?ct[i].cartItem.discountId.toString():0);
//       data.putIfAbsent('per_unit_discount[$i]', () =>ct[i].cartItem.perUnitDiscount !=null ?ct[i].cartItem.perUnitDiscount:0.0);
//       data.putIfAbsent('discount_type[$i]', () =>ct[i].cartItem.discountType!= null?ct[i].cartItem.discountType:'amount');
//     }
//
//     for(int i = 0;i<ct.length; i++){
//       invoiceVat += ct[i].cartItem.vatRate!= null?(ct[i].cartItem.vatRate * ct[i].cartItem.quantity):0.0;
//       individualDiscount += ct[i].cartItem.perUnitDiscount != null ? ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity:0.0;
//
//     }
//
//     var totalDiscount = individualDiscount+overAllDiscount;
//     var totalBeforeVat = cart.totalAmount.toDouble() - totalDiscount.toDouble();
//     var invoiceAmount = invoiceVat.toDouble() + totalBeforeVat.toDouble();
//
//
//     data.putIfAbsent('customer_id', () => selectedCustomerId);
//     data.putIfAbsent('branch_id', () => selectedBranchId);
//     data.putIfAbsent('sub_total', () => cart.totalAmount);
//     data.putIfAbsent('invoice_amount', () => invoiceAmount);
//     data.putIfAbsent('invoice_vat', () => invoiceVat);
//     data.putIfAbsent('total_before_vat', () => totalBeforeVat);
//     data.putIfAbsent('total_discount', () => totalDiscount);
//     data.putIfAbsent('delivery_date', () => deliveryDate.toString());
//     data.putIfAbsent('due_date', () => dueDate.toString());
//     data.putIfAbsent('invoice_date', () => invoiceDate.toString());
//     data.putIfAbsent('overall_discount', () => overAllDiscount);
//     data.putIfAbsent('sales_source', () => salesSource);
//
//     data.putIfAbsent('comment', () => _commentController.text);
//     data.putIfAbsent('ship_to_customer_address', () => shipToCustomerAddress);
//
//     FormData formData;
//     setState(() {
//       _isLoading = true;
//     });
//     if(widget.invoiceId == null){
//       formData = FormData.fromMap(data);
//       if(invoiceStatus == null && partialAmount == null) {
//         formData = FormData.fromMap(data);
//              showDialog(
//               barrierDismissible: false,
//               context: context,
//                builder: (context) =>
//                    // ConfirmInvoiceDialog(formData,null,null)
//                AlertDialog(
//                  title: Center(child:Text('Save invoice')),
//                  content:
//                  Container(
//                    height: 80,
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            Text('Invoice amount : '),
//                            SizedBox(width: 10,),
//                            Text(invoiceAmount.toString())
//                          ],
//                        ),
//                        SizedBox(height: 20,),
//                        Row(
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            Flexible(
//                            child:Text('Are your sure, you want to save invoice only?'),)
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                  actions: <Widget>[
//                    FlatButton(
//                      child: Text('Save'),
//                      onPressed: () async{
//                        var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
//                        if(response != null){
//                          await cart.clearCartTable();
//                          Toast.show(response['msg'], context,
//                              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                          Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
//                        }else{
//                          Toast.show('Something went wrong, please try again.', context,
//                              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                          Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//                        }
//                      },
//                    ),
//                    FlatButton(
//                      child: Text('Cancel'),
//                      onPressed: () {
//                        Navigator.of(context).pop(true);
//                      },
//                    ),
//                  ],
//                ));
//
//       }
//       else if(invoiceStatus == 5 && partialAmount == null){
//         data.putIfAbsent('invoice_status', () => invoiceStatus);
//         formData = FormData.fromMap(data);
//         showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (context) =>
//             // ConfirmInvoiceDialog(formData,null,null)
//             AlertDialog(
//               title: Center(child:Text('Save and pay invoice')),
//               content:
//               Container(
//                 height: 80,
//                 child: Column(
//                   children: <Widget>[
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Text('Invoice amount : '),
//                         SizedBox(width: 10,),
//                         Text(invoiceAmount.toString())
//                       ],
//                     ),
//                     SizedBox(height: 20,),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Flexible(
//                           child:Text('Are your sure, you want to save and pay invoice?'),)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Save and pay'),
//                   onPressed: () async{
//                     var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
//                     if(response != null){
//                       await cart.clearCartTable();
//                       Toast.show(response['msg'], context,
//                           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                       Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//                     }else{
//                       Toast.show('Something went wrong, please try again.', context,
//                           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                       Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//                     }
//                   },
//                 ),
//                 FlatButton(
//                   child: Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                 ),
//               ],
//             ));
//
//       }else if(invoiceStatus == 4 || invoiceStatus == 1){
//         data.putIfAbsent('invoice_status', () => invoiceStatus);
//         data.putIfAbsent('receipt_amount', () => partialAmount);
//         formData = FormData.fromMap(data);
//         showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (context) =>
//             // ConfirmInvoiceDialog(formData,null,null)
//             AlertDialog(
//               title: Center(child:Text('Save with due invoice')),
//               content:
//               Container(
//                 height: 100,
//                 child: Column(
//                   children: <Widget>[
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Text('Invoice amount : '),
//                         SizedBox(width: 10,),
//                         Text(invoiceAmount.toString())
//                       ],
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Text('Current payment : '),
//                         SizedBox(width: 10,),
//                         Text(partialAmount.toString())
//                       ],
//                     ),
//                     SizedBox(height: 20,),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Flexible(
//                           child:Text('Are your sure, you want to save with due invoice?'),)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Save with due'),
//                   onPressed: () async{
//                     var response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
//                     if(response != null){
//                       await cart.clearCartTable();
//                       Toast.show(response['msg'], context,
//                           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                       Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName);
//                     }else{
//                       Toast.show('Something went wrong, please try again.', context,
//                           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                       Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//                     }
//                   },
//                 ),
//                 FlatButton(
//                   child: Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                 ),
//               ],
//             ));
//       }
//     }else{
//       data.putIfAbsent('invoice_id', () => widget.invoiceId);
//       formData = FormData.fromMap(data);
//       showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (context) => ConfirmInvoiceDialog(formData,invoiceStatus,widget.invoiceId)
//       );
//       // response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData,widget.invoiceId);
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//    final customerInfo = Provider.of<Orders>(context);
//     final cartInfo = ModalRoute.of(context).settings.arguments as Cart;
//     return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: Text('Confirm order'),
//         ),
//         drawer: AppDrawer(),
//         body: _isLoading
//             ? Center(
//           child: CircularProgressIndicator(),
//         )
//             : SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//
//
//               SizedBox(
//                 height: 10.0,
//               ),
//               Container(
//                 child: DropdownButton(
//                   isExpanded: true,
//                   hint: Text('Select Customer'),
//                   value: selectedCustomerId,
//                   onChanged: (newValue) {
//                     setState(() {
//                       selectedCustomerId = newValue;
//
//                     });
//                   },
//                   items: _addCustomerMenuItems(customerInfo.getCustomersId),
//                 )
//               ),
//               SizedBox(
//                 height: 10.0,
//               ),
//               Container(
//                   child: DropdownButton(
//                     isExpanded: true,
//                     hint: Text('Select Branch'),
//                     value: selectedBranchId,
//                     onChanged: (newValue) {
//                       setState(() {
//                         selectedBranchId = newValue;
//
//                       });
//                     },
//                     items: _addBranchMenuItems(customerInfo.getBranchId),
//                   )
//               ),
//               SizedBox(
//                 height: 10.0,
//               ),
//               Container(
//                   child: TextField(
//                       controller: _amountController,
//
//                       keyboardType: TextInputType.text,
//                       decoration: InputDecoration(
//                         hintText: 'Please insert amount',
//                         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                         // hintText: data,
//
//                       )
//                   )
//               ),
//
//               SizedBox(
//                 height: 20.0,
//               ),
//               Container(
//                   child: TextField(
//                     controller: _commentController,
//                       keyboardType: TextInputType.text,
//                       decoration: InputDecoration(
//                         hintText: 'write a comment',
//                         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                         // hintText: data,
//
//                       )
//                   )
//               ),
//
//               SizedBox(
//                 height: 20.0,
//               ),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   Container(
//                     height: 40.0,
//                     width: 120.0,
//                     child: RaisedButton(
//                       color: Theme.of(context).primaryColor,
//                       textColor: Colors.white,
//                       child: Text("Save \n Invoice".toUpperCase(),textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 14)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                           side: BorderSide(color: Colors.grey)),
//                       onPressed: () async{
//                         Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
//                         if (cart.items.length > 0) {
//                           await _confirmInvoice(cart,null,null);
//                         }else{
//                           _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
//                         }
//                       },
//
//                     ),
//                   ),
//                   Container(
//                     height: 40.0,
//                     width: 120.0,
//                     child: RaisedButton(
//                       color: Theme.of(context).primaryColor,
//                       textColor: Colors.white,
//                       child: Text("Save \n and paid".toUpperCase(),textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 14)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                           side: BorderSide(color: Colors.grey)),
//                       onPressed: () async{
//                         Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
//                         if (cart.items.length > 0) {
//                           await _confirmInvoice(cart,5,null);
//                         }else{
//                           _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
//                         }
//
//                       },
//                     ),
//                   ),
//                   Container(
//                     height: 40.0,
//                     width: 120.0,
//                     child: RaisedButton(
//                       color: Theme.of(context).primaryColor,
//                       textColor: Colors.white,
//                       child: Text("Save \n with Due".toUpperCase(),textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 14)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                           side: BorderSide(color: Colors.grey)),
//                       onPressed: () async{
//                         Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
//                         if (cart.items.length > 0) {
//                           if(_amountController.text == _dueAmount.toString()){
//                             await _confirmInvoice(cart, 1, _amountController.text);
//                           }else {
//                             await _confirmInvoice(cart, 4, _amountController.text);
//                           }
//                         }else{
//                           _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
//                         }
//                         // Cart cart = widget.invoiceId == null ?  cartInfo:widget.cart;
//                         // if(cart.items.length < 0){
//                         //   _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
//                         // }else{
//                         //   await _confirmInvoice(cart,4,_amountController.text);
//                         //   // print(_amountController.text);
//                         // }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10.0,
//               ),
//             ],
//           ),
//         ));
//   }
// }
//
