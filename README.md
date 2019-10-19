# couchdbclientfordart

A couch db client written for dart and flutter.

## Getting Started

You example use case:
```
final he = HttpEngine(domain);
var res = await he.process(HttpMethod.GET, "/");
var jsonRes = json.decode(res.body);
expect(res.reqAction, Action.GET_DBMS_INFO );
expect(jsonRes["couchdb"],"Welcome");
```
___
This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
