import 'package:jdc/routes/404.dart';
import 'package:jdc/routes/router_init.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:jdc/screens/main_screen.dart';
import 'package:jdc/screens/screen_router.dart';
import 'package:jdc/screens/webview_page.dart';

// ignore: avoid_classes_with_only_static_members
class Routes {
  static String mainscreen = '/mainscreen';
  static String webViewPage = '/webview';

  static final List<IRouterProvider> _listRouter = [];

  static void configureRoutes(FluroRouter router) {
    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      debugPrint('未找到目标页');
      return PageNotFound();
    });

    router.define(mainscreen, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) => MainScreen()));

    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      final String title = params['title']!.first;
      final String url = params['url']!.first;
      return WebViewPage(
        title: title,
        url: url,
      );
    }));

    _listRouter.clear();

    /// 各自路由由各自模块管理，统一在此添加初始化
    _listRouter.add(ScreenRouter());

    /// 初始化路由
    _listRouter.forEach((routerProvider) {
      routerProvider.initRouter(router);
    });
  }
}
