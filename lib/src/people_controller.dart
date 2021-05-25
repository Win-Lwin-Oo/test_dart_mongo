import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PeopleController {
  final HttpRequestBody _requestBody;
  final HttpRequest _request;
  final DbCollection _dbCollection;

  PeopleController(this._requestBody, Db db)
      // initialize
      : _request = _requestBody.request,
        _dbCollection = db.collection('people') {
    handle(); // Invoke handle method
  }

  // ignore: always_declare_return_types
  handle() async {
    switch (_request.method) {
      case 'GET':
        await handleGet();
        break;
      case 'POST':
        await handlePost();
        break;
      case 'PUT':
        await handlePut();
        break;
      case 'DELETE':
        await handleDelete();
        break;
      case 'PATCH':
        await handlePatch();
        break;
      default:
        _request.response.statusCode = HttpStatus.notFound;
        _request.response.write('Not Found');
    }
    await _request.response.close();
  }

  // ignore: always_declare_return_types
  handleGet() async {
    _request.response.write(await _dbCollection.find().toList());
  }

  // ignore: always_declare_return_types
  handlePost() async {
    _request.response.write(await _dbCollection.insert(_requestBody.body));
  }

  // ignore: always_declare_return_types
  handlePut() async {
    var param = _request.uri.queryParameters['id'];
    var id = int.parse(param!);
    var itemToPut = await _dbCollection.findOne(where.eq('id', id));
    //print('Item to put: \n $itemToPut');
    if (itemToPut == null) {
      _request.response.write(await _dbCollection.insert(_requestBody.body));
    } else {
      _request.response
          .write(await _dbCollection.update(itemToPut, _requestBody.body));
    }
  }

  // ignore: always_declare_return_types
  handlePatch() async {
    var param = _request.uri.queryParameters['id'];
    var id = int.parse(param!);
    var itemToPatch = await _dbCollection.findOne(where.eq('id', id));
    _request.response.write(await _dbCollection.update(itemToPatch, {
      // r is raw string ,
      // $ know mongodb
      // not update the whole item
      r'$set': _requestBody.body
    }));
  }

  // ignore: always_declare_return_types
  handleDelete() async {
    var paramId = _request.uri.queryParameters['id'];
    var id = int.parse(paramId!);
    var first_name = _request.uri.queryParameters['first_name'];
    var itemToDelete = await _dbCollection
        .findOne(where.eq('id', id).or(where.eq('first_name', first_name)));
    if (itemToDelete == null) {
      _request.response.statusCode = HttpStatus.notFound;
      _request.response.write('Not Found');
    } else {
      _request.response.write(await _dbCollection.remove(itemToDelete));
    }
  }
}

// Different between PUT and PATCH request
// PUT can update the whole items and overwrite all fields items
// PATCH will update a piece of item and don't overwrite other fields itmes
//
// In request
// PUT : must add all fields itmes to update
// like:
// {
// "id": 1,
// "first_name": "Bo"
// "last_name": "Kyaw"
// "age": 20
// }
//
// PATCH: can add just need to update items
// like:
//{
//"age": 22
//}
