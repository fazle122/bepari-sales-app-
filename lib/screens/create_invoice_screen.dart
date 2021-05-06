import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:sales_app/base_state.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/shipping_address.dart';
import 'package:sales_app/screens/due_orders_screen.dart';
import 'package:sales_app/screens/pending_order_list_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:toast/toast.dart';
import 'package:velocity_x/velocity_x.dart';


class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/shipping_address';

  final Cart cart;
  final invoiceId;
  final discountType;
  final discountValue;
  CreateOrderScreen({this.cart,this.invoiceId,this.discountType,this.discountValue});


  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends BaseState<CreateOrderScreen> {
  final _form = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressItem selectedAddress;
  String selectedAddressId;
  String selectedBranchId;
  String selectedCustomerId;
  DateTime deliveryDate = DateTime.now();
  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  var shipToCustomerAddress = 1;
  final format = DateFormat('yyyy-MM-dd');
  var _isInit = true;
  var _isLoading = false;


  int salesSource = 6;
  int overAllDiscount = 0;
  List productWiseOverallDiscount = [0];
  List itemTotalDiscount = [];
  double invoiceVat = 0.0;
  double _receiptAmount = 0.0;
  double individualDiscount = 0.0;
  String comments;
  var overAllDiscountPercent = 0;
  bool discountType;


  @override
  void initState() {
    if(widget.discountValue != null && widget.discountValue > 0) {
      overAllDiscount = widget.discountValue;


      discountType = widget.discountType;
      print('value :' + widget.discountValue.toString());
      print('type :' + widget.discountType.toString());
    }
    super.initState();
  }


  @override
  void didChangeDependencies() {
    final orders = Provider.of<Orders>(context, listen:false);
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchCustomers().then((_) async{
        await Provider.of<Orders>(context,listen: false).fetchBranchInfo();

        if (!mounted) return;
        setState(() {
          selectedBranchId = orders.selectedBranch.toString();
          selectedCustomerId = orders.selectedCustomer.toString();
          print('bid :' + orders.selectedBranch.toString());
          print('cid :' + orders.selectedCustomer.toString());
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


  // Widget _selectCustomerDropdown(Map<String, dynamic> customerData) {
  //       return DropdownButtonFormField(
  //         isExpanded: true,
  //         decoration: InputDecoration(
  //           prefixIcon: Icon(
  //             Icons.person,
  //             color: Theme.of(context).primaryColor,
  //           ),
  //           border: OutlineInputBorder(),
  //         ),
  //         hint: Text('select customer'),
  //         value: selectedCustomerId,
  //         onSaved: (value) {
  //         },
  //         validator: (value) {
  //           if (value == null) {
  //             return 'please select customer';
  //           }
  //           return null;
  //         },
  //         onChanged: (newValue) {
  //           selectedCustomerId = newValue;
  //         },
  //         items: _addCustomerMenuItems(customerData),
  //       );
  // }
  //
  // Widget _selectBranchDropdown(Map<String, dynamic> branchData) {
  //   final orders = Provider.of<Orders>(context, listen:false);
  //   return DropdownButtonFormField(
  //     isExpanded: true,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(
  //         Icons.outlined_flag,
  //         color: Theme.of(context).primaryColor,
  //       ),
  //       border: OutlineInputBorder(),
  //     ),
  //     hint: Text('select branch'),
  //     value: selectedBranchId,
  //     onSaved: (value) {
  //     },
  //     validator: (value) {
  //       if (value == null) {
  //         return 'please select branch';
  //       }
  //       return null;
  //     },
  //     onChanged: (newValue) {
  //       selectedBranchId = newValue;
  //     },
  //     items: _addBranchMenuItems(orders.getBranchId),
  //   );
  // }

  // List<DropdownMenuItem> _addCustomerMenuItems(Map<String, dynamic> items) {
  //   List<DropdownMenuItem> itemWidgets = List();
  //   items.forEach((key, value) {
  //     itemWidgets.add(DropdownMenuItem(
  //       value: key,
  //       child: value['name']!=null? Text(value['name']):Text('NA'),
  //     ));
  //   });
  //   return itemWidgets;
  // }
  //
  // List<DropdownMenuItem> _addBranchMenuItems(Map<String, dynamic> items) {
  //   List<DropdownMenuItem> itemWidgets = List();
  //   items.forEach((key, value) {
  //     itemWidgets.add(DropdownMenuItem(
  //       value: key,
  //       child: value['name']!=null? Text(value['name']):Text('NA'),
  //     ));
  //   });
  //   return itemWidgets;
  // }

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
      // validator: (value) {
      //   if (value.isEmpty) {
      //     return 'please enter comments';
      //   }
      //   return null;
      // },
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


  Widget _snackBar(String text) {
    return SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: Text(text)),
      duration: Duration(seconds: 2),
    );
  }

  Widget _dialogWidget(String title,String confirmMessage,String btn1Txt,String btn2Txt,btn3Txt,FormData formData,Cart cart,double invoiceAmount,double partialAmount,int status){
    final orders = Provider.of<Orders>(context,listen: false);
    return AlertDialog(
      title: Center(child:Text(title)),
      content:
      Container(
        height: 120,
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
            SizedBox(height: 10,),
            partialAmount == null ? SizedBox(width:0.0,height: 0.0,):
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
                  child:Text(confirmMessage),)
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(btn1Txt),
          onPressed: () async{
            print('cp - ' + selectedCustomerId.toString());
            print('bp - ' + selectedBranchId.toString());
            setState(() {
              _isLoading = true;
            });
            var response;
            if(widget.invoiceId == null){
              response = await Provider.of<Orders>(context, listen: false).createInvoiceForSales(formData);
            }else{
              response = await Provider.of<Orders>(context, listen: false).updateInvoice(formData, widget.invoiceId);
            }
            if(response != null){
              await cart.clearCartTable();
              // await cart.removeSingleItem('1');
              orders.deliveryCharge = null;
              // Toast.show(response['msg'], context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              context.showToast(
                  msg: response['msg'],
                showTime: 5000,
                position: VxToastPosition.bottom,
              );
              status == 0 || status == 5 ?
              Navigator.of(context).pushReplacementNamed(PendingOrderListScreen.routeName):
              Navigator.of(context).pushReplacementNamed(DueOrderListScreen.routeName);
            }else{
              // Toast.show('Something went wrong, please try again.', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              context.showToast(
                msg: 'Something went wrong, please try again.',
                showTime: 5000,
                position: VxToastPosition.bottom,
                bgColor: Colors.red,
                textColor: Colors.white,
                
              );
              Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
            }
          },
        ),
        FlatButton(
          child: Text(btn2Txt),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  _calculateItemTotalDiscount(var cartItem,Cart cart){
    if(overAllDiscount > 0){
      for (int i = 0; i < cartItem.length; i++) {
        if(cartItem[i].discount == null){
          double itemDiscount = (overAllDiscount*cartItem[i].price)/cart.totalAmount;
          productWiseOverallDiscount.add(itemDiscount);
        }
        else{
          var sum = 0.0;
          for (int i = 0; i < cartItem.length; i++) {
            sum += cartItem[i].price - cartItem[i].discount;
          }
          for(int j = 0; j<cartItem.length; j++){
            double itemDiscount = (overAllDiscount*cartItem[i].price)/sum;
            double itemTotalDiscount = cartItem[i].discount + itemDiscount;
            productWiseOverallDiscount.add(itemTotalDiscount);

          }
        }
      }
    }
  }

  _calculateProductWiseOverallDiscount(var cartItem,Cart cart){
    if(overAllDiscount > 0){
      for (int i = 0; i < cartItem.length; i++) {
        if(cartItem[i].discount == null){
            double itemDiscount = (overAllDiscount*cartItem[i].price)/cart.totalAmount;
            productWiseOverallDiscount.add(itemDiscount);
        }
        else{
          var sum = 0.0;
          for (int i = 0; i < cartItem.length; i++) {
            sum += cartItem[i].price - cartItem[i].discount;
          }
          for(int j = 0; j<cartItem.length; j++){
            double itemDiscount = (overAllDiscount*cartItem[i].price)/sum;
            productWiseOverallDiscount.add(itemDiscount);

          }
        }
      }
    }
  }

  _confirmInvoice(Cart cart,var invoiceStatus,var partialAmount) async{
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    List<Cart> ct = [];
    ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
    // _calculateItemTotalDiscount(ct,cart);
    // _calculateProductWiseOverallDiscount(ct,cart);

    Map<String,dynamic>  data = Map();
    for (int i = 0; i < ct.length; i++) {
      if(widget.invoiceId != null){
        data.putIfAbsent('invoice_detail_id[$i]', () => ct[i].cartItem.id);
      }
      data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
      data.putIfAbsent('quantity[$i]', () =>ct[i].cartItem.quantity);
      data.putIfAbsent('vat_rate[$i]', () =>ct[i].cartItem.vatRate.toString());
      data.putIfAbsent('total_vat[$i]', () =>ct[i].cartItem.vatRate!= null?
      ct[i].cartItem.perUnitDiscount !=null?(ct[i].cartItem.vatRate * (ct[i].cartItem.price*ct[i].cartItem.quantity - ct[i].cartItem.perUnitDiscount*ct[i].cartItem.quantity))/100
      :(ct[i].cartItem.vatRate * (ct[i].cartItem.price*ct[i].cartItem.quantity))/100
          :0.0
      );
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

    //'total__amount' = item total valu - item total discount

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
    data.putIfAbsent('overall_discount_percent', () => overAllDiscountPercent);
    data.putIfAbsent('item_total_discount', () => itemTotalDiscount);
    data.putIfAbsent('productwise_overall_discount', () => productWiseOverallDiscount);
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
                _dialogWidget('Save invoice', 'Are your sure, you want to save invoice only?', 'Save', 'Cancel', null, formData,cart,invoiceAmount,null,0)
        );
      }
      else if(invoiceStatus == 5 && partialAmount == null){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                _dialogWidget('Save and pay invoice', 'Are your sure, you want to save and pay invoice?', 'Save and pay', 'Cancel', null, formData,cart,invoiceAmount,null,5)
        );

      }else if(invoiceStatus == 4 || invoiceStatus == 1){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        data.putIfAbsent('receipt_amount', () => partialAmount);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                _dialogWidget('Save with due invoice', 'Are your sure, you want to save with due invoice?', 'Save with due', 'Cancel', null, formData,cart,invoiceAmount,partialAmount,partialAmount==0.0?1:4)

        );
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
                _dialogWidget('Update invoice', 'Are your sure, you want to update invoice only?', 'Update', 'Cancel', null, formData,cart,invoiceAmount,null,0)
        );

      }
      else if(invoiceStatus == 5 && partialAmount == null){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                _dialogWidget('Update and pay invoice', 'Are your sure, you want to update and pay invoice?', 'Update and pay', 'Cancel', null, formData,cart,invoiceAmount,null,5)
        );

      }else if(invoiceStatus == 4 || invoiceStatus == 1){
        data.putIfAbsent('invoice_status', () => invoiceStatus);
        data.putIfAbsent('receipt_amount', () => partialAmount);
        formData = FormData.fromMap(data);
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                _dialogWidget('Update with due invoice', 'Are your sure, you want to update with due invoice?', 'Update with due', 'Cancel', null, formData,cart,invoiceAmount,partialAmount,partialAmount==0.0?1:4)
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final customerInfo = Provider.of<Orders>(context);
    final cartInfo = ModalRoute.of(context).settings.arguments as Cart;
    final orders = Provider.of<Orders>(context,listen: false);
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
                  // child: _selectCustomerDropdown(customerInfo.getCustomersId)
                child: DropdownWidget(
                  icon:Icons.person,
                  items:customerInfo.getCustomersId,
                  currentItem: selectedCustomerId.toString(),
                  itemCallBack: (String value) {
                    this.selectedCustomerId = value;
                    print(selectedCustomerId.toString());
                  },
                  hintText: 'Select customer'),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10.0,right: 10.0),
                  // child: _selectBranchDropdown(customerInfo.getBranchId)
                  child: DropdownWidget(
                    icon:Icons.outlined_flag,
                    items:customerInfo.getBranchId,
                    currentItem: selectedBranchId,
                    itemCallBack: (String value) {
                      this.selectedBranchId = value;
                      print(selectedBranchId.toString());
                    },
                    hintText: 'Select branch',),
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










