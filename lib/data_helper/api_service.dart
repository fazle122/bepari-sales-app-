import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

//Email: rubel@sabujudyog.com
//Email: mahmud@gmail.com
//Pwd(both): 123456
class ApiService {

  static final String BASE_URL = "http://new.bepari.net/demo/"; //dev
  static final String CDN_URl = "http://new.bepari.net/"; //dev

//  for product --- http://new.bepari.net/product-catalog-images/product/def-thumb.png
//  for category --- http://new.bepari.net/product-catalog-images/category/def-cat-thumb.png

  static final Dio dioService = new Dio();


  static Future<Map<String, dynamic>> login(String email, String password) async {
    String qString = ApiService.BASE_URL + "api/V1.1/access-control/login";
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
    } catch (Exception) {
      return null;
    }

    if (responseData['code'] == 200) {
      return responseData;
    }
    return responseData;
  }

  static Future<Map<String, dynamic>> logout(String cID,String instanceId) async {
    String qString = ApiService.BASE_URL + "api/V1.1/access-control/user/logout";
    var responseData;

    final Map<String, dynamic> authData = {
      'grant_type': 'password',
      'client_id': 3,
      'client_secret': 'W5nQYuW1OFknDwiFnU96Y7dBMqTJ5jG6r6AXYk9q',
    };
    try {
      final http.Response response = await http.post(
        qString,
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
      responseData = json.decode(response.body);
    } catch (Exception) {
      return null;
    }

    if (responseData['code'] == 200) {
//      SharedPreferences prefs = await SharedPreferences.getInstance();
      return responseData;
    }
    return responseData;
  }

  static Future<List<dynamic>> getDistrictDataFromLocalDB() async  {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "areas.db");
    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "areas.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    var db = await openDatabase(path, readOnly: true);
    var dbClient = await db;
    List<dynamic> root = await dbClient.rawQuery('select DISTINCT district from ix_areas');
//    db.close();
    return root;
  }


  static Future<List<dynamic>> getAreaDataFromLocalDB(String district) async  {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "areas.db");
    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "areas.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    var db = await openDatabase(path, readOnly: true);
    var dbClient = await db;
    List<dynamic> root = await dbClient.rawQuery('select id,location from ix_areas where district = "$district" ');
//    db.close();
    return root;
  }

  static getAreaNameFromLocalDB(String areaId) async  {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "areas.db");
    var db = await openDatabase(path, readOnly: true);

    var dbClient = await db;
    List<dynamic> result = await dbClient.rawQuery('select * from ix_areas where id = "$areaId" ');
    final location = result.map((data) => data['location']);

//    db.close();
    return location.elementAt(0).toString();
  }

  static Future<Map<String,dynamic>> getProductList() async {

    String qString = BASE_URL + "api/V1.3/product-catalog/product/list-product";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final http.Response response = await http.get(
      qString,
      headers: headers,
    );

    final Map<String,dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData;
    }
    return responseData;
  }


}
