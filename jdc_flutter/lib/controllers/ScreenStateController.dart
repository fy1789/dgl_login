import 'package:flutter/material.dart';
import 'package:jdc/models/user_info.dart';
import 'package:jdc/net/dio_utils.dart';
import 'package:jdc/net/http_api.dart';
import 'package:jdc/util/log_utils.dart';
import 'package:sp_util/sp_util.dart';

class ScreenStateController extends ChangeNotifier {
  int _screentIndex = 0;
  int get screentIndex => _screentIndex;

  void setScreenIndex(int index) {
    _screentIndex = index;
    notifyListeners();
  }

  String _qrCode = "";
  String get qrCode => _qrCode;

  void setQrcode(String qrcode) {
    _qrCode = qrcode;
    notifyListeners();
  }

  String? _eid = SpUtil.getString("eid");
  String? get eid => _eid;

  void setEid(String str) {
    _eid = str;
    getUserData();
    notifyListeners();
  }

  void setUserInfo(UserInfo userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  UserInfo _userInfo = UserInfo("", "", "", 0);
  UserInfo get userInfo => _userInfo;

  // 获取登陆用户信息
  Future getUserData() async {
    var eid = SpUtil.getString("eid");
    var nodeUrl = SpUtil.getString("nodeUrl");
    if (eid != "" && nodeUrl != "") {
      await DioUtils.instance.requestNetwork(Method.get, HttpApi.getUserInfo, queryParameters: {"eid": eid, "client_url": nodeUrl},
          onSuccess: (data) {
        _userInfo = UserInfo.fromJson(data);
        notifyListeners();
      }, onError: (_, msg) {
        Log.e(msg);
      });
    }
  }

  String _gongGao = "本项目开源,如果收费,请删除!";
  String get gongGao => _gongGao;

  // 获取公告内容
  Future getGongGao() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getGonggao, onSuccess: (data) {
      _gongGao = data;
      notifyListeners();
    }, onError: (_, msg) {
      Log.e(msg);
    });
  }

  bool _wskeyFlag = false;
  bool get wskeyFlag => _wskeyFlag;

  void setWskeyFlag(bool flag) {
    _wskeyFlag = flag;
    notifyListeners();
  }
}