class DropdownWidget extends StatefulWidget {
  final IconData icon;
  final Map<String,dynamic> items;
  final ValueChanged<String> itemCallBack;
  final String currentItem;
  final String hintText;

  DropdownWidget({
    this.icon,
    this.items,
    this.itemCallBack,
    this.currentItem,
    this.hintText,
  });

  @override
  State<StatefulWidget> createState() => _DropdownState(currentItem);
}

class _DropdownState extends State<DropdownWidget> {
  List<DropdownMenuItem<String>> dropDownItems = [];
  String currentItem;

  _DropdownState(this.currentItem);


  @override
  void initState() {
    super.initState();
    widget.items.forEach((key, value) {
      dropDownItems.add(DropdownMenuItem(
        value: key,
        child: value['name']!=null? Text(value['name']):Text('NA'),
      ));
    });
  }


  @override
  void didUpdateWidget(DropdownWidget oldWidget) {
    if (this.currentItem != widget.currentItem) {
      setState(() {
        this.currentItem = widget.currentItem;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    widget.icon,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: OutlineInputBorder(),
                ),
                value: currentItem,
                isExpanded: true,
                items: dropDownItems,
                onChanged: (selectedItem) => setState(() {
                  currentItem = selectedItem;
                  widget.itemCallBack(currentItem);
                }),
                hint: Container(
                  child: Text(widget.hintText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
