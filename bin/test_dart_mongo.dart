// import 'package:test_dart_mongo/test_dart_mongo.dart' as test_dart_mongo;
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  var db = Db('mongodb://127.0.0.1:27017/test');
  await db.open();

  print('Connected to database');

  var collection = db.collection('people');

  // Read Data
  //var people = await collection.find().toList();
  //var people = await collection.find(where.eq('first_name', 'Oren')).toList();
  //var people = await collection.find(where.limit(5)).toList();
  //var people = await collection.findOne(where.match('first_name', 'B'));
  var people = await collection
      //.findOne(where.match('first_name', 'B').and(where.gt('id', 40)));
      //.findOne(where.match('first_name', 'B').gt('id', 40));
      .findOne(where.jsQuery('''
      return this.first_name.startsWith('B') && this.id > 40;
      '''));
  print('People list: \n $people');

  // Create Data

  // Update Data

  // Delete Data

  await db.close();
}
