import 'package:flutter/material.dart';
import 'package:jdc/constants.dart';
import 'package:jdc/controllers/ScreenStateController.dart';
import 'package:jdc/res/gaps.dart';
import 'package:jdc/util/store.dart';
import 'package:jdc/util/toast.dart';
import 'package:jdc/widgets/my_button.dart';
import 'package:jdc/widgets/my_text_field.dart';

class LoginSmsPage extends StatefulWidget {
  const LoginSmsPage({Key? key}) : super(key: key);

  @override
  _LoginSmsPageState createState() => _LoginSmsPageState();
}

class _LoginSmsPageState extends State<LoginSmsPage> {
  ScreenStateController? screenStateController;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vCodeController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  bool _clickable = false;

  void _login() {
    Toast.show('去登录......');
  }

  @override
  void initState() {
    super.initState();
    screenStateController = Store.value<ScreenStateController>(context);
    screenStateController?.listWebSoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("短信登陆"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 400,
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gaps.vGap16,
              MyTextField(
                focusNode: _nodeText1,
                controller: _phoneController,
                maxLength: 11,
                keyboardType: TextInputType.phone,
                hintText: "请输入手机号",
              ),
              Gaps.vGap8,
              MyTextField(
                focusNode: _nodeText2,
                controller: _vCodeController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                hintText: "请输入验证码",
                getVCode: () {
                  Toast.show('获取验证码');
                  return Future.value(true);
                },
              ),
              Gaps.vGap24,
              MyButton(
                onPressed: _clickable ? _login : null,
                textColor: primaryColor,
                minWidth: 200,
                text: "登陆",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
