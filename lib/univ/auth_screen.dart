import 'dart:math';

import 'package:deliverpros/constants.dart';
import 'package:deliverpros/screens/product_overview_screen.dart';
import 'package:deliverpros/univ/user.dart';
import 'package:deliverpros/univ/user_connection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = 'auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  btn_color,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: btn_color,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'PostMan',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  var user = User(
    name: '',
    surname: '',
    phone: '',
    email: '',
    password: '',
  );
  var _isLoading = false;
  FocusNode _nameNode = FocusNode();
  FocusNode _surnameNode = FocusNode();
  FocusNode _phoneNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  FocusNode _passwordConfirmNode = FocusNode();
  final _passwordController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      Provider.of<UserConnection>(context,listen: false).login(user.email,user.password).then((onValue){
        print("on response $onValue");
        if(onValue == 'no_user'){

          setState(() {
            _isLoading = false;
            user = User();
            _switchAuthMode();
          });
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('You don\'t have account yet SIGNUP please',textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
          ));
        }else if(onValue == 'success'){
          setState(() {
            _isLoading = false;
          });
          //print(onValue);
          Navigator.of(context).pushReplacementNamed(ProductOverviewScreen.routeName);
        }else if(onValue == 'password'){
          setState(() {
            _isLoading = false;
            user = User();
          });
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Wrong password',textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
          ));

        }
      }).catchError((onError){
        setState(() {
          _isLoading = false;
        });
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('No internet connection', style: TextStyle(color: Colors.white),),
        ));
      });
      // Log user in
    } else {
      Provider.of<UserConnection>(context,listen: false).createUser(user).then((onValue){
        print('response $onValue');
        if(onValue){
          setState(() {
            _isLoading = false;
            _switchAuthMode();
            user = User();
          });
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('User has been created', style: TextStyle(color: Colors.white),),
          ));
        }else {
          setState(() {
            _isLoading = false;
            _switchAuthMode();
            user = User();
          });
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Something went wrong', style: TextStyle(color: Colors.white),),
          ));
        }
      });
      // Sign user up
    }

  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _surnameNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _passwordConfirmNode.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 520 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    focusNode: _nameNode,
                    textInputAction: TextInputAction.next,
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'First Name'),
                    onFieldSubmitted: (_){
                        FocusScope.of(context).requestFocus(_surnameNode);
                    },
                    onSaved: (value) {
                      user = User(
                        name: value,
                        surname: user.surname,
                        phone: user.phone,
                        email: user.email,
                        password: user.password,
                      );
                    },
                    validator: (value){
                      RegExp reg = RegExp(r'^\D*$',caseSensitive: false,
                        multiLine: false,);
                      if(!reg.hasMatch(value)){
                        return 'A-Z letters only';
                      }else
                      if(value.isEmpty){
                        return 'This field is required';
                      }
                      else{
                        return null;
                      }

                    },
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    focusNode: _surnameNode,
                    textInputAction: TextInputAction.next,
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    onFieldSubmitted: (_){
                      FocusScope.of(context).requestFocus(_phoneNode);
                    },
                    onSaved: (value) {
                      user = User(
                        name: user.name,
                        surname: value,
                        phone: user.phone,
                        email: user.email,
                        password: user.password,
                      );
                    },
                    validator: (value){
                      RegExp reg = RegExp(r'^\D*$',caseSensitive: false,
                        multiLine: false,);
                      if(!reg.hasMatch(value)){
                        return 'A-Z letters only';
                      }else
                      if(value.isEmpty){
                        return 'This field is required';
                      }
                      else{
                        return null;
                      }

                    },
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    focusNode: _phoneNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Phone'),
                    onFieldSubmitted: (_){
                      FocusScope.of(context).requestFocus(_emailNode);
                    },
                    onSaved: (value) {
                      user = User(
                        name: user.name,
                        surname: user.surname,
                        phone: value,
                        email: user.email,
                        password: user.password,
                      );
                    },
                    validator: (value){
                      RegExp reg = RegExp(r'^\+\d*$',caseSensitive: false,
                        multiLine: false,);
                      if(!reg.hasMatch(value)){
                        return '1-9 numbers only';
                      }else
                      if(value.isEmpty){
                        return 'This field is required';
                      }
                      else{
                        return null;
                      }

                    },
                  ),
                TextFormField(
                  focusNode: _emailNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).requestFocus(_passwordNode);
                  },
                  validator: (value) {
                    if (value.isEmpty ) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    user = User(
                      name: user.name,
                      surname: user.surname,
                      phone: user.phone,
                      email: value,
                      password: user.password,
                    );
                  },
                ),
                TextFormField(
                  textInputAction:_authMode == AuthMode.Signup? TextInputAction.next:TextInputAction.done,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  focusNode: _passwordNode,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onFieldSubmitted: (_){
                    if(_authMode == AuthMode.Signup)FocusScope.of(context).requestFocus(_passwordConfirmNode);
                  },
                  onSaved: (value) {
                    user = User(
                      name: user.name,
                      surname: user.surname,
                      phone: user.phone,
                      email: user.email,
                      password: value,
                    );
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
