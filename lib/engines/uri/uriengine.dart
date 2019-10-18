import 'package:uri/uri.dart';

enum HttpMethod { GET, POST, PUT, HEAD, DELETE, COPY }

//URIEngine's results facade
class URIEngineResult{
  Action action;
  UriParser parser;
  Uri inputUri;

  URIEngineResult(this.action, this.parser, this.inputUri);
}

///Parses a api uri request and let other components know what this particular action it demands
class URIEngine {

  static final db_parser = _getUriParser("/{db}");
  static final db_docid_parser= _getUriParser("/{db}/{docid}");
  static final db_design_ddoc_parser = _getUriParser("/{db}/_design/{ddoc}");
  static final db_docid_attname_parser = _getUriParser("/{db}/{docid}/{attname}");
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
        case HttpMethod.GET:
          if (inputUriString == '/') {
            return URIEngineResult(Action.GET_DBMS_INFO,null,inputUri);
          }else if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.GET_INFO_ABT_A_DB,db_parser,inputUri);
          }
          break;
        case HttpMethod.POST:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.CREATE_A_NEW_DOC,db_parser,inputUri);
          }
          break;
        case HttpMethod.PUT:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.CREATE_A_NEW_DB,db_parser,inputUri);
          }
          break;
        case HttpMethod.HEAD:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.CHECK_DB_EXTIENCE,db_parser,inputUri);
          }
          break;
        case HttpMethod.DELETE:
          if (_doItMatches(db_parser, inputUri)) {
            return URIEngineResult(Action.DELETE_THE_DB,db_parser,inputUri);
          }
          break;
        case HttpMethod.COPY:
          break;
      }
    }else if(uriparts.length ==3){
      var uriparam = db_docid_parser.parse(inputUri); //URI params

      if(!uriparam["docid"].startsWith("_")){
        switch(method){
          case HttpMethod.GET:
            return URIEngineResult(Action.GIVE_THE_DOCUMENT,db_docid_parser,inputUri);
            break;
          case HttpMethod.POST:
            break;
          case HttpMethod.PUT:
            return URIEngineResult(Action.CREATE_A_NEW_OR_NEW_VERSION_OF_DOC, db_docid_parser,inputUri);
            break;
          case HttpMethod.HEAD:
            return URIEngineResult(Action.GIVE_HEADERS_FOR_THE_DOC, db_docid_parser,inputUri);
            break;
          case HttpMethod.DELETE:
            return URIEngineResult(Action.DELETE_THE_DOC, db_docid_parser,inputUri);
            break;
          case HttpMethod.COPY:
            return URIEngineResult(Action.CREATE_A_COPY_OF_THE_DOC, db_docid_parser,inputUri);
            break;
        }
      }
    }else if(uriparts.length==4){

      if(_doItMatches(db_design_ddoc_parser, inputUri)){
        switch(method){
          case HttpMethod.GET:
            return URIEngineResult(Action.GIVE_THE_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.POST:
            break;
          case HttpMethod.PUT:
            return URIEngineResult(Action.CREATE_A_NEW_OR_NEW_VERSION_OF_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.HEAD:
            return URIEngineResult(Action.GIVE_HEADERS_FOR_DESIGN_DOC,db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.DELETE:
            return URIEngineResult(Action.DELETE_A_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
          case HttpMethod.COPY:
            return URIEngineResult(Action.COPIES_THE_DESIGN_DOC, db_design_ddoc_parser, inputUri);
            break;
        }
      }else if(_doItMatches(db_docid_attname_parser, inputUri)){
        //TODO
      }
    }else if(uriparts.length==5){

    }else if(uriparts.length==6){
      if(_doItMatches(db_design_ddoc_view_parser, inputUri)){
        switch(method){
          case HttpMethod.GET:
            return URIEngineResult(Action.GIVE_RESULT_OF_VIEW, db_design_ddoc_view_parser, inputUri);
            break;
          case HttpMethod.POST:
            return URIEngineResult(Action.GIVE_RESULT_OF_SPECIFIED_VIEW_QUERY, db_design_ddoc_view_parser, inputUri);
            break;
          case HttpMethod.PUT:
            break;
          case HttpMethod.HEAD:
            break;
          case HttpMethod.DELETE:
            break;
          case HttpMethod.COPY:
            break;
        }
      }
    }

    return URIEngineResult(Action.CASE_DO_NOT_EXIST,null,inputUri);
  }

}

enum Action {
  GET_DBMS_INFO,
  CHECK_DB_EXTIENCE,
  GET_INFO_ABT_A_DB,
  CREATE_A_NEW_DB,
  DELETE_THE_DB,
  CREATE_A_NEW_DOC,
  GIVE_HEADERS_FOR_THE_DOC,
  GIVE_THE_DOCUMENT,
  CREATE_A_NEW_OR_NEW_VERSION_OF_DOC,
  DELETE_THE_DOC,
  CREATE_A_COPY_OF_THE_DOC,
  GIVE_HEADERS_FOR_DESIGN_DOC,
  GIVE_THE_DESIGN_DOC,
  CREATE_A_NEW_OR_NEW_VERSION_OF_DESIGN_DOC,
  DELETE_A_DESIGN_DOC,
  COPIES_THE_DESIGN_DOC,
  GIVE_RESULT_OF_VIEW,
  GIVE_RESULT_OF_SPECIFIED_VIEW_QUERY,
  GIVE_HEADERS_FOR_ATTACHMENT,

  CASE_DO_NOT_EXIST,

}