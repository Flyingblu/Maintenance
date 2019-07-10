import 'package:flutter/material.dart';
import 'my_question.dart' as myQuestion;

class SubmitFormPage extends StatefulWidget {
  String _campusID, _passwd;
  SubmitFormPage(this._campusID, this._passwd);

  @override
  _SubmitFormPageState createState() => _SubmitFormPageState(this._campusID, this._passwd);
}

class _SubmitFormPageState extends State<SubmitFormPage> {
  myQuestion.Form formData;
  String _campusID, _passwd;
  var _maintenance;
  final _formKey = GlobalKey<FormState>();

  _SubmitFormPageState(this._campusID, this._passwd) {
    _maintenance = myQuestion.Maintenance(_campusID, _passwd);
    _getForm();
  }

  _getForm() {
    _maintenance.getForm().then((form) {
      if (mounted) {
        setState(() => formData = form);
      }
    }).catchError((error) {
      if (mounted) {
        final snackBar = SnackBar(
          content: Text(error.toString()),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _getForm(),
          ),
          duration: Duration(days: 1),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    List<DropdownMenuItem<String>> roomUsageItem = [];
    List<DropdownMenuItem<String>> categoryItem = [];
    List<DropdownMenuItem<String>> blockItem = [];
    List<DropdownMenuItem<String>> wingItem = [];

    formData.roomUsage.forEach((item) =>
        roomUsageItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.category.forEach((item) =>
        categoryItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.blockID.forEach((item) =>
        blockItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.wingID.forEach((item) =>
        wingItem.add(DropdownMenuItem(child: Text(item), value: item)));

    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            FormField<String>(
                builder: (formFieldState) => Column(children: [
                      DropdownButton(
                        value: formFieldState.value,
                        items: roomUsageItem,
                        hint: Text(
                          'Room Usage',
                        ),
                        onChanged: (selectedVal) {
                          formFieldState.didChange(selectedVal);
                          setState(() => formFieldState.validate());
                        },
                      ),
                      formFieldState.hasError
                          ? Text(
                              formFieldState.errorText,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            )
                          : Container()
                    ]),
                validator: (selectedValue) {
                  if (selectedValue == null)
                    return "Please choose an option";
                  else
                    return null;
                },
                onSaved: (selectedValue) =>
                    formData.croomUsage = selectedValue),
            FormField(
              builder: (formFieldState) => Column(children: [
                DropdownButton(
                  value: formFieldState.value,
                  items: categoryItem,
                  hint: Text(
                    'Problem Category',
                  ),
                  onChanged: (selectedVal) {
                    formFieldState.didChange(selectedVal);
                    setState(() => formFieldState.validate());
                  },
                ),
                formFieldState.hasError
                    ? Text(
                        formFieldState.errorText,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      )
                    : Container()
              ]),
              validator: (selectedValue) {
                if (selectedValue == null) {
                  return "Please choose an option";
                } else
                  return null;
              },
              onSaved: (selectedValue) => formData.ccategory = selectedValue,
            ),
            Row(
              children: <Widget>[
                FormField(
                  builder: (formFieldState) => Column(children: [
                    DropdownButton(
                      value: formFieldState.value,
                      items: blockItem,
                      hint: Text(
                        'Block',
                      ),
                      onChanged: (selectedVal) {
                        formFieldState.didChange(selectedVal);
                        setState(() => formFieldState.validate());
                      },
                    ),
                    formFieldState.hasError
                        ? Text(
                            formFieldState.errorText,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          )
                        : Container()
                  ]),
                  validator: (selectedValue) {
                    if (selectedValue == null)
                      return "Please choose an option";
                    else
                      return null;
                  },
                  onSaved: (selectedValue) => formData.cblockID = selectedValue,
                ),
                FormField(
                  builder: (formFieldState) => Column(children: [
                    DropdownButton(
                      value: formFieldState.value,
                      items: wingItem,
                      hint: Text(
                        'Wing',
                      ),
                      onChanged: (selectedVal) {
                        formFieldState.didChange(selectedVal);
                        setState(() => formFieldState.validate());
                      },
                    ),
                    formFieldState.hasError
                        ? Text(
                            formFieldState.errorText,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          )
                        : Container()
                  ]),
                  validator: (selectedValue) {
                    if (selectedValue == null)
                      return "Please choose an option";
                    else
                      return null;
                  },
                  onSaved: (selectedValue) => formData.cwingID = selectedValue,
                )
              ],
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Room Number'),
              validator: (currentValue) {
                if (currentValue.isEmpty)
                  return 'Please fill in room number';
                else
                  return null;
              },
              onSaved: (currentValue) => formData.roomNo = currentValue,
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Description\nUp to 100 characters\n\n'),
              validator: (currentValue) {
                if (currentValue.isEmpty)
                  return 'Please fill in room number';
                else if (currentValue.length > 100)
                  return 'Description should be less than 100 characters';
                else
                  return null;
              },
              onSaved: (currentValue) => formData.description = currentValue,
            ),
            TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Phone Number'),
              keyboardType: TextInputType.number,
              validator: (currentValue) {
                if (currentValue.isEmpty)
                  return 'Please fill in phone number';
                else
                  return null;
              },
              onSaved: (currentValue) => formData.phoneNo = currentValue,
            ),
            CheckboxListTile(
              title: Text('Recurring problem'),
              value: formData.isrecurringProblem,
              onChanged: (checked) =>
                  setState(() => formData.isrecurringProblem = checked),
            ),
            RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _maintenance.formSender(formData).then((r) {
                    if (mounted) {
                      final snackBar = SnackBar(
                        content: Text('Form successfully submitted! '),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  }).catchError((error) {
                    if (mounted) {
                      final snackBar = SnackBar(
                        content: Text(error.toString()),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  });
                }
              },
              child: Text('Submit Form'),
            )
          ],
        ));
  }
}
