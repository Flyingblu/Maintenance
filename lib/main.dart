import 'package:flutter/material.dart';
import 'my_question_page.dart' as myQPage;
import 'submit_form_page.dart';
import 'faq_page.dart';
import 'config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage('Maintenance'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  HomePage(this.title);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance'),
        backgroundColor: Colors.deepOrange,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.question_answer),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FaqPage(campus_id, passwd)));
            },
          )
        ],
        bottom: TabBar(
          tabs: <Tab>[
            Tab(
              text: 'New form',
            ),
            Tab(
              text: 'My complaint',
            ),
          ],
          controller: controller,
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          SubmitFormPage(campus_id, passwd),
          myQPage.MyQuestionsPage(campus_id, passwd),
        ],
      ),
    );
  }
}
