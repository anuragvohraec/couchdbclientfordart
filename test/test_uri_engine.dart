import "package:flutter_test/flutter_test.dart";
import "package:couchdbclientfordart/engines/uri/uriengine.dart";

main (){

  test("CASE 1: GET_DBMS_INFO",(){
    const uriString = "/";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_DBMS_INFO);
    expect( URIEngine.indentifyTheAction(HttpMethod.GET, "/somethingelse").action==Action.GET_DBMS_INFO,false);
  });

  test("CASE 2: GET_INFO_ABT_A_DB",(){
    const uriString = "/mydb";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_INFO_ABT_A_DB);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
  });

  test("CASE 3: CREATE_A_NEW_DOC",(){
    const uriString = "/mydb";
    var result = URIEngine.indentifyTheAction(HttpMethod.POST, uriString);

    expect( result.action,Action.POST_A_NEW_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
  });

  test("CASE 4: CREATE_A_NEW_DB",(){
    const uriString = "/mydb";
    var result = URIEngine.indentifyTheAction(HttpMethod.PUT, uriString);

    expect( result.action,Action.PUT_A_NEW_DB);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
  });

  test("CASE 5: CHECK_DB_EXTIENCE",(){
    const uriString = "/mydb";
    var result = URIEngine.indentifyTheAction(HttpMethod.HEAD, uriString);

    expect( result.action,Action.CHECK_DB_EXISTENCE);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
  });

  test("CASE 6: DELETE_THE_DB",(){
    const uriString = "/mydb";
    var result = URIEngine.indentifyTheAction(HttpMethod.DELETE, uriString);

    expect( result.action,Action.DELETE_THE_DB);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
  });

  test("CASE 7: GIVE_THE_DOCUMENT",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_THE_DOCUMENT);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "1234");
  });

  test("CASE 8: POST /{db}/{docid}",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.POST, uriString);

    expect( result.action,Action.CASE_DO_NOT_EXIST);
    expect( result.parser, null);
  });

  test("CASE 9: CREATE_A_NEW_OR_NEW_VERSION_OF_DOC",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.PUT, uriString);

    expect( URIEngine.indentifyTheAction(HttpMethod.PUT, "/mydb/1234").action,Action.PUT_A_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "1234");
  });

  test("CASE 10: GIVE_HEADERS_FOR_THE_DOC",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.HEAD, uriString);

    expect( result.action,Action.CHECK_DOC_EXISTENCE);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "1234");
  });

  test("CASE 11: DELETE_THE_DOC",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.DELETE, uriString);

    expect( result.action,Action.DELETE_THE_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "1234");
  });
/*
  test("CASE 12: CREATE_A_COPY_OF_THE_DOC",(){
    const uriString = "/mydb/1234";
    var result = URIEngine.indentifyTheAction(HttpMethod.COPY, uriString);

    expect( result.action,Action.COPY_THE_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "1234");
  });*/

  test("CASE 13: GIVE_THE_DESIGN_DOC: GET /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_THE_DESIGN_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
  });

  test("CASE 14: CASE_DO_NOT_EXIST: POST /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.POST, uriString);

    expect( result.action,Action.CASE_DO_NOT_EXIST);
    expect( result.parser, null);
  });

  test("CASE 15: CREATE_A_NEW_OR_NEW_VERSION_OF_DESIGN_DOC: PUT /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.PUT, uriString);

    expect( result.action,Action.PUT_A_DESIGN_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
  });

  test("CASE 16: GIVE_HEADERS_FOR_DESIGN_DOC: HEAD /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.HEAD, uriString);

    expect( result.action,Action.CHECK_DESIGN_DOC_EXISTENCE);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
  });

  test("CASE 16: DELETE_A_DESIGN_DOC: DELETE /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.DELETE, uriString);

    expect( result.action,Action.DELETE_A_DESIGN_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
  });
/*

  test("CASE 17: COPIES_THE_DESIGN_DOC: COPY /{db}/_design/{ddoc}",(){
    const uriString = "/mydb/_design/foremployees";
    var result = URIEngine.indentifyTheAction(HttpMethod.COPY, uriString);

    expect( result.action,Action.COPY_THE_DESIGN_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
  });
*/

  test("CASE 18: GIVE_RESULT_OF_VIEW: GET /{db}/_design/{ddoc}/_view/{view}",(){
    const uriString = "/mydb/_design/foremployees/_view/by_salary";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_THE_RESULT_OF_VIEW);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
    expect(map['view'], "by_salary");
  });

  test("CASE 19: GIVE_RESULT_OF_SPECIFIED_VIEW_QUERY: POST /{db}/_design/{ddoc}/_view/{view}",(){
    const uriString = "/mydb/_design/foremployees/_view/by_salary";
    var result = URIEngine.indentifyTheAction(HttpMethod.POST, uriString);

    expect( result.action,Action.POST_A_VIEW_QUERY);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['ddoc'], "foremployees");
    expect(map['view'], "by_salary");
  });

  test("CASE 20: GIVE_HEADERS_FOR_ATTACHMENT: POST /{db}/{docid}/{attname}",(){
    const uriString = "/mydb/123/profile.png";
    var result = URIEngine.indentifyTheAction(HttpMethod.HEAD, uriString);

    expect( result.action,Action.CHECK_ATTACHMENT_EXISTENCE);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "123");
    expect(map['attname'], "profile.png");
  });


  test("CASE 21: GIVE_ATTACHMENT_FOR_DOC: GET /{db}/{docid}/{attname}",(){
    const uriString = "/mydb/123/profile.png";
    var result = URIEngine.indentifyTheAction(HttpMethod.GET, uriString);

    expect( result.action,Action.GET_ATTACHMENT_FOR_THE_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "123");
    expect(map['attname'], "profile.png");
  });

  test("CASE 22: ADD_ATTACHMENT_TO_DOC: PUT /{db}/{docid}/{attname}",(){
    const uriString = "/mydb/123/profile.png";
    var result = URIEngine.indentifyTheAction(HttpMethod.PUT, uriString);

    expect( result.action,Action.PUT_AN_ATTACHMENT_TO_THE_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "123");
    expect(map['attname'], "profile.png");
  });

  test("CASE 22: DELETE_THE_ATTACHMENT_OF_DOC: PUT /{db}/{docid}/{attname}",(){
    const uriString = "/mydb/123/profile.png";
    var result = URIEngine.indentifyTheAction(HttpMethod.DELETE, uriString);

    expect( result.action,Action.DELETE_THE_ATTACHMENT_OF_THE_DOC);
    var map = result.parser.parse(result.inputUri);
    expect(map['db'], "mydb");
    expect(map['docid'], "123");
    expect(map['attname'], "profile.png");
  });

}