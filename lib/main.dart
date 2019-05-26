import 'dart:io';
import 'package:flutter/material.dart';
import 'my_questions.dart' as myQPage;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Maintenance'),
        backgroundColor: Colors.deepOrange,
        bottom: TabBar(
          tabs: <Tab>[
            Tab(
              text: 'My question',
            ),
            Tab(
              text: 'New complaint',
            ),
            Tab(
              text: 'Q&A',
            )
          ],
          controller: controller,
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          myQPage.MyQuestionsPage(_scaffoldKey),
          Center(
            child: Text("Hello world again!"),
          ),
          Center(
            child: Text("Hello world again again!"),
          )
        ],
      ),
    );
  }
}