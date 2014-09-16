/*
 * Package : Sporran
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/02/2014
 * Copyright :  S.Hamblett@OSCF
 */

library sporran_test;

import 'dart:async';
import 'dart:html';

import 'package:sporran/sporran.dart';
import 'package:json_object/json_object.dart';
import 'package:wilt/wilt.dart';
import 'package:wilt/wilt_browser_client.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'sporran_test_config.dart';

main() {

  useHtmlConfiguration();

  /* Common initialiser */
  SporranInitialiser initialiser = new SporranInitialiser();
  initialiser.dbName = databaseName;
  initialiser.hostname = hostName;
  initialiser.manualNotificationControl = true;
  initialiser.port = port;
  initialiser.scheme = scheme;
  initialiser.username = userName;
  initialiser.password = userPassword;
  initialiser.preserveLocal = false;

  /* Group 1 - Environment tests */
  group("1. Environment Tests - ", () {

    print("1.1");
    String status = "online";

    test("Online/Offline", () {

      window.onOffline.first.then((e) {

        expect(status, "offline");
        /* Because we aren't really offline */
        expect(window.navigator.onLine, isTrue);

      });

      window.onOnline.first.then((e) {

        expect(status, "online");
        expect(window.navigator.onLine, isTrue);

      });

      status = "offline";
      var e = new Event.eventType('Event', 'offline');
      window.dispatchEvent(e);
      status = "online";
      e = new Event.eventType('Event', 'online');
      window.dispatchEvent(e);


    });

  });

  /* Group 2 - Sporran constructor/ invalid parameter tests */
  group("2. Constructor/Invalid Parameter Tests - ", () {

    Sporran sporran;

    test("0. Sporran Initialisation", ()  {

      print("2.0");
      sporran = new Sporran(initialiser);

      var wrapper = expectAsync0(() {

        expect(sporran, isNotNull);
        expect(sporran.dbName, databaseName);
        expect(sporran.online, true);

      });

      sporran.autoSync = false;
      sporran.onReady.first.then((e) => wrapper());
      
    });


    test("1. Construction Online/Offline listener ", () {

      print("2.1");
      Sporran sporran21;

      var wrapper = expectAsync0(() {

        Event offline = new Event.eventType('Event', 'offline');
        window.dispatchEvent(offline);
        expect(sporran21.online, isFalse);
        Event online = new Event.eventType('Event', 'online');
        window.dispatchEvent(online);
        expect(sporran21.online, isTrue);
        sporran21 = null;

      });


      var wrapper1 = expectAsync0(() {

        sporran21 = new Sporran(initialiser);
        sporran21.autoSync = false;
        sporran21.onReady.first.then((e) => wrapper());
      });

      Timer pause = new Timer(new Duration(seconds: 2), () {
        wrapper1();
      });


    });

    test("2. Construction Existing Database ", () {

      print("2.2");
      Sporran sporran22 = new Sporran(initialiser);

      var wrapper = expectAsync0(() {

        expect(sporran22, isNotNull);
        expect(sporran22.dbName, databaseName);
        sporran22 = null;

      });

      sporran22.autoSync = false;
      sporran22.onReady.first.then((e) => wrapper());

    });

    test("3. Construction Invalid Authentication ", () {

      print("2.3");
      initialiser.password = 'none';
      Sporran sporran23 = new Sporran(initialiser);
      initialiser.password = userPassword;

      var wrapper = expectAsync0(() {

        expect(sporran23, isNotNull);
        expect(sporran23.dbName, databaseName);
        expect(sporran23.online, true);
        sporran23 = null;

      });

      sporran23.autoSync = false;
      sporran23.onReady.first.then((e) => wrapper());


    });

    test("4. Put No Doc Id ", () {

      print("2.4");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.PUT_NO_DOC_ID);
      });

      sporran.put(null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("5. Get No Doc Id ", () {

      print("2.5");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.GET_NO_DOC_ID);
      });

      sporran.get(null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("6. Delete No Doc Id ", () {

      print("2.6");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.DELETE_NO_DOC_ID);
      });

      sporran.delete(null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("7. Put Attachment No Doc Id ", () {

      print("2.7");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.PUT_ATT_NO_DOC_ID);
      });

      sporran.putAttachment(null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("8. Put Attachment No Attachment ", () {

      print("2.8");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.PUT_ATT_NO_ATT);
      });

      sporran.putAttachment('billy', null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("9. Delete Attachment No Doc Id ", () {

      print("2.9");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.DELETE_ATT_NO_DOC_ID);
      });

      sporran.deleteAttachment(null, null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("10. Delete Attachment No Attachment Name ", () {

      print("2.10");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.DELETE_ATT_NO_ATT_NAME);
      });

      sporran.deleteAttachment('billy', null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("11. Delete Attachment No Revision ", () {

      print("2.11");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.DELETE_ATT_NO_REV);
      });
      //sporran.online = false;
      sporran.deleteAttachment('billy', 'fred', null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("12. Get Attachment No Doc Id ", () {

      print("2.12");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.GET_ATT_NO_DOC_ID);
      });

      sporran.getAttachment(null, null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("13. Get Attachment No Attachment Name ", () {

      print("2.13");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.GET_ATT_NO_ATT_NAME);
      });

      sporran.getAttachment('billy', null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("14. Bulk Create No Document List ", () {

      print("2.14");

      var completer = expectAsync1((e) {
        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.BULK_CREATE_NO_DOCLIST);
      });

      sporran.bulkCreate(null)..then((_) {}, onError: (SporranException e) {
            completer(e);
          });

    });

    test("15. Login invalid user ", () {

      print("2.15");

      try {

        sporran.login(null, 'password');

      } catch (e) {

        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.INVALID_LOGIN_CREDS);
      }

    });

    test("16. Login invalid password ", () {

      print("2.16");

      try {

        sporran.login('billy', null);

      } catch (e) {

        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.INVALID_LOGIN_CREDS);
      }

    });

    test("17. Null Initialiser ", () {

      print("2.17");

      try {

        Sporran bad = new Sporran(null);

      } catch (e) {

        expect(e.runtimeType.toString(), 'SporranException');
        expect(e.toString(), SporranException.HEADER + SporranException.NO_INITIALISER);
      }

    });

  });

  /* Group 3 - Sporran document put/get tests */
  group("3. Document Put/Get/Delete Tests - ", () {

    Sporran sporran3;

    String docIdPutOnline = "putOnlineg3";
    String docIdPutOffline = "putOfflineg3";
    JsonObject onlineDoc = new JsonObject();
    JsonObject offlineDoc = new JsonObject();
    String onlineDocRev;

    test("1. Create and Open Sporran", () {

      print("3.1");

      var wrapper1 = expectAsync0(() {

        expect(sporran3.lawnIsOpen, isTrue);

      });

      var wrapper = expectAsync0(() {

        expect(sporran3.dbName, databaseName);
        Timer timer = new Timer(new Duration(seconds: 3), wrapper1);

      });

      sporran3 = new Sporran(initialiser);
      sporran3.autoSync = false;
      sporran3.onReady.first.then((e) => wrapper());


    });

    test("2. Put Document Online docIdPutOnline", () {

      print("3.2");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT);
        expect(res.localResponse, isFalse);
        expect(res.id, docIdPutOnline);
        expect(res.rev, anything);
        onlineDocRev = res.rev;
        expect(res.payload.name, "Online");

      });

      onlineDoc.name = "Online";
      sporran3.put(docIdPutOnline, onlineDoc)..then((res) {
            wrapper(res);
          });


    });

    test("3. Put Document Offline docIdPutOffline", () {

      print("3.3");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT);
        expect(res.localResponse, isTrue);
        expect(res.id, docIdPutOffline);
        expect(res.payload.name, "Offline");

      });

      sporran3.online = false;
      offlineDoc.name = "Offline";
      sporran3.put(docIdPutOffline, offlineDoc)..then((res) {
            wrapper(res);
          });


    });


    test("4. Put Document Online Conflict", () {

      print("3.4");
      var wrapper = expectAsync1((res) {

        expect(res.errorCode, 409);
        expect(res.errorText, 'conflict');
        expect(res.operation, Sporran.PUT);
        expect(res.id, docIdPutOnline);


      });

      sporran3.online = true;
      onlineDoc.name = "Online";
      sporran3.put(docIdPutOnline, onlineDoc)..then((res) {
            wrapper(res);
          });

    });

    test("5. Put Document Online Updated docIdPutOnline", () {

      print("3.5");

      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT);
        expect(res.localResponse, isFalse);
        expect(res.id, docIdPutOnline);
        expect(res.rev, anything);
        expect(res.payload.name, "Online - Updated");

      });

      onlineDoc.name = "Online - Updated";
      sporran3.put(docIdPutOnline, onlineDoc, onlineDocRev)..then((res) {
            wrapper(res);
          });

    });

    test("6. Get Document Offline docIdPutOnline", () {

      print("3.6");
      var wrapper = expectAsync1((res) {


        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, docIdPutOnline);
        expect(res.payload.name, "Online - Updated");

      });

      sporran3.online = false;
      sporran3.get(docIdPutOnline)..then((res) {

            wrapper(res);
          });

    });

    test("7. Get Document Offline docIdPutOffline", () {

      print("3.7");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, docIdPutOffline);
        expect(res.payload.name, "Offline");
        expect(res.rev, isNull);

      });

      sporran3.online = false;
      sporran3.get(docIdPutOffline)..then((res) {
            wrapper(res);
          });


    });

    test("8. Get Document Offline Not Exist", () {

      print("3.8");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, "Billy");
        expect(res.rev, isNull);
        expect(res.payload, isNull);

      });

      sporran3.online = false;
      offlineDoc.name = "Offline";
      sporran3.get("Billy")..then((res) {
            wrapper(res);
          });


    });

    test("9. Get Document Online docIdPutOnline", () {

      print("3.9");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.payload.name, "Online - Updated");
        expect(res.localResponse, isFalse);
        expect(res.id, docIdPutOnline);
        onlineDocRev = res.rev;

      });

      sporran3.online = true;
      sporran3.get(docIdPutOnline)..then((res) {
            wrapper(res);
          });


    });


    test("10. Delete Document Offline", () {

      print("3.10");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isTrue);
        expect(res.operation, Sporran.DELETE);
        expect(res.id, docIdPutOffline);
        expect(res.payload, isNull);
        expect(res.rev, isNull);
        expect(sporran3.pendingDeleteSize, 1);

      });

      sporran3.online = false;
      sporran3.delete(docIdPutOffline)..then((res) {
            wrapper(res);
          });

    });


    test("11. Delete Document Online", () {

      print("3.11");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isFalse);
        expect(res.operation, Sporran.DELETE);
        expect(res.id, docIdPutOnline);
        expect(res.payload, isNotNull);
        expect(res.rev, anything);

      });

      sporran3.online = true;
      sporran3.delete(docIdPutOnline, onlineDocRev)..then((res) {
            wrapper(res);
          });


    });

    test("12. Get Document Online Not Exist", () {

      print("3.12");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isFalse);
        expect(res.id, "Billy");

      });

      sporran3.get("Billy")..then((res) {
            wrapper(res);
          });


    });

    test("13. Delete Document Not Exist", () {

      print("3.13");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.DELETE);
        expect(res.id, "Billy");
        expect(res.payload, isNull);
        expect(res.rev, isNull);

      });

      sporran3.online = false;
      sporran3.delete("Billy")..then((res) {
            wrapper(res);
          });


    });

    test("14. Group Pause", () {

      print("3.14");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

  });

  /* Group 4 - Sporran attachment put/get tests */
  group("4. Attachment Put/Get/Delete Tests - ", () {

    Sporran sporran4;

    String docIdPutOnline = "putOnlineg4";
    String docIdPutOffline = "putOfflineg4";
    JsonObject onlineDoc = new JsonObject();
    JsonObject offlineDoc = new JsonObject();
    String onlineDocRev;

    String attachmentPayload = 'iVBORw0KGgoAAAANSUhEUgAAABwAAAASCAMAAAB/2U7WAAAABl' + 'BMVEUAAAD///+l2Z/dAAAASUlEQVR4XqWQUQoAIAxC2/0vXZDr' + 'EX4IJTRkb7lobNUStXsB0jIXIAMSsQnWlsV+wULF4Avk9fLq2r' + '8a5HSE35Q3eO2XP1A1wQkZSgETvDtKdQAAAABJRU5ErkJggg==';


    test("1. Create and Open Sporran", () {

      print("4.1");
      var wrapper = expectAsync0(() {

        expect(sporran4.dbName, databaseName);
        expect(sporran4.lawnIsOpen, isTrue);

      });

      sporran4 = new Sporran(initialiser);

      sporran4.autoSync = false;
      sporran4.onReady.first.then((e) => wrapper());

    });

    test("2. Put Document Online docIdPutOnline", () {

      print("4.2");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT);
        expect(res.id, docIdPutOnline);
        expect(res.localResponse, isFalse);
        expect(res.payload.name, "Online");
        expect(res.rev, anything);
        onlineDocRev = res.rev;


      });

      sporran4.online = true;
      onlineDoc.name = "Online";
      sporran4.put(docIdPutOnline, onlineDoc)..then((res) {
            wrapper(res);
          });


    });

    test("3. Put Document Offline docIdPutOffline", () {

      print("4.3");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT);
        expect(res.id, docIdPutOffline);
        expect(res.localResponse, isTrue);
        expect(res.payload.name, "Offline");

      });

      sporran4.online = false;
      offlineDoc.name = "Offline";
      sporran4.put(docIdPutOffline, offlineDoc)..then((res) {
            wrapper(res);
          });


    });

    test("4. Create Attachment Online docIdPutOnline", () {

      print("4.4");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT_ATTACHMENT);
        expect(res.id, docIdPutOnline);
        expect(res.localResponse, isFalse);
        expect(res.rev, anything);
        onlineDocRev = res.rev;
        expect(res.payload.attachmentName, "onlineAttachment");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran4.online = true;
      JsonObject attachment = new JsonObject();
      attachment.attachmentName = "onlineAttachment";
      attachment.rev = onlineDocRev;
      attachment.contentType = 'image/png';
      attachment.payload = attachmentPayload;
      sporran4.putAttachment(docIdPutOnline, attachment)..then((res) {
            wrapper(res);
          });


    });

    test("5. Create Attachment Offline docIdPutOffline", () {

      print("4.5");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT_ATTACHMENT);
        expect(res.id, docIdPutOffline);
        expect(res.localResponse, isTrue);
        expect(res.rev, isNull);
        expect(res.payload.attachmentName, "offlineAttachment");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran4.online = false;
      JsonObject attachment = new JsonObject();
      attachment.attachmentName = "offlineAttachment";
      attachment.rev = onlineDocRev;
      attachment.contentType = 'image/png';
      attachment.payload = attachmentPayload;
      sporran4.putAttachment(docIdPutOffline, attachment)..then((res) {
            wrapper(res);
          });


    });

    test("6. Get Attachment Online docIdPutOnline", () {

      print("4.6");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET_ATTACHMENT);
        expect(res.id, docIdPutOnline);
        expect(res.localResponse, isFalse);
        expect(res.rev, anything);
        expect(res.payload.attachmentName, "onlineAttachment");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran4.online = true;
      sporran4.getAttachment(docIdPutOnline, "onlineAttachment")..then((res) {
            wrapper(res);
          });


    });

    test("7. Get Attachment Offline docIdPutOffline", () {

      print("4.7");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET_ATTACHMENT);
        expect(res.id, docIdPutOffline);
        expect(res.localResponse, isTrue);
        expect(res.rev, isNull);
        expect(res.payload.attachmentName, "offlineAttachment");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran4.online = false;
      sporran4.getAttachment(docIdPutOffline, "offlineAttachment")..then((res) {
            wrapper(res);
          });


    });

    test("8. Get Document Online docIdPutOnline", () {

      print("4.8");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.id, docIdPutOnline);
        expect(res.localResponse, isFalse);
        expect(res.rev, onlineDocRev);
        List attachments = WiltUserUtils.getAttachments(res.payload);
        expect(attachments.length, 1);

      });

      sporran4.online = true;
      sporran4.get(docIdPutOnline, onlineDocRev)..then((res) {
            wrapper(res);
          });



    });

    test("9. Delete Attachment Online docIdPutOnline", () {

      print("4.9");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.DELETE_ATTACHMENT);
        expect(res.id, docIdPutOnline);
        expect(res.localResponse, isFalse);
        onlineDocRev = res.rev;
        expect(res.rev, anything);


      });

      sporran4.online = true;
      sporran4.deleteAttachment(docIdPutOnline, "onlineAttachment", onlineDocRev)..then((res) {
            wrapper(res);
          });

    });

    test("10. Delete Document Online docIdPutOnline", () {

      print("4.10");
      var wrapper = expectAsync1((res) {

      });

      /* Tidy up only, tested in group 3 */
      sporran4.delete(docIdPutOnline, onlineDocRev)..then((res) {
            wrapper(res);
          });


    });


    test("11. Delete Attachment Offline docIdPutOffline", () {

      print("4.11");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.DELETE_ATTACHMENT);
        expect(res.id, docIdPutOffline);
        expect(res.localResponse, isTrue);
        expect(res.rev, isNull);
        expect(res.payload, isNull);


      });

      sporran4.online = false;
      sporran4.deleteAttachment(docIdPutOffline, "offlineAttachment", null)..then((res) {
            wrapper(res);
          });

    });

    test("12. Delete Attachment Not Exist", () {

      print("4.12");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.DELETE_ATTACHMENT);
        expect(res.id, docIdPutOffline);
        expect(res.localResponse, isTrue);
        expect(res.rev, isNull);
        expect(res.payload, isNull);


      });

      sporran4.online = false;
      sporran4.deleteAttachment(docIdPutOffline, "Billy", null)..then((res) {
            wrapper(res);
          });

    });

    /*test("13. Group Pause", () {

      print("4.13");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });*/

  });

  /* Group 5 - Sporran Bulk Documents tests */
  group("5. Bulk Document Tests - ", () {

    Sporran sporran5;
    String docid1rev;
    String docid2rev;
    String docid3rev;

    test("1. Create and Open Sporran", () {

      print("5.1");
      var wrapper = expectAsync0(() {

        expect(sporran5.dbName, databaseName);
        expect(sporran5.lawnIsOpen, isTrue);

      });

      sporran5 = new Sporran(initialiser);

      sporran5.autoSync = false;
      sporran5.onReady.first.then((e) => wrapper());

    });

    test("2. Bulk Insert Documents Online", () {

      print("5.2");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isFalse);
        expect(res.operation, Sporran.BULK_CREATE);
        expect(res.id, isNull);
        expect(res.payload, isNotNull);
        expect(res.rev, isNotNull);
        expect(res.rev[0].rev, anything);
        docid1rev = res.rev[0].rev;
        expect(res.rev[1].rev, anything);
        docid2rev = res.rev[1].rev;
        expect(res.rev[2].rev, anything);
        docid3rev = res.rev[2].rev;
        JsonObject doc3 = res.payload['docid3'];
        expect(doc3.title, "Document 3");
        expect(doc3.version, 3);
        expect(doc3.attribute, "Doc 3 attribute");


      });

      JsonObject document1 = new JsonObject();
      document1.title = "Document 1";
      document1.version = 1;
      document1.attribute = "Doc 1 attribute";

      JsonObject document2 = new JsonObject();
      document2.title = "Document 2";
      document2.version = 2;
      document2.attribute = "Doc 2 attribute";

      JsonObject document3 = new JsonObject();
      document3.title = "Document 3";
      document3.version = 3;
      document3.attribute = "Doc 3 attribute";

      Map docs = new Map<String, JsonObject>();
      docs['docid1'] = document1;
      docs['docid2'] = document2;
      docs['docid3'] = document3;

      sporran5.bulkCreate(docs)..then((res) {
            wrapper(res);
          });


    });

    test("3. Bulk Insert Documents Offline", () {

      print("5.3");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isTrue);
        expect(res.operation, Sporran.BULK_CREATE);
        expect(res.id, isNull);
        expect(res.payload, isNotNull);
        expect(res.rev, isNull);
        JsonObject doc3 = res.payload['docid3offline'];
        expect(doc3.title, "Document 3");
        expect(doc3.version, 3);
        expect(doc3.attribute, "Doc 3 attribute");


      });

      JsonObject document1 = new JsonObject();
      document1.title = "Document 1";
      document1.version = 1;
      document1.attribute = "Doc 1 attribute";

      JsonObject document2 = new JsonObject();
      document2.title = "Document 2";
      document2.version = 2;
      document2.attribute = "Doc 2 attribute";

      JsonObject document3 = new JsonObject();
      document3.title = "Document 3";
      document3.version = 3;
      document3.attribute = "Doc 3 attribute";

      Map docs = new Map<String, JsonObject>();
      docs['docid1offline'] = document1;
      docs['docid2offline'] = document2;
      docs['docid3offline'] = document3;

      sporran5.online = false;
      sporran5.bulkCreate(docs)..then((res) {
            wrapper(res);
          });


    });

    test("4. Get All Docs Online", () {

      print("5.4");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isFalse);
        expect(res.operation, Sporran.GET_ALL_DOCS);
        expect(res.id, isNull);
        expect(res.rev, isNull);
        expect(res.payload, isNotNull);
        JsonObject successResponse = res.payload;
        expect(successResponse.total_rows, equals(3));
        expect(successResponse.rows[0].id, equals('docid1'));
        expect(successResponse.rows[1].id, equals('docid2'));
        expect(successResponse.rows[2].id, equals('docid3'));

      });

      sporran5.online = true;
      sporran5.getAllDocs(includeDocs: true)..then((res) {
            wrapper(res);
          });


    });

    test("5. Get All Docs Offline", () {

      print("5.5");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isTrue);
        expect(res.operation, Sporran.GET_ALL_DOCS);
        expect(res.id, isNull);
        expect(res.rev, isNull);
        expect(res.payload, isNotNull);
        expect(res.payload.length, 6);
        expect(res.payload['docid1'].payload.title, "Document 1");
        expect(res.payload['docid2'].payload.title, "Document 2");
        expect(res.payload['docid3'].payload.title, "Document 3");
        expect(res.payload['docid1offline'].payload.title, "Document 1");
        expect(res.payload['docid2offline'].payload.title, "Document 2");
        expect(res.payload['docid3offline'].payload.title, "Document 3");

      });

      sporran5.online = false;
      List keys = ['docid1offline', 'docid2offline', 'docid3offline', 'docid1', 'docid2', 'docid3'];

      sporran5.getAllDocs(keys: keys)..then((res) {
            wrapper(res);
          });


    });

    test("6. Get Database Info Offline", () {

      print("5.6");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isTrue);
        expect(res.operation, Sporran.DB_INFO);
        expect(res.id, isNull);
        expect(res.rev, isNull);
        expect(res.payload, isNotNull);
        expect(res.payload.length, 6);
        expect(res.payload.contains('docid1'), isTrue);
        expect(res.payload.contains('docid2'), isTrue);
        expect(res.payload.contains('docid3'), isTrue);
        expect(res.payload.contains('docid1offline'), isTrue);
        expect(res.payload.contains('docid2offline'), isTrue);
        expect(res.payload.contains('docid3offline'), isTrue);

      });

      sporran5.getDatabaseInfo()..then((res) {
            wrapper(res);
          });

    });

    test("7. Get Database Info Online", () {

      print("5.7");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.localResponse, isFalse);
        expect(res.operation, Sporran.DB_INFO);
        expect(res.id, isNull);
        expect(res.rev, isNull);
        expect(res.payload, isNotNull);
        expect(res.payload.doc_count, 3);
        expect(res.payload.db_name, databaseName);

      });

      sporran5.online = true;
      sporran5.getDatabaseInfo()..then((res) {
            wrapper(res);
          });


    });

    test("8. Tidy Up All Docs Online", () {

      print("5.8");
      var wrapper = expectAsync1((res) {}, count: 3);

      sporran5.delete('docid1', docid1rev)..then((res) {
            wrapper(res);
          });
      sporran5.delete('docid2', docid2rev)..then((res) {
            wrapper(res);
          });
      sporran5.delete('docid3', docid3rev)..then((res) {
            wrapper(res);
          });

    });

    /*test("9. Group Pause", () {

      print("5.9");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });*/

  });

  /* Group 6 - Sporran Change notification tests */
  group("6. Change notification Tests Documents - ", () {

    Sporran sporran6;

    /* We use Wilt here to change the CouchDb database independently
     * of Sporran, these change will be picked up in change notifications.
     */

    /* Create our Wilt */
    Wilt wilting = new WiltBrowserClient(hostName, port, scheme);

    /* Login if we are using authentication */
    if (userName != null) {

      wilting.login(userName, userPassword);
    }

    wilting.db = databaseName;
    String docId1Rev;
    String docId2Rev;
    String docId3Rev;

    test("1. Create and Open Sporran", () {

      print("6.1");
      var wrapper = expectAsync0(() {

        expect(sporran6.dbName, databaseName);
        expect(sporran6.lawnIsOpen, isTrue);

      });

      initialiser.manualNotificationControl = false;
      sporran6 = new Sporran(initialiser);

      sporran6.autoSync = false;
      sporran6.onReady.first.then((e) => wrapper());

    });

    test("2. Wilt - Bulk Insert Supplied Keys", () {

      print("6.2");
      var completer = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Bulk Insert Supplied Keys");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse[0].id, equals("MyBulkId1"));
        expect(successResponse[1].id, equals("MyBulkId2"));
        expect(successResponse[2].id, equals("MyBulkId3"));
        docId1Rev = successResponse[0].rev;
        docId2Rev = successResponse[1].rev;
        docId3Rev = successResponse[2].rev;

      });

      JsonObject document1 = new JsonObject();
      document1.title = "Document 1";
      document1.version = 1;
      document1.attribute = "Doc 1 attribute";
      String doc1 = WiltUserUtils.addDocumentId(document1, "MyBulkId1");
      JsonObject document2 = new JsonObject();
      document2.title = "Document 2";
      document2.version = 2;
      document2.attribute = "Doc 2 attribute";
      String doc2 = WiltUserUtils.addDocumentId(document2, "MyBulkId2");
      JsonObject document3 = new JsonObject();
      document3.title = "Document 3";
      document3.version = 3;
      document3.attribute = "Doc 3 attribute";
      String doc3 = WiltUserUtils.addDocumentId(document3, "MyBulkId3");
      List docList = new List<String>();
      docList.add(doc1);
      docList.add(doc2);
      docList.add(doc3);
      String docs = WiltUserUtils.createBulkInsertString(docList);
      wilting.bulkString(docs)..then((res) {
            completer(res);
          });

    });

    /* Pause a little for the notifications to come through */
    test("3. Notification Pause", () {

      print("6.4");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

    /* Go offline and get our created documents, from local storage */
    test("4. Get Document Offline MyBulkId1", () {

      print("6.4");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, "MyBulkId1");
        expect(res.payload.title, "Document 1");
        expect(res.payload.version, 1);
        expect(res.payload.attribute, "Doc 1 attribute");

      });

      sporran6.online = false;
      sporran6.get("MyBulkId1")..then((res) {
            wrapper(res);
          });


    });

    test("5. Get Document Offline MyBulkId2", () {

      print("6.5");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, "MyBulkId2");
        expect(res.payload.title, "Document 2");
        expect(res.payload.version, 2);
        expect(res.payload.attribute, "Doc 2 attribute");

      });

      sporran6.get("MyBulkId2")..then((res) {
            wrapper(res);
          });

    });

    test("6. Get Document Offline MyBulkId3", () {

      print("6.6");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);
        expect(res.id, "MyBulkId3");
        expect(res.payload.title, "Document 3");
        expect(res.payload.version, 3);
        expect(res.payload.attribute, "Doc 3 attribute");

      });

      sporran6.get("MyBulkId3")..then((res) {
            wrapper(res);
          });

    });

    test("7. Wilt - Delete Document MyBulkId1", () {

      print("6.7");
      var wrapper = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Delete Document MyBulkId1");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse.id, "MyBulkId1");

      });

      wilting.deleteDocument("MyBulkId1", docId1Rev)..then((res) {
            wrapper(res);
          });

    });

    test("8. Wilt - Delete Document MyBulkId2", () {

      print("6.8");
      var wrapper = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Delete Document MyBulkId2");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse.id, "MyBulkId2");

      });

      wilting.deleteDocument("MyBulkId2", docId2Rev)..then((res) {
            wrapper(res);
          });

    });

    test("9. Wilt - Delete Document MyBulkId3", () {

      print("6.9");
      var wrapper = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Delete Document MyBulkId3");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse.id, "MyBulkId3");

      });

      wilting.deleteDocument("MyBulkId3", docId3Rev)..then((res) {
            wrapper(res);
          });

    });

    /* Pause a little for the notifications to come through */
    test("10. Notification Pause", () {

      print("6.10");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

    /* Go offline and get our created documents, from local storage */
    test("11. Get Document Offline Deleted MyBulkId1", () {

      print("6.11");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);

      });

      sporran6.online = false;
      sporran6.get("MyBulkId1")..then((res) {
            wrapper(res);
          });


    });

    test("12. Get Document Offline Deleted MyBulkId2", () {

      print("6.12");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);

      });

      sporran6.get("MyBulkId2")..then((res) {
            wrapper(res);
          });

    });

    test("13. Get Document Offline Deleted MyBulkId3", () {

      print("6.13");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET);
        expect(res.localResponse, isTrue);

      });

      sporran6.get("MyBulkId3")..then((res) {
            wrapper(res);
          });

    });

    test("14. Group Pause", () {

      print("6.14");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

  });

  /* Group 7 - Sporran Change notification tests */
  group("7. Change notification Tests Attachments - ", () {

    Sporran sporran7;

    /* We use Wilt here to change the CouchDb database independently
     * of Sporran, these change will be picked up in change notifications.
     */

    /* Create our Wilt */
    Wilt wilting = new WiltBrowserClient(hostName, port, scheme);

    /* Login if we are using authentication */
    if (userName != null) {

      wilting.login(userName, userPassword);
    }

    wilting.db = databaseName;
    String docId1Rev;
    String docId2Rev;
    String docId3Rev;
    String attachmentPayload = 'iVBORw0KGgoAAAANSUhEUgAAABwAAAASCAMAAAB/2U7WAAAABl' + 'BMVEUAAAD///+l2Z/dAAAASUlEQVR4XqWQUQoAIAxC2/0vXZDr' + 'EX4IJTRkb7lobNUStXsB0jIXIAMSsQnWlsV+wULF4Avk9fLq2r' + '8a5HSE35Q3eO2XP1A1wQkZSgETvDtKdQAAAABJRU5ErkJggg==';

    test("1. Create and Open Sporran", () {

      print("7.1");
      var wrapper = expectAsync0(() {

        expect(sporran7.dbName, databaseName);
        expect(sporran7.lawnIsOpen, isTrue);

      });

      initialiser.manualNotificationControl = false;
      sporran7 = new Sporran(initialiser);

      sporran7.autoSync = false;
      sporran7.onReady.first.then((e) => wrapper());

    });

    test("2. Wilt - Bulk Insert Supplied Keys", () {

      print("7.2");
      var completer = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Bulk Insert Supplied Keys");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse[0].id, equals("MyBulkId1"));
        expect(successResponse[1].id, equals("MyBulkId2"));
        expect(successResponse[2].id, equals("MyBulkId3"));
        docId1Rev = successResponse[0].rev;
        docId2Rev = successResponse[1].rev;
        docId3Rev = successResponse[2].rev;

      });

      JsonObject document1 = new JsonObject();
      document1.title = "Document 1";
      document1.version = 1;
      document1.attribute = "Doc 1 attribute";
      String doc1 = WiltUserUtils.addDocumentId(document1, "MyBulkId1");
      JsonObject document2 = new JsonObject();
      document2.title = "Document 2";
      document2.version = 2;
      document2.attribute = "Doc 2 attribute";
      String doc2 = WiltUserUtils.addDocumentId(document2, "MyBulkId2");
      JsonObject document3 = new JsonObject();
      document3.title = "Document 3";
      document3.version = 3;
      document3.attribute = "Doc 3 attribute";
      String doc3 = WiltUserUtils.addDocumentId(document3, "MyBulkId3");
      List docList = new List<String>();
      docList.add(doc1);
      docList.add(doc2);
      docList.add(doc3);
      String docs = WiltUserUtils.createBulkInsertString(docList);
      wilting.bulkString(docs)..then((res) {
            completer(res);
          });

    });

    /* Pause a little for the notifications to come through */
    test("3. Notification Pause", () {

      print("7.3");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

    test("4. Create Attachment Online MyBulkId1 Attachment 1", () {

      print("7.4");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT_ATTACHMENT);
        expect(res.id, "MyBulkId1");
        expect(res.localResponse, isFalse);
        expect(res.rev, anything);
        docId1Rev = res.rev;
        expect(res.payload.attachmentName, "AttachmentName1");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran7.online = true;
      JsonObject attachment = new JsonObject();
      attachment.attachmentName = "AttachmentName1";
      attachment.rev = docId1Rev;
      attachment.contentType = 'image/png';
      attachment.payload = attachmentPayload;
      sporran7.putAttachment("MyBulkId1", attachment)..then((res) {
            wrapper(res);
          });


    });

    test("5. Create Attachment Online MyBulkId1 Attachment 2", () {

      print("7.5");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isTrue);
        expect(res.operation, Sporran.PUT_ATTACHMENT);
        expect(res.id, "MyBulkId1");
        expect(res.localResponse, isFalse);
        expect(res.rev, anything);
        docId1Rev = res.rev;
        expect(res.payload.attachmentName, "AttachmentName2");
        expect(res.payload.contentType, 'image/png');
        expect(res.payload.payload, attachmentPayload);

      });

      sporran7.online = true;
      JsonObject attachment = new JsonObject();
      attachment.attachmentName = "AttachmentName2";
      attachment.rev = docId1Rev;
      attachment.contentType = 'image/png';
      attachment.payload = attachmentPayload;
      sporran7.putAttachment("MyBulkId1", attachment)..then((res) {
            wrapper(res);
          });


    });

    /* Pause a little for the notifications to come through */
    test("6. Notification Pause", () {

      print("7.6");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

    test("7. Delete Attachment Online MyBulkId1 Attachment 1", () {

      print("7.7");
      var completer = expectAsync1((res) {

        try {
          expect(res.error, isFalse);
        } catch (e) {

          logMessage("WILT::Delete Attachment Failed");
          JsonObject errorResponse = res.jsonCouchResponse;
          String errorText = errorResponse.error;
          logMessage("WILT::Error is $errorText");
          String reasonText = errorResponse.reason;
          logMessage("WILT::Reason is $reasonText");
          int statusCode = res.errorCode;
          logMessage("WILT::Status code is $statusCode");
          return;
        }

        JsonObject successResponse = res.jsonCouchResponse;
        expect(successResponse.ok, isTrue);
        docId1Rev = successResponse.rev;

      });

      wilting.db = databaseName;
      wilting.deleteAttachment('MyBulkId1', 'AttachmentName1', docId1Rev)..then((res) {
            completer(res);
          });

    });

    test("8. Notification Pause", () {

      print("7.8");
      var wrapper = expectAsync0(() {});

      Timer pause = new Timer(new Duration(seconds: 3), wrapper);

    });

    test("9. Get Attachment Offline MyBulkId1 AttachmentName1", () {

      print("7.9");
      var wrapper = expectAsync1((res) {

        expect(res.ok, isFalse);
        expect(res.operation, Sporran.GET_ATTACHMENT);
        expect(res.localResponse, isTrue);

      });

      sporran7.online = false;
      sporran7.getAttachment('MyBulkId1', 'AttachmentName1')..then((res) {
            wrapper(res);
          });


    });


  });

}