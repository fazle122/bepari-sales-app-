import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_app/data_helper/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sales_app/models/http_exception.dart';




class AddressItem{
  final String id;
  final String city;
  final String areaId;
  final String shippingAddress;
  final String customerId;
  final String phoneNumber;

  AddressItem({
    @required this.id,
    @required this.city,
    @required this.areaId,
    @required this.shippingAddress,
    @required this.customerId,
    @required this.phoneNumber,
  });
}

class ProfileItem{
  final String id;
  final String name;
  final String displayName;
  final String gender;
  final String email;
  final String mobileNumber;
  final String address;
  final String city;
  final String areaId;
  final String contactPerson;
  final String contactPersonMobileNumber;

  ProfileItem({
    @required this.id,
    @required this.name,
    @required this.displayName,
    @required this.gender,
    @required this.email,
    @required this.mobileNumber,
    @required this.address,
    @required this.city,
    @required this.areaId,
    @required this.contactPerson,
    @required this.contactPersonMobileNumber,
  });
}

class ShippingAddress with ChangeNotifier{
  List<AddressItem> _allShippingAddress = [];
  final String authToken;
  final String userId;

  ShippingAddress(this.authToken,this.userId,this._allShippingAddress);

  Map<String,dynamic> _districtList = Map();
  Map<String,dynamic> _areaList = Map();
  ProfileItem _profileItem;

  ProfileItem get profileInfo{
    return _profileItem;
  }

  List<AddressItem> get allShippingAddress{
    return [..._allShippingAddress];
  }

  Map<String,dynamic> get allDistricts{
    return _districtList;
  }

  Map<String,dynamic> get allAreas{
    return _areaList;
  }

  String _selectedDistrict;
  String _selectedArea;


  String get selectedDistrict {
    return this._selectedDistrict;
  }
  set selectedDistrict(final String item) {
    this._selectedDistrict = item;
    fetchAreaList(item);
    this.notifyListeners();
  }

  String get selectedArea {
    return this._selectedArea;
  }
  set selectedArea(final String item) {
    this._selectedArea = item;
    this.notifyListeners();
  }

  Future<void> fetchDistrictList() async {
    List<dynamic> dbData = await ApiService.getDistrictDataFromLocalDB();
    Map<String,dynamic> districtData = Map();
    List<dynamic> data = [];
    data = dbData.map((model){
      return{
//        'id':model['id'],
        'district': model['district'],
//        'location':model['location'],
      };
    }).toList();

    if (data == null) {
      return;
    }
    for(int i =0; i<data.length; i++){
      districtData[i.toString()] = data[i]['district'];
    }
    _districtList = districtData;
    notifyListeners();
  }

  Future<void> fetchAreaList(String district) async {
    List<dynamic> dbData = await ApiService.getAreaDataFromLocalDB(district);
    Map<String,dynamic> areaData = Map();
    List<dynamic> data = [];
    data = dbData.map((model){
      return{
        'id':model['id'],
        'location':model['location'],
      };
    }).toList();

    if (data == null) {
      return;
    }
    for(int i =0; i<data.length; i++){
      areaData[data[i]['id']] = data[i]['location'];
    }
    _areaList = areaData;
    notifyListeners();
  }

  Future<String> fetchAreaName(String areaId) async {
    var area = await ApiService.getAreaNameFromLocalDB(areaId);
    print(area.toString());
    return area.toString();
//    notifyListeners();
  }

//  Future<void> fetchAreaList() async {
//    var url = 'http://new.bepari.net/demo/api/V1.0/crm/customer/list-shipping-address';
//    Map<int, dynamic> areaData = Map();
//    try {
//      final response = await http.get(url);
//      final data = json.decode(response.body) as Map<String, dynamic>;
//      if (data == null) {
//        return;
//      }
//      for(int i =0; i<data['data']['area'].length; i++){
//        areaData[data['data']['area'][i]['id']] = data['data']['area'][i]['area'];
//      }
//      _areaList = areaData;
//      notifyListeners();
//    } catch (error) {
//      throw (error);
//    }
//  }


