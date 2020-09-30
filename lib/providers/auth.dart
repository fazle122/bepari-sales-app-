import 'package:sales_app/data_helper/api_service.dart';
import 'package:sales_app/models/http_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;


  bool get isAuth {
    return token != null;
  }

//  String get token {
//    if (_expiryDate != null &&
//        _expiryDate.isAfter(DateTime.now()) &&
//        _token != null) {
//      return _token;
//    }
//    return null;
//  }

  String get token {
    return _token;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    String qString = ApiService.BASE_URL + "api/V1.1/access-control/user/login";
    var responseData;

    final Map<String, dynamic> authData = {
      'client_id': 3,
      'client_secret': 'zKu8puNCPZYTYYBRsHtw3Efz8hemktaP1LZ73aSf',
      'email': email,
      'password': password,
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
      responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['data']['access_token'];
      _userId = email;
      _expiryDate = DateTime.now().add(Duration(seconds: responseData['data']['expires_in']));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'user_token': _token,
        'user_id': email,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
    json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['user_token'];
    _userId = extractedUserData['user_id'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }


  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
      _token = extractedUserData['user_token'];
      String qString = "http://new.bepari.net/demo/api/V1.1/access-control/user/logout";
      Map<String, String> headers = {
        'Authorization': 'Bearer ' + _token,
        'Content-Type': 'application/json',
      };
      final http.Response response = await http.post(
        qString,
        headers: headers,
      );
      var responseData = json.decode(response.body);

    }

    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}