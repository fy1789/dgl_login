import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jdc/constants.dart';
import 'package:jdc/controllers/ScreenStateController.dart';
import 'package:jdc/models/node_list_model.dart';
import 'package:jdc/net/dio_utils.dart';
import 'package:jdc/net/http_api.dart';
import 'package:jdc/res/gaps.dart';
import 'package:jdc/routes/fluro_navigator.dart';
import 'package:jdc/util/device_utils.dart';
import 'package:jdc/util/store.dart';
import 'package:jdc/util/toast.dart';
import 'package:jdc/util/utils.dart';
import 'package:jdc/widgets/base_dialog.dart';
import 'package:jdc/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:sp_util/sp_util.dart';

class NodeInfoCard extends StatefulWidget {
  const NodeInfoCard({
    key,
    required this.info,
  }) : super(key: key);

  final NodeListModel info;

  @override
  _NodeInfoCardState createState() => _NodeInfoCardState();
}

class _NodeInfoCardState extends State<NodeInfoCard> {
  late ScreenStateController screenStateController;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    screenStateController = Store.value<ScreenStateController>(context);
  }

  late Map<String, dynamic> qrcode;

  // 检查是否登陆
  Future checkLogin(String cookie, String type) async {
    var nodeUrl = SpUtil.getString("nodeUrl");
    // 直接发送链接
    await DioUtils.instance.requestNetwork(Method.post, type == "1" ? HttpApi.saveCk : HttpApi.saveWs,
        params: {"value": cookie}, queryParameters: {"client_url": nodeUrl}, onSuccess: (resultList) async {
      Toast.show(resultList["message"]);
      SpUtil.putString("eid", resultList["eid"]);
      // 更新user页面
      screenStateController.setEid(resultList["eid"]);
      await screenStateController.getUserData();
      // 退出弹窗
      NavigatorUtils.goBack(context);
    }, onError: (_, msg) {
      Toast.show("上传失败,已把凭证复制到剪切板,", duration: 10 * 1000);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.info.activite) {
          Toast.show("当前节点不在线, 请选择在线的节点");
          return;
        }
        showDialog(
            context: context,
            builder: (_) {
              return BaseDialog(
                  hiddenTitle: false,
                  onPressed: () {
                    NavigatorUtils.goBack(context);
                    showElasticDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Material(
                          type: MaterialType.transparency,
                          child: Center(
                            child: Container(
                              width: 300,
                              height: 500,
                              margin: EdgeInsets.only(top: defaultPadding),
                              padding: EdgeInsets.all(defaultPadding),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultPadding),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      "手机验证码登陆有效期大约是30天 \n wskey登陆提供自动刷新服务,理论上是永久登陆",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      MyButton(
                                        text: '手机号验证码登陆',
                                        onPressed: () async {
                                          //调用对应节点的扫码接口
                                          SpUtil.putString("nodeUrl", widget.info.clientUrl);
                                          SpUtil.putString("nodeName", widget.info.clientName);
                                          //开启webview提供登陆
                                          if (Devices.isAndroid || Devices.isIOS) {
                                            NavigatorUtils.goWebViewPage(context, "登陆凭证获取", "https://bean.m.jd.com/bean/signIndex.action",
                                                (Object? obj) async {
                                              print(obj);
                                              if (obj != null) {
                                                await checkLogin(obj.toString(), "1");
                                              }
                                            });
                                          } else {
                                            Toast.show("web不支持手机验证码登陆,请选择wskey登陆");
                                          }
                                        },
                                      ),
                                      Gaps.vGap10,
                                      MyButton(
                                        text: 'wskey登陆',
                                        onPressed: () async {
                                          SpUtil.putString("nodeUrl", widget.info.clientUrl);
                                          SpUtil.putString("nodeName", widget.info.clientName);
                                          screenStateController.setWskeyFlag(true);
                                        },
                                      ),
                                      Gaps.vGap10,
                                      Selector<ScreenStateController, bool>(
                                          builder: (_, wskeyFlag, __) {
                                            return wskeyFlag
                                                ? Column(
                                                    children: [
                                                      TextField(
                                                        decoration: InputDecoration(
                                                          hintText: "请填入wskey",
                                                          fillColor: secondaryColor,
                                                          filled: true,
                                                          border: OutlineInputBorder(
                                                            borderSide: BorderSide.none,
                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                          ),
                                                          suffixIcon: InkWell(
                                                            onTap: () {
                                                              _controller.text = "";
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(defaultPadding * 0.75),
                                                              margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                                                              decoration: BoxDecoration(
                                                                color: primaryColor,
                                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                              ),
                                                              child: Icon(
                                                                Icons.clear,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        autofocus: true,
                                                        controller: _controller,
                                                        maxLines: 1,
                                                      ),
                                                      Gaps.vGap10,
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          MyButton(
                                                            onPressed: () => screenStateController.setWskeyFlag(false),
                                                            text: "取消",
                                                          ),
                                                          MyButton(
                                                            onPressed: () async {
                                                              // 上传wskey
                                                              await checkLogin(_controller.text, "0");
                                                            },
                                                            text: "确定",
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : Container();
                                          },
                                          selector: (_, store) => store.wskeyFlag)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "已经确定了登陆的风险了吗?",
                    style: TextStyle(color: Colors.redAccent),
                  ));
            });
      },
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("(状态:${widget.info.activite ? '在线' : '不在线'})"),
            Text(
              "${widget.info.clientName}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            ProgressLine(
              color: Color(0xFFA4CDFF),
              percentage: (widget.info.allCount - widget.info.marginCount) / widget.info.allCount,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "剩余:${widget.info.marginCount}",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white70),
                ),
                Text(
                  "总共:${widget.info.allCount}",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final double? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * percentage!,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
