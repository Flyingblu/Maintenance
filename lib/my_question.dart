import 'dart:io';

import 'cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'config.dart';

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
  Form();
  Form.fromList(List<List<String>> data)
      : roomUsage = data[0],
        category = data[1],
        recurringProblem = data[2],
        blockID = data[3],
        wingID = data[4];

  List<String> roomUsage;
  List<String> category;
  List<String> recurringProblem;
  List<String> blockID;
  List<String> wingID;
  @override
  String toString() {
    return '''roomUsage: ${this.roomUsage}
      category: ${this.category}
      recurringProblem: ${this.recurringProblem}
      blockID: ${this.blockID}
      wingID: ${this.wingID}
      ''';
  }
}

class Maintenance {
  final String _campusID;
  final String _passwd;
  String _name;
  String _email;
  String _formToken;
  String _gender;

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
      rethrow;
    }
  }

  Future<Form> getForm() async {
    var dio = await _login();
    var askPage =
        await dio.get('https://app.xmu.edu.my/Maintenance/Reader/Ask/Create');
    if (askPage.data is DioError) {
      throw askPage.data;
    }
    var page = parse(askPage.data);
    var data = [
      '#RoomUsage',
      '#Category',
      '#RecurringProblem',
      '#Block',
      '#Wing'
    ].map((d) => page
        .querySelector(d)
        .querySelectorAll('option')
        .map((e) => e.text)
        .toList()).toList();
    
    var form = Form.fromList(data);
    this._gender = page.querySelector('[name="Gender"]').attributes['value'];
    this._formToken = page.querySelector('[name="__RequestVerificationToken"]').attributes['value'];
    this._name = page.querySelector('[name="Name"]').attributes['value'];
    print('gender: ${this._gender}\ntoken: ${this._formToken}\nname: ${this._name}');
    return form;
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
        rethrow;
      }
    }
    return dio;
  }

  formSender(Map<String, String> formData) async {
    var dio = new Dio();
    try {
      await dio.post('https://app.xmu.edu.my/Maintenance/Reader/Ask/Create',
            data: {
              '__RequestVerificationToken': this._formToken,
              'Gender': this._gender,
              'RoomUsage': formData['roomUsage'], 
              'Category': formData['category'], 
              'Block': formData['blockID'], 
              'Wing': formData['wingID'], 
              'RoomNo': formData['roomNo'],
              'RecurringProblem': formData['recurringProblem'],
              'Description': formData['description'], 
              'CampusID': this._campusID,
              'Name': this._name,
              'Email': this._email,
              'Telephone': formData['phone'], 
              'Agree': true
            },
            options: Options(
                contentType:
                    ContentType.parse("application/x-www-form-urlencoded"),
                followRedirects: true));
    } on DioError catch (e) {
      if (e.response == null || e.response.statusCode != 302) {
        rethrow;
      }
    }
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

void main(List<String> args) async {
  var maintenance = Maintenance(campus_id, passwd);
  print(await maintenance.getForm());
}
