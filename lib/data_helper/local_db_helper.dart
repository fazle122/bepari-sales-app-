import 'package:sales_app/providers/cart.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

// import 'package:api_to_sqlite_flutter/src/models/employee_model.dart';
// import 'package:path_provider/path_provider.dart';

class DBHelper {
  final String tableCart = 'cartTable';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnProductId = 'productId';
  final String columnQuantity = 'quantity';
  final String columnPrice = 'price';
  final String columnIsNonInventory = 'isNonInventory';
  final String columnDiscount = 'discount';
  final String columnDiscountType = 'discountType';
  final String columnDiscountId = 'discountId';

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'carts.db'),
        onCreate: (db, version) {
      return db.execute('CREATE TABLE cartTable('
          // 'id INTEGER PRIMARY KEY AUTOINCREMENT, productId TEXT, title TEXT,quantity NUMERIC,price NUMERIC,isNonInventory INTEGER,discount NUMERIC,discountType TEXT,discountId TEXT,orderId TEXT)');
          'id TEXT,'
          'productId TEXT,'
          'title TEXT,'
          // 'productCategoryId TEXT,'
          'quantity NUMERIC,'
          'unitName TEXT,'
          'price NUMERIC,'
          'isNonInventory INTEGER,'
          'salesAccountsGroupId TEXT,'
          'discount NUMERIC,'
          'discountType TEXT,'
          'discountId TEXT,'
          'perUnitDiscount NUMERIC,'
          'vatRate NUMERIC,'
          'orderId TEXT)');
    }, version: 1);
  }

  static Future<bool> isProductExist(String id) async {
    final db = await DBHelper.database();
    var result =
        await db.rawQuery('SELECT * FROM cartTable WHERE productId = $id');

    if (result.length != 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> updateOrderId(String table, String orderId) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET orderId = $orderId WHERE tempId = temp_id');
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> createCartFromOrder(CartItem cartItem) async {
    await clearCart();
    final db = await DBHelper.database();
    final res = await db.insert('cartTable', cartItem.toJson());
    // db.close();
    return res;
  }

  static Future<void> updateItemQuantity(
      String table, String productId, double quantity) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET quantity = $quantity WHERE productId = $productId');
  }

  static Future<void> increaseItemQuantity(String table, String productId) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET quantity = quantity+1.0 WHERE productId = $productId');
  }

  static Future<void> decreaseItemQuantity(String productId) async {
    final db = await DBHelper.database();
    db.rawUpdate(
        'UPDATE cartTable SET quantity = quantity-1 WHERE productId = $productId');
  }

  static Future<void> deleteCartItm(String productId) async {
    final db = await DBHelper.database();
    await db.rawDelete('DELETE FROM cartTable WHERE productId = $productId');
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return await db.query(table);
  }

  static Future<CartItem> getSingleData(String productId) async {
    final db = await DBHelper.database();
    final result = await db
        .rawQuery('SELECT * FROM cartTable WHERE productId = $productId');
    if (result.length > 0) {
      return await new CartItem.fromJson(result.first);
    }
    return null;
  }

  static Future<void> clearCart() async {
    final db = await DBHelper.database();
    await db.rawQuery('DELETE  FROM cartTable');
//    db.rawDelete('DELETE * from cartTable ');
  }
}
