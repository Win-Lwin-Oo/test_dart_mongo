// import 'package:test_dart_mongo/test_dart_mongo.dart' as test_dart_mongo;
import 'dart:io';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  // initialize server
  var port = 5000;
  var address = 'localhost';
  var server = await HttpServer.bind(address, port);

  // initialize db
  var db = Db('mongodb://127.0.0.1:27017/test');
  await db.open();
  print('Connected to database');

  var collection = db.collection('people');

  server.listen((HttpRequest request) async {
    switch (request.uri.path) {
      case '/':
        request.response.write('Hello world!');
        await request.response.close();
        break;
      case '/people':
        if (request.method == 'GET') {
          request.response.write(await collection.find().toList());
        } else if (request.method == 'POST') {
          // IMPORTANT: to cast<List<int>> in request transform
          // BECAUSE: change SDK https://github.com/aloisdeniel/flutter_geocoder/pull/22
          var content =
              await request.cast<List<int>>().transform(Utf8Decoder()).join();
          var document = json.decode(content);
          await collection.insert(document);
          request.response.write('Insert Success');
        } else if (request.method == 'PUT') {
          var param = request.uri.queryParameters['id'];
          var id = int.parse(param!);
          //print(id.runtimeType);
          var content =
              await request.cast<List<int>>().transform(Utf8Decoder()).join();
          var document = json.decode(content);
          var itemToReplace = await collection.findOne(where.eq('id', id));
          //print(itemToReplace);
          if (itemToReplace == null) {
            await collection.insert(document);
            request.response.write('Insert Success');
          } else {
            await collection.update(itemToReplace, document);
            request.response.write('Update Success');
          }
        } else if (request.method == 'DELETE') {
          var param = request.uri.queryParameters['id'];
          var id = int.parse(param!);
          var itemToDelete = await collection.findOne(where.eq('id', id));
          print(itemToDelete);
          //await collection.remove(where.eq('id', id)); OR
          await collection.remove(itemToDelete);
          request.response.write('Delete Success');
        } else if (request.method == 'PATCH') {
          var param = request.uri.queryParameters['id'];
          var id = int.parse(param!);
          var itemToPatch = await collection.findOne(where.eq('id', id));
          var content =
              await request.cast<List<int>>().transform(Utf8Decoder()).join();
          var document = json.decode(content);
          await collection.update(itemToPatch, {r'$set': document});
          request.response.write('Patch Success');
        }
        await request.response.close();
        break;
      default:
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
        await request.response.close();
    }
  });

  print('Server is listening at http://$address:$port');

  // Read Data
  //var people = await collection.find().toList();
  //var people = await collection.find(where.eq('first_name', 'Oren')).toList();
  //var people = await collection.find(where.limit(5)).toList();
  //var people = await collection.findOne(where.match('first_name', 'B'));
  // var people = await collection
  //     //.findOne(where.match('first_name', 'B').and(where.gt('id', 40)));
  //     //.findOne(where.match('first_name', 'B').gt('id', 40));
  //     .findOne(where.jsQuery('''
  //     return this.first_name.startsWith('B') && this.id > 40;
  //     '''));
  //print('People list: \n $people');

  // Create Data
  // await collection.insert({
  //   'id': 101,
  //   'first_name': 'Win',
  //   'last_name': 'Win',
  //   'email': 'winwin@xinhuanet.com',
  //   'gender': 'Male',
  //   'ip_address': '99.252.84.122'
  // });
  // print('Insert data');

  // Update Data
  // await collection.update(
  //     where.eq('id', 101), modify.set('ip_address', '192.168.10.100'));
  // print('Update data');

  // Delete Data
  // await collection.remove(where.eq('id', 101));
  // print('Delete data');

  // await db.close();
}
