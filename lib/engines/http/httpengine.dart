
import 'dart:convert';
import 'dart:io';

import 'package:couchdbclientfordart/engines/uri/uriengine.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';

class fileToBeUploaded{

  String domainName;

  fileToBeUploaded(this.domainName);

  //output can be Response  or Uint8List
  Future<dynamic> process(HttpMethod method, String inputUriString ,{Map<String, String> headers,String body, String attachmentFilePath}){
    URIEngineResult result = URIEngine.indentifyTheAction(method, inputUriString);
    String url = "$domainName$inputUriString";

    switch(result.action){

      case Action.GET_DBMS_INFO:
        return get(url);
        break;
      case Action.CHECK_DB_EXISTENCE:
        return  head(url);
        break;
      case Action.GET_INFO_ABT_A_DB:
        return  get(url);
        break;
      case Action.PUT_A_NEW_DB:
        return  put(url);
        break;
      case Action.DELETE_THE_DB:
        return  delete(url);
        break;
      case Action.POST_A_NEW_DOC:
        return  post(url,headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
        break;
      case Action.CHECK_DOC_EXISTENCE:
        return  head(url);
        break;
      case Action.GET_THE_DOCUMENT:
        return  get(url);
        break;
      case Action.PUT_A_DOC:
        return  put(url, headers: headers, body: body,encoding: Encoding.getByName("utf-8") );
        break;
      case Action.DELETE_THE_DOC:
        return  delete(url);
        break;
      case Action.CHECK_DESIGN_DOC_EXISTENCE:
        return  head(url);
        break;
      case Action.GET_THE_DESIGN_DOC:
        return  get(url);
        break;
      case Action.PUT_A_DESIGN_DOC:
        return  put(url, headers: headers, body: body,encoding: Encoding.getByName("utf-8") );
        break;
      case Action.DELETE_A_DESIGN_DOC:
        return  delete(url);
        break;
      case Action.GET_THE_RESULT_OF_VIEW:
        return get(url);
        break;
      case Action.POST_A_VIEW_QUERY:
        return  post(url,headers: headers, body: body, encoding: Encoding.getByName("utf-8"));
        break;
      case Action.CHECK_ATTACHMENT_EXISTENCE:
        return head(url);
        break;
      case Action.GET_ATTACHMENT_FOR_THE_DOC:
        var nasb = NetworkAssetBundle(Uri.parse(url));
        return nasb.load(url);
        break;
      case Action.PUT_AN_ATTACHMENT_TO_THE_DOC:
        return upload(File(attachmentFilePath), url, headers['Content-Type']);
        break;
      case Action.DELETE_THE_ATTACHMENT_OF_THE_DOC:
        return delete(url);
        break;
      case Action.CASE_DO_NOT_EXIST:
        // TODO: Handle this case.
        break;
    }
  }

  upload(File imageFile, url, String contentType) async {
    var ct = contentType.split('/');
    var stream = new ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(url);

    var request = MultipartRequest("POST", uri);
    var multipartFile = MultipartFile('file', stream, length,
        filename: imageFile.path, contentType: MediaType(ct[0], ct[1]));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    /*response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
*/
    return response;
  }

}