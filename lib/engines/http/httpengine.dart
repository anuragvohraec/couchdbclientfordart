
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:couchdbclientfordart/engines/uri/uriengine.dart';
import 'package:http/http.dart';

class CompositeResponse{
  String body;
  Map<String, dynamic> headers;
  int statusCode;
  Action reqAction;
  CompositeResponse(this.body, this.headers, this.statusCode, this.reqAction);

}


class HttpEngine{

  String domainName;

  HttpEngine(this.domainName);

  //output can be Response  or Uint8List
  Future<CompositeResponse> process(HttpMethod method, String inputUriString ,{Map<String, String> headers,String body, String localFilePathToPickUpFile, String localFilePathToSaveAttachment}) async{
    URIEngineResult result = URIEngine.indentifyTheAction(method, inputUriString);
    String url = "$domainName$inputUriString";

    switch(result.action){

      case Action.GET_DBMS_INFO:
        var res = await get(url , headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.CHECK_DB_EXISTENCE:
        var res = await  head(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.GET_INFO_ABT_A_DB:
        var res = await   get(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.PUT_A_NEW_DB:
        var res = await   put(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.DELETE_THE_DB:
        var res = await   delete(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.POST_A_NEW_DOC:
        var res = await   post(url,headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.CHECK_DOC_EXISTENCE:
        var res = await   head(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.GET_THE_DOCUMENT:
        var res = await   get(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.PUT_A_DOC:
        var res = await   put(url, headers: headers, body: body,encoding: Encoding.getByName("utf-8") );
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.DELETE_THE_DOC:
        var res = await   delete(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.CHECK_DESIGN_DOC_EXISTENCE:
        var res = await   head(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.GET_THE_DESIGN_DOC:
        var res = await   get(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.PUT_A_DESIGN_DOC:
        var res = await   put(url, headers: headers, body: body,encoding: Encoding.getByName("utf-8") );
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.DELETE_A_DESIGN_DOC:
        var res = await   delete(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.GET_THE_RESULT_OF_VIEW:
        var res = await  get(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.POST_A_VIEW_QUERY:
        var res = await   post(url,headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.CHECK_ATTACHMENT_EXISTENCE:
        var res = await  head(url, headers: headers);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.GET_ATTACHMENT_FOR_THE_DOC:
        var res = await  get(url, headers: headers);
        final fileName = url.split("/").last;
        Uint8List bytes = res.bodyBytes;
        if(localFilePathToSaveAttachment.endsWith("/")){
          localFilePathToSaveAttachment=localFilePathToSaveAttachment.substring(0,localFilePathToSaveAttachment.length-2);
        }
        var outputFile = File("$localFilePathToSaveAttachment/$fileName");
        outputFile.writeAsBytes(bytes);
        return CompositeResponse('', res.headers,res.statusCode, result.action);
        break;
      case Action.PUT_AN_ATTACHMENT_TO_THE_DOC:
        /*return upload(File(localFilePathToPickUpFile), url, headers['Content-Type']);*/
        var req = StreamedRequest("put", Uri.parse(url))
        ..headers.addAll(headers);
        File f1 = File(localFilePathToPickUpFile);
        var str = f1.openRead();
        str.listen(req.sink.add).onDone((){
          req.sink.close();
        });

        var res = await req.send().then(Response.fromStream);
        return CompositeResponse(res.body, res.headers,res.statusCode, result.action);
        break;
      case Action.DELETE_THE_ATTACHMENT_OF_THE_DOC:
        var res = await delete(url);
        return CompositeResponse(res.body,res.headers,res.statusCode, result.action);
        break;
      case Action.CASE_DO_NOT_EXIST:
        // TODO: Handle this case.
        break;
    }
  }


}