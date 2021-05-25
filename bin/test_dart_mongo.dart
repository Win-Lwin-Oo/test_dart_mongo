import 'package:test_dart_mongo/test_dart_mongo.dart';

void main(List<String> arguments) async {
  // initialize server
  var port = 5000;
  var address = 'localhost';
  var server = await HttpServer.bind(address, port);

  // initialize db
  var db = Db('mongodb://127.0.0.1:27017/test');
  await db.open();
  print('Connected to database');

  server
      .transform(HttpBodyHandler())
      .listen((HttpRequestBody requestBody) async {
    switch (requestBody.request.uri.path) {
      case '/':
        requestBody.request.response.write('Hello world!');
        await requestBody.request.response.close();
        break;
      case '/people':
        PeopleController(requestBody, db); // use controller
        break;
      default:
        requestBody.request.response.statusCode = HttpStatus.notFound;
        requestBody.request.response.write('Not Found');
        await requestBody.request.response.close();
    }
  });
  print('Server is listening at http://$address:$port');
}
