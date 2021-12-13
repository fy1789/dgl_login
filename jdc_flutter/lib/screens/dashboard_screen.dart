import 'package:jdc/components/my_node_list.dart';
import 'package:flutter/material.dart';
import 'package:jdc/components/storage_details.dart';

import 'package:jdc/constants.dart';
import 'package:jdc/components/header.dart';
import 'package:jdc/controllers/ScreenStateController.dart';
import 'package:jdc/models/user_info.dart';
import 'package:jdc/responsive.dart';
import 'package:jdc/util/store.dart';
import 'package:jdc/widgets/my_button.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ScreenStateController? screenStateController;

  String eid = "";
  String nickname = "";
  String sa = "";

  @override
  void initState() {
    screenStateController = Store.value<ScreenStateController>(context);
    getUserData();
    super.initState();
  }

  Future getUserData() async {
    await screenStateController?.getUserData();
  }

  Future getGonggao() async {
    await screenStateController?.getGongGao();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Selector<ScreenStateController, String>(
                        builder: (_, gonggao, __) {
                          return StarageDetails(
                            gonggao: gonggao,
                          );
                        },
                        selector: (_, store) => store.gongGao),
                  ),
                if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we dont want to show it
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      if (Responsive.isMobile(context))
                        Selector<ScreenStateController, String>(
                            builder: (_, gonggao, __) {
                              return StarageDetails(
                                gonggao: gonggao,
                              );
                            },
                            selector: (_, store) => store.gongGao),
                      if (Responsive.isMobile(context)) SizedBox(height: defaultPadding),
                      Selector<ScreenStateController, UserInfo>(
                          builder: (_, userInfo, __) {
                            return userInfo.nickName == ""
                                ? MyNodeList()
                                : Column(
                                    children: [
                                      Text("${userInfo.nickName} 已登录"),
                                      Text("最后登陆时间: ${userInfo.timestamp}"),
                                      Text("登录状态: ${userInfo.status == 1 ? '在线' : '不在线'}"),
                                      Row(
                                        children: [
                                          MyButton(
                                            onPressed: () {
                                              screenStateController?.setUserInfo(UserInfo("", userInfo.eid, userInfo.timestamp, userInfo.status));
                                            },
                                            text: "更新账号",
                                          ),
                                          MyButton(
                                            onPressed: () {
                                              screenStateController?.setUserInfo(UserInfo("", "", "", 0));
                                            },
                                            text: "切换账号",
                                          )
                                        ],
                                      )
                                    ],
                                  );
                          },
                          selector: (_, store) => store.userInfo),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
