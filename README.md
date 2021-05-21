# test_dart_mongo

## Prerequirement
1. Install [MongoDB](https://docs.mongodb.com/manual/administration/install-community/)

### Dependencies
- [momgo_dart](https://pub.dev/packages/mongo_dart/install)

### Impoer json data to mongodb
```
mongoimport --jsonArray -d <yourDatabaseName> -c <yourCollectionName> --file <path/To/File.json>
```

> [Mongo shell quick reference](https://docs.mongodb.com/manual/reference/mongo-shell/) for Shell Command