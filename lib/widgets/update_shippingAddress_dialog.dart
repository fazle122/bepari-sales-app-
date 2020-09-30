import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app/providers/cart.dart';
import 'package:sales_app/providers/orders.dart';
import 'package:sales_app/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:sales_app/screens/orders_screen.dart';
import 'package:sales_app/screens/products_overview_screen.dart';

class UpdateShippingAddressDialog extends StatefulWidget {
  final AddressItem addressItem;

  UpdateShippingAddressDialog({this.addressItem});

  @override
  _UpdateShippingAddressDialogState createState() =>
      _UpdateShippingAddressDialogState();
}



class _UpdateShippingAddressDialogState
    extends State<UpdateShippingAddressDialog> {
  final _form = GlobalKey<FormState>();

  TextEditingController _phoneEditController;
  TextEditingController _addressEditController;
  String selectedArea;
  String selectedDistrict;
  String selectedAreaFromLocal;

  var _isInit = true;
  var _isLoading = false;
  String mobileNumber;
  String homeAddress;


  var _currentAddress = AddressItem(
    id: '',
    customerId: '',
    phoneNumber: '',
    city:'',
    areaId: '',
    shippingAddress: '',
  );
  var _initValues = {
    'id': '',
    'customerId': '',
    'phoneNumber': '',
    'city': '',
    'areaId': 0,
    'shippingAddress': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
      _initValues = {
        'id': widget.addressItem.id,
        'customerId': widget.addressItem.customerId,
        'phoneNumber': widget.addressItem.phoneNumber,
        'city': widget.addressItem.city,
        'areaId': int.parse(widget.addressItem.areaId),
        'shippingAddress': widget.addressItem.shippingAddress,
      };
    }
    getAreaName(widget.addressItem.areaId);

    _isInit = false;
    super.didChangeDependencies();
  }

  getAreaName(String areaId) async {
    final data = await Provider.of<ShippingAddress>(context, listen: false)
        .fetchAreaName(areaId.toString());
    setState(() {
      selectedAreaFromLocal = data;
    });
  }


  Widget phoneField() {
    return TextFormField(
      initialValue: _initValues['phoneNumber'],
      keyboardType: TextInputType.number,
//      controller: _phoneEditController,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter mobile number';
        }else if(value.length > 11 || value.length < 11){
          return 'please provide a valid mobile number';
        }
        return null;
      },
      onSaved: (value) {
        mobileNumber = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone_android,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Mobile number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }


  Widget addressField() {
    return TextFormField(
      initialValue: _initValues['shippingAddress'],
      keyboardType: TextInputType.multiline,
      maxLines: 2,
//      controller: _addressEditController,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter your home address';
        }
        return null;
      },
      onSaved: (value){
        homeAddress = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.home,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Home address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(

          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: _initValues['city'] != null ?Text(_initValues['city']):Text('select city'),
          value: shippingAddress.selectedDistrict,
          onSaved: (value){
//            shippingAddress.selectedDistrict = value;
            if(shippingAddress.selectedDistrict == null) {
              shippingAddress.selectedDistrict = _initValues['city'];
            }else{
              shippingAddress.selectedDistrict = value;
            }
          },
          validator: (value){
            if (shippingAddress.selectedDistrict == null) {
              value = _initValues['city'];
            } else {
              value = shippingAddress.selectedDistrict;
            }
            if (value == null) {
              return 'please choose district';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedDistrict = newValue;
            shippingAddress.selectedArea = null;
            setState(() {
              selectedAreaFromLocal = null;
            });
          },
          items: _districtMenuItems(district),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//
//                  isExpanded: true,
////                icon: Icon(Icons.location_city),
//                  hint: Text('Select district'),
//                  value: shippingAddress.selectedDistrict,
//                  onSaved: (value){
//                    shippingAddress.selectedDistrict = value;
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose district';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedDistrict = newValue;
//                    shippingAddress.selectedArea = null;
//                  },
//                  items: _districtMenuItems(district),
//                )),
//            Container(
//              padding: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.location_city,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }

  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: selectedAreaFromLocal != null ? Text(selectedAreaFromLocal):Text('Select area'),
          value: shippingAddress.selectedArea,
          onSaved: (value){
//            shippingAddress.selectedArea = value;
            if(shippingAddress.selectedArea == null) {
              shippingAddress.selectedArea = _initValues['areaId'].toString();
            }else{
              shippingAddress.selectedArea = value;
            }
          },
          validator: (value){
            if(shippingAddress.selectedDistrict != null && shippingAddress.selectedArea == null){
              return 'please update area';
            }
            if (shippingAddress.selectedArea == null) {
              value = _initValues['areaId'].toString();
            } else {
              value = shippingAddress.selectedArea;
            }
            if (value == null) {
              return 'please choose area';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          items: _areaMenuItems(areas),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//                  isExpanded: true,
//                decoration: InputDecoration(
//            prefixIcon: Icon(
//              Icons.local_gas_station,
//              color: Theme.of(context).primaryColor,
//            ),
//            border: OutlineInputBorder(),
////                enabledBorder: UnderlineInputBorder(
////                    borderSide: BorderSide(color: Colors.white))
//          ),
//                  hint: Text('Select area'),
//                  value: shippingAddress.selectedArea,
//                  onSaved: (value){
//                    shippingAddress.selectedArea = value;
//
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose area';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedArea = newValue;
//                  },
//                  items: _areaMenuItems(areas),
//                )),
//            Container(
//              margin: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.local_gas_station,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }

  Future<void> _saveForm(var shippingAddress) async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
//    FormData data = new FormData();
//    data.add('city',shippingAddress.selectedDistrict);
//    data.add('area_id', shippingAddress.selectedArea.toString());
//    data.add('shipping_address_line', homeAddress);
//    data.add('mobile_no', mobileNumber);

    //    FormData data = new FormData();


    Map<String,dynamic> dt = Map();
    dt.putIfAbsent('city',() =>shippingAddress.selectedDistrict);
    dt.putIfAbsent('area_id', () =>shippingAddress.selectedArea.toString());
    dt.putIfAbsent('shipping_address_line', () =>homeAddress);
    dt.putIfAbsent('mobile_no', () => mobileNumber);
    FormData data = FormData.fromMap(dt);

    setState(() {
      _isLoading = true;
    });
    final response = await Provider.of<ShippingAddress>(context, listen: false).createShippingAddress1(widget.addressItem.id.toString(),data);
    if (response != null) {
      setState(() {
        _isLoading = false;
      });
      shippingAddress.selectedDistrict = null;
      shippingAddress.selectedArea = null;
      Navigator.of(context).pop();
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text('Order confirmation'),
            content: Text(
                'something went wrong!!! Please try again'),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                      ProductsOverviewScreen
                          .routeName);
                },
              ),
            ],
          ));
    }
  }

  Future<bool> _onBackPressed() {
    final shippingAddress = Provider.of<ShippingAddress>(context,listen: false);
    setState(() {
      shippingAddress.selectedDistrict = null;
    });
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);

    Map<String, dynamic> district = shippingAddress.allDistricts;
    Map<String, dynamic> areas = Map();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: AlertDialog(

        title: Center(
          child: Text('Update address'),
        ),
        content: SingleChildScrollView(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                :
            Form(key:_form,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  phoneField(),
                  SizedBox(
                    height: 15.0,
                  ),
//                  DistrictDropDown(),
                  districtDropdown(shippingAddress,shippingAddress.allDistricts),
                  SizedBox(
                    height: 15.0,
                  ),
//                  AreaDropDown(),
                  areaDropdown(shippingAddress,shippingAddress.allAreas),
                  SizedBox(
                    height: 15.0,
                  ),
                  addressField(),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.grey)),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Confirm".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      onPressed: () async{
                        await _saveForm(shippingAddress);
                      },
                    ),
                  )
                ],
              ),)

        ),
      ),
    );

  }

  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }


}


