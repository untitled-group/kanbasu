import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home.dart';

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _rememberMe = false;

  Widget _buildApiTokenTF(context) {
    final theme = Provider.of<Model>(context).theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'login.label.api_token'.tr(),
          style: TextStyle(
            color: theme.text,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.secondaryText,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: theme.secondaryText,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            obscureText: true,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: theme.background,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.vpn_key_outlined,
                color: theme.background,
              ),
              hintText: 'login.hint.api_token'.tr(),
              hintStyle: TextStyle(
                color: theme.tertiaryText,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointTF(context) {
    final theme = Provider.of<Model>(context).theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'login.label.endpoint'.tr(),
          style: TextStyle(
            color: theme.text,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.secondaryText,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: theme.secondaryText,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            initialValue: 'https://oc.sjtu.edu.cn/api/v1',
            style: TextStyle(
              color: theme.background,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.vpn_lock_outlined,
                color: theme.background,
              ),
              hintText: 'login.hint.endpoint'.tr(),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(context) {
    final theme = Provider.of<Model>(context).theme;
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: theme.tertiaryText),
            child: Checkbox(
              value: _rememberMe,
              checkColor: theme.succeed,
              activeColor: theme.background,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          Text('login.remember_me'.tr(),
              style: TextStyle(
                color: theme.tertiaryText,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              )),
        ],
      ),
    );
  }

  Widget _buildLoginBtn(context) {
    final theme = Provider.of<Model>(context).theme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(),
          ));
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(theme.loginBotton),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(15.0)),
          elevation: MaterialStateProperty.all<double>(5.0),
        ),
        child: Text(
          'login.login'.tr(),
          style: TextStyle(
            color: theme.loginBottonText,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF73AEF5),
                // Color(0xFF61A4F1),
                // Color(0xFF478DE0),
                // Color(0xFF398AE5),
                // Color(0xFFF08080),
                // Color(0xFFCD5C5C),
                // Color(0xFFFF0000),
                // Color(0xFFA52A2A),
                Color(theme.background.value),
                Color(theme.background.value),
                Color(theme.background.value),
                Color(theme.background.value),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
          ),
        ),
        Container(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 120.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Kanbasu',
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'OpenSans',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                _buildEndpointTF(context),
                SizedBox(height: 30.0),
                _buildApiTokenTF(context),
                SizedBox(height: 20.0),
                _buildRememberMeCheckbox(context),
                _buildLoginBtn(context),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
