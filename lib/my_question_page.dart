import 'package:flutter/material.dart';
import 'config.dart';
import 'package:dio/dio.dart';
import 'my_question.dart';

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
        onRefresh: () {
          try {
            return getMyQuestion(campus_id, passwd).then((data) {
              print(data);
              setState(() {
                _questions = data;
              });
            });
          } on DioError catch (e) {
            final snackBar = SnackBar(
              content: Text(e.toString()),
              duration: Duration(days: 1),
              action: SnackBarAction(
                  label: 'Reload',
                  onPressed: () => WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _refreshIndicatorKey.currentState.show())),
            );
            widget.scaffoldKey.currentState.showSnackBar(snackBar);
            return null;
          }
        });
  }
}
