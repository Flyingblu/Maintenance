import 'dart:io';
import 'package:flutter/material.dart';
import 'cookie_manager.dart';
import 'config.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

class Question {
  String id;
  String time;
  String title;
  String answer;

  @override
  String toString() {
    return '''ID: ${this.id}
      Time: ${this.time}
      Title: ${this.title}
      Answer: ${this.answer}
      ''';
  }
}

formSender(Response<dynamic> formPage) {
  var formData = parse(formPage.data);
  var token = formData
      .querySelector('[name="__RequestVerificationToken"]')
      .attributes['value'];
  var gender = formData.querySelector('[name="Gender"]').attributes['value'];
  print(gender);
}

removeSpace(String str) {
  int start, end;
  for (int i = 0; i < str.length; ++i) {
    if (str.codeUnitAt(i) != 10 && str.codeUnitAt(i) != 32) {
      start = i;
      break;
    }
  }
  for (int i = str.length - 1; i >= 0; --i) {
    if (str.codeUnitAt(i) != 10 && str.codeUnitAt(i) != 32) {
      end = i + 1;
      break;
    }
  }
  if (start == null || end == null) {
    return '';
  }
  return str.substring(start, end);
}

List<Question> myQuestion(Response<dynamic> qPage) {
  var myQData =
      parse(qPage.data).querySelector('.table-QA').querySelectorAll('td');
  var qList = List<Question>(myQData.length ~/ 2);
  for (int i = 0; i < myQData.length; ++i) {
    int index;
    if (i % 2 == 0) {
      index = i ~/ 2;
      qList[index] = new Question();
      qList[index].id = removeSpace(myQData[i].nodes[0].text);
      qList[index].title = removeSpace(myQData[i].nodes[1].text);
      qList[index].time = removeSpace(myQData[i].nodes[2].text);
    } else {
      index = (i - 1) ~/ 2;
      var ans = List();
      myQData[i].children.forEach((e) {
        ans.add(e.text);
      });
      qList[index].answer = ans.join('\n');
    }
  }
  return qList;
}

class MyQuestionsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  MyQuestionsPage(this.scaffoldKey);

  @override
  _MyQuestionsPageState createState() => _MyQuestionsPageState();
}

class _MyQuestionsPageState extends State<MyQuestionsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Question> _questions;

  Future<List<Question>> _getData() async {
    var checkError = (Response r) {
      if (r.data is DioError) {
        final snackBar = SnackBar(
          content: Text(r.data.toString()),
          duration: Duration(days: 1),
          action: SnackBarAction(
              label: 'Reload',
              onPressed: () => WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _refreshIndicatorKey.currentState.show())),
        );
        widget.scaffoldKey.currentState.showSnackBar(snackBar);
        return true;
      }
      return false;
    };

    var dio = new Dio();
    dio.interceptors.add(NBCookieManager(CookieJar()));
    try {
      var loginPage =
          await dio.get('https://app.xmu.edu.my/Maintenance/Account/Login');
      if (checkError(loginPage)) {
        return null;
      }
      var loginData = parse(loginPage.data);
      var token = loginData
          .querySelector('[name="__RequestVerificationToken"]')
          .attributes['value'];
      await dio.post('https://app.xmu.edu.my/Maintenance/Account/Login',
          data: {
            "__RequestVerificationToken": token,
            "CampusID": campus_id,
            "Password": passwd
          },
          options: Options(
              contentType:
                  ContentType.parse("application/x-www-form-urlencoded"),
              followRedirects: true));
      var myQPage =
          await dio.get('https://app.xmu.edu.my/Maintenance/Reader/Ask');
      if (checkError(myQPage)) {
        return null;
      }
      return myQuestion(myQPage);
    } on DioError catch (e) {
      if (e.response.statusCode != 302) {
        final snackBar = SnackBar(
          content: Text(e.error.toString()),
          duration: Duration(days: 1),
          action: SnackBarAction(
              label: 'Reload',
              onPressed: () => WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _refreshIndicatorKey.currentState.show())),
        );
        widget.scaffoldKey.currentState.showSnackBar(snackBar);
        return null;
      }
      var myQPage =
          await dio.get('https://app.xmu.edu.my/Maintenance/Reader/Ask');
      if (checkError(myQPage)) {
        return null;
      }
      return myQuestion(myQPage);
    }
  }

  _showDetail(Question q, BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    q.title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    q.time,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  q.id,
                  style: TextStyle(fontSize: 14),
                ),
                Divider(height: 15),
                Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      q.answer,
                      style: TextStyle(fontSize: 16),
                    )),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    var cards = List<Card>();
    if (_questions != null) {
      _questions.forEach((q) {
        cards.add(Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(q.title),
              subtitle: Text(q.time),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                      child: const Text('Details'),
                      onPressed: () => _showDetail(q, context))
                ],
              ),
            )
          ]),
        ));
      });
    }
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        child: Padding(
          padding: EdgeInsets.only(left: 4, right: 4, top: 10),
          child: ListView(
            children: cards,
          ),
        ),
        onRefresh: () => _getData().then((data) {
              setState(() {
                _questions = data;
              });
            }));
  }
}
