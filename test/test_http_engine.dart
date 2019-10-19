import 'package:couchdbclientfordart/engines/http/httpengine.dart';
import "package:couchdbclientfordart/engines/uri/uriengine.dart";
import "package:flutter_test/flutter_test.dart";
import "dart:convert";
import "dart:io";

import 'package:http/http.dart';


///PRE_REQUISITE:
/// couchdb is started at : http://0.0.0.0:5984 [if its at different address, the update the domain string in test case]
main() async {
  final String domain = "http://0.0.0.0:5984";
  final String testdb = "testdb";

  test("Case 1: GET_DBMS_INFO",() async{
    final he = HttpEngine(domain);
    var res = await he.process(HttpMethod.GET, "/");
    var jsonRes = json.decode(res.body);
    expect(res.reqAction, Action.GET_DBMS_INFO );
    expect(jsonRes["couchdb"],"Welcome");
  });

  test("Case 2: PUT, CHECK, GET and DELETE a DB",() async{
    final he = HttpEngine(domain);

    //PUT_A_NEW_DB
    {
      var res = await he.process(HttpMethod.PUT, "/$testdb");
      var jsonRes = json.decode(res.body);
      expect(res.reqAction, Action.PUT_A_NEW_DB );
      expect(jsonRes["ok"],true);
    }

    //CHECK_DB_EXISTENCE
    {
      var res1 = await he.process(HttpMethod.HEAD, "/$testdb");
      expect(res1.reqAction, Action.CHECK_DB_EXISTENCE );
      expect(res1.statusCode, 200);
    }
    //GET_INFO_ABT_A_DB
    {
      var res2 = await he.process(HttpMethod.GET, "/$testdb");
      var jsonRes2 = json.decode(res2.body);
      expect(res2.reqAction, Action.GET_INFO_ABT_A_DB );
      expect(jsonRes2["db_name"],"testdb");
    }

    //DELETE_THE_DB
    {
      var res3 = await he.process(HttpMethod.DELETE, "/$testdb");
      var jsonRes3 = json.decode(res3.body);
      expect(res3.reqAction, Action.DELETE_THE_DB );
      expect(jsonRes3["ok"],true);
    }
  });

  test("Case 3: POST, CHECK, GET, PUT and DELETE a DOC ",() async{
    //putting a testdb for testing first
    final he = HttpEngine(domain);
    await he.process(HttpMethod.PUT, "/$testdb");
    //assuming all is well here, as the test case before has tested creation of DB already

    String id_of_new_doc;
    String rev_of_new_doc;
    String rev_after_update;

    //POST_A_NEW_DOC
    {
      var res1 = await he.process(HttpMethod.POST, "/$testdb",body: '{"t":1}', headers: {"Content-Type":"application/json"});
      var jsonRes1 = json.decode(res1.body);
      expect(res1.reqAction, Action.POST_A_NEW_DOC );
      expect(jsonRes1["ok"],true);
      id_of_new_doc = jsonRes1["id"];
      rev_of_new_doc  = jsonRes1["rev"];
    }

    //CHECK_DOC_EXISTENCE
    {
      var res2 = await he.process(HttpMethod.HEAD, "/$testdb/$id_of_new_doc");
      expect(res2.reqAction, Action.CHECK_DOC_EXISTENCE );
      expect(res2.statusCode, 200);
    }

    //GET_THE_DOCUMENT
    {
      var res3 = await he.process(HttpMethod.GET, "/$testdb/$id_of_new_doc");
      expect(res3.reqAction, Action.GET_THE_DOCUMENT );
      expect(res3.statusCode, 200);
      var jsonRes3 = json.decode(res3.body);
      expect(jsonRes3["t"],1);
    }

    //PUT_A_DOC
    {
      var res4 = await he.process(HttpMethod.PUT, "/$testdb/$id_of_new_doc?rev=$rev_of_new_doc",body: '{"t":12}', headers: {"Content-Type":"application/json"});
      var jsonRes4 = json.decode(res4.body);
      expect(res4.reqAction, Action.PUT_A_DOC );
      expect(jsonRes4["ok"],true);
      var id_of_new_doc4 = jsonRes4["id"];
      var rev_of_new_doc4 = jsonRes4["rev"];
      expect(id_of_new_doc4, id_of_new_doc);
      expect(rev_of_new_doc4.toString().startsWith("2"), true);
      rev_after_update = rev_of_new_doc4;
    }

    //DELETE_THE_DOC
    {
      var res4 = await he.process(HttpMethod.DELETE, "/$testdb/$id_of_new_doc?rev=$rev_after_update");
      var jsonRes4 = json.decode(res4.body);
      expect(res4.reqAction, Action.DELETE_THE_DOC );
      expect(jsonRes4["ok"],true);
      var id_of_new_doc4 = jsonRes4["id"];
      var rev_of_new_doc4 = jsonRes4["rev"];
      expect(id_of_new_doc4, id_of_new_doc);
      expect(rev_of_new_doc4.toString().startsWith("3"), true);
      rev_after_update = rev_of_new_doc4;
    }

    //DELETE_THE_DB ://assuming all is well here, as the test case before has tested creation of DB already
    await he.process(HttpMethod.DELETE, "/$testdb");
  });

  test("Case 4: PUT, CHECK, GET, and DELETE a DESIGN DOC ",() async{
    //putting a testdb for testing first
    final he = HttpEngine(domain);
    await he.process(HttpMethod.PUT, "/$testdb");
    //loading some data
    for(int i=0; i<4; i++){
      await he.process(HttpMethod.POST, "/$testdb",body: '{"t":$i}', headers: {"Content-Type":"application/json"});
    }
    //assuming all is well here, as the test case before has tested creation of DB already
    String id_of_new_doc="_design/testdesign";
    String rev_of_new_doc;

    String inputUri = "/$testdb/$id_of_new_doc";
    //PUT_A_DESIGN_DOC
    {
      var res = await he.process(HttpMethod.PUT,inputUri,
      body:"""
          {
            "_id" : "$id_of_new_doc",
            "validate_doc_update" : "function(nd,od,uc){validate([nd.t, 't is must']);}",
            "views" : {
              "by_t" : {
                "map" : "function(doc){ emit(doc.t)}"
              }
            }
          }
          """);
      var jsonRes = json.decode(res.body);
      expect(res.statusCode, 201);
      expect(res.reqAction, Action.PUT_A_DESIGN_DOC);
      expect(jsonRes["ok"],true);
      rev_of_new_doc=jsonRes['rev'];
    }

    //CHECK_DESIGN_DOC_EXISTENCE
    {
      var res = await he.process(HttpMethod.HEAD,inputUri);
      expect(res.statusCode, 200);
      expect(res.reqAction, Action.CHECK_DESIGN_DOC_EXISTENCE);
    }

    //GET_THE_DESIGN_DOC
    {
      var res = await he.process(HttpMethod.GET,inputUri);
      expect(res.statusCode, 200);
      expect(res.reqAction, Action.GET_THE_DESIGN_DOC);
      var jsonRes = json.decode(res.body);
      expect(jsonRes["_id"],id_of_new_doc);
      expect(jsonRes["_rev"],rev_of_new_doc);
    }

    //DELETE_A_DESIGN_DOC
    {
      var res = await he.process(HttpMethod.DELETE,"$inputUri?rev=$rev_of_new_doc");
      var jsonRes = json.decode(res.body);
      expect(res.reqAction, Action.DELETE_A_DESIGN_DOC );
      expect(jsonRes["ok"],true);
    }

    //DELETE_THE_DB ://assuming all is well here, as the test case before has tested creation of DB already
   await he.process(HttpMethod.DELETE, "/$testdb");
  });

  test("Case 5: GET and POST a View and View query",() async{
    //putting a testdb for testing first
    final he = HttpEngine(domain);
    await he.process(HttpMethod.PUT, "/$testdb");
    //loading some data
    for (int i = 0; i < 4; i++) {
      await he.process(HttpMethod.POST, "/$testdb", body: '{"t":$i}',
          headers: {"Content-Type": "application/json"});
    }

    String id_of_design_doc = "_design/testdesign";

    String designDocUri = "/$testdb/$id_of_design_doc";

    await he.process(HttpMethod.PUT,designDocUri,
        body:"""
          {
            "_id" : "$id_of_design_doc",
            "validate_doc_update" : "function(nd,od,uc){validate([nd.t, 't is must']);}",
            "views" : {
              "by_t" : {
                "map" : "function(doc){ emit(doc.t)}"
              }
            }
          }
          """);
    var viewUri = '$designDocUri/_view/by_t';
    //assuming all is well here, as the test case before has tested creation of DB already

    //GET_THE_RESULT_OF_VIEW
    {
      var res = await he.process(HttpMethod.GET, viewUri);
      expect(res.statusCode, 200);
      expect(res.reqAction, Action.GET_THE_RESULT_OF_VIEW);
      var jsonRes = json.decode(res.body);
      expect(jsonRes["total_rows"],4);
    }


    //POST_A_VIEW_QUERY
    {
      var res = await he.process(HttpMethod.POST, viewUri,
      body: """
            {
              "keys" : [1,2]
            }
            """,
      headers: {"Content-Type": "application/json"}
      );
      expect(res.statusCode, 200);
      expect(res.reqAction, Action.POST_A_VIEW_QUERY);
      var jsonRes = json.decode(res.body);
      expect((jsonRes["rows"] as List).length,2);
    }

    //DELETE_THE_DB ://assuming all is well here, as the test case before has tested creation of DB already
    await he.process(HttpMethod.DELETE, "/$testdb");
  });


  test("Case 6: POST, CHECK, GET, PUT and DELETE a DOC ",() async{
    //putting a testdb for testing first
    final he = HttpEngine(domain);
    await he.process(HttpMethod.PUT, "/$testdb");

    String id_of_new_doc;
    String rev_of_new_doc;
    String rev_after_update;

    //POST_A_NEW_DOC
    {
      var res = await he.process(HttpMethod.POST, "/$testdb", body: '{"t":1}',
          headers: {"Content-Type": "application/json"});
      var jsonRes = json.decode(res.body);
      expect(res.reqAction, Action.POST_A_NEW_DOC);
      expect(jsonRes["ok"], true);
      id_of_new_doc = jsonRes["id"];
      rev_of_new_doc = jsonRes["rev"];
    }
    //assuming all is well here, as the test case before has tested creation of DB already
    var inputUriString ="/$testdb/$id_of_new_doc/sampleimage.png";

    //PUT_AN_ATTACHMENT_TO_THE_DOC
    {
      var localFilePathToPickUpFile="test/test_assets/sampleimage.png";
      var res = await he.process(HttpMethod.PUT, "$inputUriString?rev=$rev_of_new_doc",
        localFilePathToPickUpFile: localFilePathToPickUpFile,
          headers: {"Content-Type": "image/png"}
      );
      expect(res.statusCode, 201); //201: created successfully
      var jsonRes = json.decode(res.body);
      expect(res.reqAction, Action.PUT_AN_ATTACHMENT_TO_THE_DOC);
      expect(jsonRes["ok"], true);
      rev_after_update= jsonRes['rev'];
      expect(rev_after_update.startsWith("2"), true);
    }

    //GET_ATTACHMENT_FOR_THE_DOC
    {
      var localFilePathToSaveAttachment = "test/test_assets/downloaded";
      var res = await he.process(HttpMethod.GET, inputUriString,
      localFilePathToSaveAttachment: localFilePathToSaveAttachment
      );
      expect(res.statusCode, 200);
    }

    //DELETE_THE_ATTACHMENT_OF_THE_DOC
    {
      var res = await he.process(HttpMethod.DELETE, "$inputUriString?rev=$rev_after_update");
      print(res.reqAction);
      expect(res.statusCode, 200);
    }

    //DELETE_THE_DB ://assuming all is well here, as the test case before has tested creation of DB already
    await he.process(HttpMethod.DELETE, "/$testdb");
  });


  }