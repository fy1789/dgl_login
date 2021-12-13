import 'package:animations/animations.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:jdc/routes/routers.dart';

import 'application.dart';

/// fluro的路由跳转工具类
class NavigatorUtils {
  static void push(BuildContext context, String path, {bool replace = false, bool clearStack = false}) {
    unfocus();
    Application.router!.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: TransitionType.custom,
      routeSettings: RouteSettings(name: path.split("?")[0]),
      transitionBuilder: (context, animation, secondaryAnimation, child) => SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      ),
    );
  }

  static void pushResult(BuildContext context, String path, Function(Object) function, {bool replace = false, bool clearStack = false}) {
    unfocus();
    Application.router!
        .navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: TransitionType.custom,
      transitionBuilder: (context, animation, secondaryAnimation, child) => SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      ),
    )
        .then((result) {
      // // 页面返回result为null
      // if (result == null) {
      //   return;
      // }
      function(result);
    }).catchError((dynamic error) {
      print('$error');
    });
  }

  /// 返回
  static void goBack(BuildContext context) {
    unfocus();
    Navigator.pop(context);
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, Object result) {
    unfocus();
    Navigator.pop<Object>(context, result);
  }

  static void unfocus() {
    // 使用下面的方式，会触发不必要的build。
    // FocusScope.of(context).unfocus();
    // https://github.com/flutter/flutter/issues/47128#issuecomment-627551073
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 跳到WebView页
  static void goWebViewPage(BuildContext context, String title, String url, Function(Object)? function) {
    //fluro 不支持传中文,需转换
    if (function != null) {
      pushResult(context, '${Routes.webViewPage}?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}', function);
    } else {
      push(context, '${Routes.webViewPage}?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
    }
  }
}
