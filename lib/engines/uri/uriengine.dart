import 'package:uri/uri.dart';

enum HttpMethod { HEAD, GET, POST, PUT, DELETE }

//URIEngine's results facade
class URIEngineResult{
  Action action;
  UriParser parser;
  Uri inputUri;

  URIEngineResult(this.action, this.parser, this.inputUri);
}

///Parses a api uri request and let other components know what this particular action it demands
class URIEngine {

  ///**/{db\}**
  static final db_parser = _getUriParser("/{db}");
  ///**/{db}/{docid}**
  static final db_docid_parser= _getUriParser("/{db}/{docid}");
  ///**/{db}/_design/{ddoc}**
  static final db_design_ddoc_parser = _getUriParser("/{db}/_design/{ddoc}");
  ///**/{db}/{docid}/{attname}**
  static final db_docid_attname_parser = _getUriParser("/{db}/{docid}/{attname}");
  ///**/{db}/_design/{ddoc}/_view/{view}**
  static final db_design_ddoc_view_parser = _getUriParser("/{db}/_design/{ddoc}/_view/{view}");


  ///gets the URI parser for the given template
  static UriParser _getUriParser(String template){
    var uriTemplate =  UriTemplate(template);
    return UriParser(uriTemplate);
  }

  ///do the input uri matches the template parser
  static bool _doItMatches(UriParser templateParser, Uri inputUri) {
    return templateParser.matches(inputUri);
  }


  ////classifies a uri into: what action this URI Demands
  static URIEngineResult indentifyTheAction(HttpMethod method, String inputUriString) {
    final uriparts = inputUriString.split("/");
    Uri inputUri = Uri.parse(inputUriString);

    if (uriparts.length == 2) {

      switch(method){
        case HttpMethod.HEAD:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.CHECK_DB_EXISTENCE,db_parser,inputUri);
          }
          break;
        case HttpMethod.GET:
          if (inputUriString == '/') {
            return URIEngineResult(Action.GET_DBMS_INFO,null,inputUri);
          }else if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.GET_INFO_ABT_A_DB,db_parser,inputUri);
          }
          break;
        case HttpMethod.POST:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.POST_A_NEW_DOC,db_parser,inputUri);
          }
          break;
        case HttpMethod.PUT:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.PUT_A_NEW_DB,db_parser,inputUri);
          }
          break;
        case HttpMethod.DELETE:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.DELETE_THE_DB,db_parser,inputUri);
          }
          break;
      }
    }else if(uriparts.length ==3){
      var uriparam = db_docid_parser.parse(inputUri); //URI params

      if(!uriparam["docid"].startsWith("_")){
        switch(method){
          case HttpMethod.HEAD:
            return URIEngineResult(Action.CHECK_DOC_EXISTENCE, db_docid_parser,inputUri);
            break;
          case HttpMethod.GET:
            return URIEngineResult(Action.GET_THE_DOCUMENT,db_docid_parser,inputUri);
            break;
          case HttpMethod.POST:
            break;
          case HttpMethod.PUT:
            return URIEngineResult(Action.PUT_A_DOC, db_docid_parser,inputUri);
            break;
          case HttpMethod.DELETE:
            return URIEngineResult(Action.DELETE_THE_DOC, db_docid_parser,inputUri);
            break;
        }
      }
    }else if(uriparts.length==4){

      if(_doItMatches(db_design_ddoc_parser, inputUri)){
        switch(method){
          case HttpMethod.HEAD:
            return URIEngineResult(Action.CHECK_DESIGN_DOC_EXISTENCE,db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.GET:
            return URIEngineResult(Action.GET_THE_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.POST:
            break;
          case HttpMethod.PUT:
            return URIEngineResult(Action.PUT_A_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.DELETE:
            return URIEngineResult(Action.DELETE_A_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
        }
      }else if(_doItMatches(db_docid_attname_parser, inputUri)){
        switch(method){
          case HttpMethod.HEAD:
            return URIEngineResult(Action.CHECK_ATTACHMENT_EXISTENCE, db_docid_attname_parser, inputUri);
            break;
          case HttpMethod.GET:
            return URIEngineResult(Action.GET_ATTACHMENT_FOR_THE_DOC, db_docid_attname_parser, inputUri);
            break;
          case HttpMethod.POST:
            break;
          case HttpMethod.PUT:
            return URIEngineResult(Action.PUT_AN_ATTACHMENT_TO_THE_DOC, db_docid_attname_parser, inputUri);
            break;
          case HttpMethod.DELETE:
            return URIEngineResult(Action.DELETE_THE_ATTACHMENT_OF_THE_DOC, db_docid_attname_parser, inputUri);
            break;
        }
      }
    }else if(uriparts.length==5){

    }else if(uriparts.length==6){
      if(_doItMatches(db_design_ddoc_view_parser, inputUri)){
        switch(method){
          case HttpMethod.HEAD:
            break;
          case HttpMethod.GET:
            return URIEngineResult(Action.GET_THE_RESULT_OF_VIEW, db_design_ddoc_view_parser, inputUri);
            break;
          case HttpMethod.POST:
            return URIEngineResult(Action.POST_A_VIEW_QUERY, db_design_ddoc_view_parser, inputUri);
            break;
          case HttpMethod.PUT:
            break;
          case HttpMethod.DELETE:
            break;
        }
      }
    }

    return URIEngineResult(Action.CASE_DO_NOT_EXIST,null,inputUri);
  }

}


enum Action {
  ///**GET /**
  GET_DBMS_INFO,
  ///**HEAD /{db}**
  CHECK_DB_EXISTENCE,
  ///**GET /{db}**
  GET_INFO_ABT_A_DB,
  ///**PUT /{db}**
  PUT_A_NEW_DB,
  ///DELETE /{db}**
  DELETE_THE_DB,
  ///POST /{db}**
  POST_A_NEW_DOC,
  ///**HEAD /{db}/{docid}**
  CHECK_DOC_EXISTENCE,
  ///**GET /{db}/{docid}**
  GET_THE_DOCUMENT,
  ///**PUT /{db}/{docid}**
  PUT_A_DOC,
  ///**DELETE /{db}/{docid}**
  DELETE_THE_DOC,
  ///**HEAD /{db}/_design/{ddoc}**
  CHECK_DESIGN_DOC_EXISTENCE,
  ///**GET /{db}/_design/{ddoc}**
  GET_THE_DESIGN_DOC,
  ///**PUT /{db}/_design/{ddoc}**
  PUT_A_DESIGN_DOC,
  ///**DELETE /{db}/_design/{ddoc}**
  DELETE_A_DESIGN_DOC,
  ///**GET /{db}/_design/{ddoc}/_view/{view}**
  GET_THE_RESULT_OF_VIEW,
  ///**POST /{db}/_design/{ddoc}/_view/{view}**
  POST_A_VIEW_QUERY,
  ///**HEAD /{db}/{docid}/{attname}**
  CHECK_ATTACHMENT_EXISTENCE,
  ///**GET /{db}/{docid}/{attname}**
  GET_ATTACHMENT_FOR_THE_DOC,
  ///**PUT /{db}/{docid}/{attname}**
  PUT_AN_ATTACHMENT_TO_THE_DOC,
  ///**DELETE /{db}/{docid}/{attname}**
  DELETE_THE_ATTACHMENT_OF_THE_DOC,

  ///No api present or not coded yet in this package
  CASE_DO_NOT_EXIST,
}