//
//class _UpdateShippingAddressDialogState extends State<UpdateShippingAddressDialog> {
//  var _isInit = true;
//  var _isLoading = false;
//  String selectedArea;
//  String selectedDistrict;
//  String addressLine;
//  String city;
//
//  final _form = GlobalKey<FormState>();
//  String mobileNo;
//  String homeAddress;
//  String name;
//  String email;
//
//  var _currentAddress = AddressItem(
//    id: '',
//    customerId: '',
//    phoneNumber: '',
//    areaId: '',
//    shippingAddress: '',
//  );
//  var _initValues = {
//    'id': '',
//    'customerId': '',
//    'phoneNumber': '',
//    'areaId': 0,
//    'shippingAddress': '',
//  };
//
//  @override
//  void didChangeDependencies() {
//    if (_isInit) {
//      if (!mounted) return;
//      setState(() {
//        _isLoading = true;
//      });
//      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_) {
//        _initValues = {
//          'id': widget.addressItem.id,
//          'customerId': widget.addressItem.customerId,
//          'phoneNumber': widget.addressItem.phoneNumber,
//          'areaId': 0,
//          'shippingAddress': widget.addressItem.shippingAddress,
//        };
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
//
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }
//
//
//
//  Widget phoneField() {
//    return TextFormField(
//      initialValue: _initValues['phoneNumber'],
//      keyboardType: TextInputType.number,
//      validator: (value) {
//        if (value.isEmpty) {
//          return 'please enter mobile number';
//        }else if(value.length > 11 || value.length < 11){
//          return 'please provide a valid mobile number';
//        }
//        return null;
//      },
//      onSaved: (value) {
//        mobileNo = value;
//      },
//      decoration: InputDecoration(
//        prefixIcon: Icon(
//          Icons.phone_android,
//          color: Theme.of(context).primaryColorDark,
//        ),
//        hintText: 'mobile number',
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//      ),
//    );
//  }
//
//  Widget addressField() {
//    return TextFormField(
//      initialValue: _initValues['shippingAddress'],
//      keyboardType: TextInputType.multiline,
//      maxLines: 2,
//      validator: (value) {
//        if (value.isEmpty) {
//          return 'please enter your home address';
//        }
//        return null;
//      },
//      onSaved: (value){
//        homeAddress = value;
//      },
//      decoration: InputDecoration(
//        prefixIcon: Icon(
//          Icons.home,
//          color: Theme.of(context).primaryColorDark,
//        ),
//        hintText: 'Home address',
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//      ),
//    );
//  }
//
//  Future<void> _saveForm(var shippingAddress) async{
//
//
//    final isValid = _form.currentState.validate();
//    if (!isValid) {
//      return;
//    }
//    _form.currentState.save();
//    setState(() {
//      _isLoading = true;
//    });
//
//
//    if (shippingAddress.selectedArea != null &&
//        shippingAddress.selectedDistrict != null) {
//      setState(() {
//        city = shippingAddress.selectedDistrict;
//        addressLine = shippingAddress.selectedArea +
//            ',' +
//            shippingAddress.selectedDistrict +
//            ',' +
//            homeAddress;
//      });
//    } else {
////      city = widget.info.city;
//      addressLine = homeAddress;
//    }
//
//    try {
//      Map<String,dynamic> response =await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo1(
//        addressLine,
//        mobileNo,
//        name,
//        email,
//        city,
////        shippingAddress.selectedArea,
//      );
//      if(response != null){
//        String msg ='';
//        for(int i=0; i<response['data'].value.length; i++)
//        {
//          for(int j=0; j<response['data'][''].length; j++){
//            msg += 'error definition goes here';
//          }
//          for(int j=0; j<response['data'][''].length; j++){
//            msg += 'error definition goes here';
//          }
//        }
//        _showErrorDialog(msg);
//      }
//    } catch (error) {
//      const errorMessage = 'Some thing wrong, please try again later';
//      _showErrorDialog(errorMessage);
//    }
//    shippingAddress.selectedDistrict = null;
//    shippingAddress.selectedArea = null;
//
//    Navigator.of(context).pop();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//    Map<String, dynamic> district = shippingAddress.allDistricts;
//    Map<String, dynamic> areas = Map();
//    return AlertDialog(
//      title: Center(
//        child: Text('Profile info'),
//      ),
//      content: _isLoading ? Center(child: CircularProgressIndicator(),):SingleChildScrollView(
//          child: Form(
//            key: _form,
//            child: Column(
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                phoneField(),
//                SizedBox(
//                  height: 15.0,
//                ),
//                districtDropdown(shippingAddress, shippingAddress.allDistricts),
//                SizedBox(
//                  height: 15.0,
//                ),
//                areaDropdown(shippingAddress, shippingAddress.allAreas),
//                SizedBox(
//                  height: 15.0,
//                ),
//                addressField(),
//                SizedBox(
//                  height: 25.0,
//                ),
//                Container(
//                  child: RaisedButton(
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(25.0),
//                        side: BorderSide(color: Colors.grey)),
//                    onPressed: () async {
//                      _saveForm(shippingAddress);
//                    },
//                    color: Theme.of(context).primaryColor,
//                    textColor: Colors.white,
//                    child: Text("Confirm".toUpperCase(),
//                        style: TextStyle(fontSize: 14)),
//                  ),
//                )
//              ],
//            ),
//          )
//
//      ),
//    );
//  }
//
//  void _showErrorDialog(String message) {
//    showDialog(
//        context: context,
//        builder: (ctx) =>
//            AlertDialog(
//              title: Text('An Error Occurred!'),
//              content: Text(message),
//              actions: <Widget>[
//                FlatButton(
//                  child: Text('ok'),
//                  onPressed: () {
//                    Navigator.of(ctx).pop();
//                  },
//                )
//              ],
//            ));
//  }
//
//  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
//    List<DropdownMenuItem> itemWidgets = List();
//    items.forEach((key, value) {
//      itemWidgets.add(DropdownMenuItem(
//        value: value,
//        child: Text(value),
//      ));
//    });
//    return itemWidgets;
//  }
//
//  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
//    List<DropdownMenuItem> itemWidgets = List();
//    items.forEach((key, value) {
//      itemWidgets.add(DropdownMenuItem(
//        value: value,
//        child: Text(value),
//      ));
//    });
//    return itemWidgets;
//  }
//
//  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
//    return Consumer<ShippingAddress>(
//      builder: (
//          final BuildContext context,
//          final ShippingAddress address,
//          final Widget child,
//          ) {
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//
//                  isExpanded: true,
////                icon: Icon(Icons.location_city),
//                  hint: Text('Select district'),
//                  value: shippingAddress.selectedDistrict,
//                  onSaved: (value){
//                    shippingAddress.selectedDistrict = value;
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose district';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedDistrict = newValue;
//                    shippingAddress.selectedArea = null;
//                  },
//                  items: _districtMenuItems(district),
//                )),
//            Container(
//              padding: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.location_city,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas){
//    return Consumer<ShippingAddress>(
//      builder: (
//          final BuildContext context,
//          final ShippingAddress address,
//          final Widget child,
//          ) {
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//                  isExpanded: true,
////                icon: Icon(Icons.local_gas_station),
//                  hint: Text('Select area'),
//                  value: shippingAddress.selectedArea,
//                  onSaved: (value){
//                    shippingAddress.selectedArea = value;
//
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose area';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedArea = newValue;
//                  },
//                  items: _areaMenuItems(areas),
//                )),
//            Container(
//              margin: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.local_gas_station,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
//      },
//    );
//  }
//}