  Future<void> createShippingAddress(String areaId, String address,String phone) async {
    var responseData;
    String qString = "http://new.bepari.net/demo/api/V1.0/crm/customer/create-shipping-address";

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'area_id': areaId,
      'shipping_address_line': address,
      'mobile_no': phone,
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
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

  Future<Map<String,dynamic>> createShippingAddress1(String shippingAddressId,FormData data) async {
    String qString;
    Dio dioService = new Dio();
    if(shippingAddressId != null){
      qString = "http://new.bepari.net/demo/api/V1.0/crm/customer/update-shipping-address/$shippingAddressId";

    }else {
      qString = "http://new.bepari.net/demo/api/V1.0/crm/customer/create-shipping-address";
    }

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Response response = await dioService.post(
        qString,
        data: data,
      );
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
      if(response.statusCode == 200) {
        return response.data;
      }else{
        return null;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String,dynamic>> deleteShippingAddress(String shippingAddressId) async {
    Dio dioService = new Dio();
    String qString = "http://new.bepari.net/demo/api/V1.0/crm/customer/delete-shipping-address/$shippingAddressId";

    dioService.options.headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Response response = await dioService.delete(qString);
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
      if(response.statusCode == 200) {
        return response.data;
      }else{
        return null;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProfileInfo(ProfileItem newInfo) async {
    var responseData;
    String qString = "http://new.bepari.net/demo/api/V1.0/access-control/user/update-profile";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'name':newInfo.name,
//      'mobile_no': newInfo.mobileNumber,
      'email':newInfo.email,
//      'address': newInfo.address,

    };
//    try {
//      final http.Response response = await http.post(
//        qString,
//        body: json.encode(authData),
//        headers: headers,
//      );
//      responseData = json.decode(response.body);
//
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
//      notifyListeners();
//    } catch (error) {
//      throw error;
//    }
  }

  Future<Map<String,dynamic>> updateProfileInfo1(String address,String phone,String name,String email,String district,int areaId) async {
    var responseData;
    String qString = "http://new.bepari.net/demo/api/V1.0/access-control/user/update-profile";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> authData = {
      'address': address,
      'mobile_no': phone,
      'name':name,
      'email':email,
      'city':district,
      'area_id':areaId
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: headers,
      );
      responseData = json.decode(response.body);



      notifyListeners();
      if (response.statusCode != 200) {
        return responseData;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }

  ProfileItem getProfileInfo(){
    return _profileItem;
  }

  Future<void> fetchProfileInfo() async {
    print('fetch profile');

    var url = 'http://new.bepari.net/demo/api/V1.0/access-control/user/show-profile';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      var alldata = data['data']['profile'];
        final ProfileItem info = ProfileItem(
          id: alldata['id'].toString(),
          name: alldata['name'],
          displayName: alldata['display_name'],
          gender: alldata['gender'],
          email: alldata['email'],
          mobileNumber: alldata['mobile'].toString(),
          address: alldata['address'],
          city: alldata['city'],
          areaId: alldata['area_id'].toString(),
          contactPerson: alldata['contact_person'],
          contactPersonMobileNumber: alldata['contact_person_contact_no'],
        );
      _profileItem = info;
      notifyListeners();
    } catch (error) {throw (error);
    }
  }

  Future<void> fetchShippingAddress() async {
    var url = 'http://new.bepari.net/demo/api/V1.0/crm/customer/list-shipping-address';
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.get(
        url,
        headers: headers,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final List<AddressItem> loadedAddress = [];
      var alldata = data['data']['address'];
      for(int  i=0; i<alldata.length;i++){
        final AddressItem address = AddressItem(
          id: alldata[i]['id'].toString(),
          city:alldata[i]['city'],
          shippingAddress: alldata[i]['shipping_address_line'],
          areaId: alldata[i]['area_id'].toString(),
          customerId: alldata[i]['customer_id'].toString(),
          phoneNumber: alldata[i]['mobile_no'].toString(),
        );
        loadedAddress.add(address);
      }
      _allShippingAddress = loadedAddress.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}