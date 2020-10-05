import 'package:sales_app/data_helper/api_service.dart';
import 'package:sales_app/models/http_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




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

class Profile with ChangeNotifier{
  final String authToken;
  final String userId;

  Profile(this.authToken,this.userId);

  ProfileItem _profileItem;

  ProfileItem get profileInfo{
    return _profileItem;
  }


  ProfileItem getProfileInfo(){
    return _profileItem;
  }

  Future<void> fetchProfileInfo() async {

    var url = 'http://new.bepari.net/demo/api/V1.1/access-control/user/show-profile';
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
      var alldata = data['data'];
      final ProfileItem info = ProfileItem(
        id: alldata['id'].toString(),
        name: alldata['name'],
//        displayName: alldata['display_name'],
//        gender: alldata['gender'],
        email: alldata['email'],
        mobileNumber: alldata['mobile_no'].toString(),
//        address: alldata['address'],
//        city: alldata['city'],
//        areaId: alldata['area_id'].toString(),
//        contactPerson: alldata['contact_person'],
//        contactPersonMobileNumber: alldata['contact_person_contact_no'],
      );
      _profileItem = info;
      notifyListeners();
    } catch (error) {throw (error);
    }
  }

  Future<Map<String,dynamic>> updatePassWord(String oldPass ,String newPass) async{

    var responseData;
    final url = ApiService.BASE_URL +  'api/V1.3/access-control/user/update-password';

    Map<String, String> headers = {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> data = {
      'old_password': oldPass,
      'new_password': newPass,
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
      return responseData;
      notifyListeners();
    }catch(error){
      throw error;
    }
  }

}