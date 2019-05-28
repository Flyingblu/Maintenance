import 'dart:io';
import 'cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

class Question {
  String id;
  String time;
  String title;
  String answer;
  String roomUsage;
  String category;

  @override
  String toString() {
    return '''ID: ${this.id}
      Time: ${this.time}
      Title: ${this.title}
      Room Usage: ${this.roomUsage}
      Category: ${this.category}
      Answer: ${this.answer}
      ''';
  }
}

class Form {
  List<String> roomUsage;
  List<String> category;
  List<String> recurringProblem;
  List<String> blockID;
  List<String> wingID;
}

class Maintenance {
  final String _campusID;
  final String _passwd;

  Maintenance(this._campusID, this._passwd);

  Future<List<Question>> getMyQuestion() async {
    try {
      var dio = await _login();
      var myQPage =
          await dio.get('https://app.xmu.edu.my/Maintenance/Reader/Ask');
      if (myQPage.data is DioError) {
        throw myQPage.data;
      }
      return _myQuestion(myQPage);
    } catch (e) {
      throw e;
    }
  }

  Future<Form> getForm() async {
    try {
      var dio = await _login();
      var askPage = await dio.get('https://app.xmu.edu.my/Maintenance/Reader/Ask/Create');
      if (askPage.data is DioError) {
        throw askPage.data;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<Dio> _login() async {
    var dio = new Dio();
    dio.interceptors.add(NBCookieManager(CookieJar()));
    try {
      var loginPage =
          await dio.get('https://app.xmu.edu.my/Maintenance/Account/Login');
      if (loginPage.data is DioError) {
        throw loginPage.data;
      }

      var loginData = parse(loginPage.data);
      var token = loginData
          .querySelector('[name="__RequestVerificationToken"]')
          .attributes['value'];
      await dio.post('https://app.xmu.edu.my/Maintenance/Account/Login',
          data: {
            "__RequestVerificationToken": token,
            "CampusID": this._campusID,
            "Password": this._passwd
          },
          options: Options(
              contentType:
                  ContentType.parse("application/x-www-form-urlencoded"),
              followRedirects: true));
    } on DioError catch (e) {
      if (e.response == null || e.response.statusCode != 302) {
        throw e;
      }
    }
    return dio;
  }

  _formSender(Response<dynamic> formPage) {
    var formData = parse(formPage.data);
    var token = formData
        .querySelector('[name="__RequestVerificationToken"]')
        .attributes['value'];
    var gender = formData.querySelector('[name="Gender"]').attributes['value'];
    print(gender);
  }

  _removeSpace(String str) {
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

  List<Question> _myQuestion(Response<dynamic> qPage) {
    var myQData =
        parse(qPage.data).querySelector('.table-QA').querySelectorAll('td');
    var qList = List<Question>(myQData.length ~/ 2);
    int index;
    List<String> title;
    for (int i = 0; i < myQData.length; ++i) {
      if (i % 2 == 0) {
        index = i ~/ 2;
        qList[index] = new Question();
        qList[index].id = _removeSpace(myQData[i].nodes[0].text);
        title = _removeSpace(myQData[i].nodes[1].text).split(' - ');
        qList[index].roomUsage = title[0];
        qList[index].category = title[1];
        qList[index].title = title[2];
        qList[index].time = _removeSpace(myQData[i].nodes[2].text);
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
}
