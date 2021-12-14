import 'package:jdc/routes/router_init.dart';
import 'package:fluro/fluro.dart';
import 'package:jdc/screens/bean_page.dart';
import 'package:jdc/screens/task_page.dart';
import 'package:jdc/screens/windows_webview_page.dart';

class ScreenRouter implements IRouterProvider {
  static String taskPage = '/task';
  static String beanPage = '/bean';
  static String winWebviewPage = '/winWebviewPage';

  @override
  void initRouter(FluroRouter router) {
    router.define(taskPage, handler: Handler(handlerFunc: (_, params) => TaskPage()));
    router.define(beanPage, handler: Handler(handlerFunc: (_, params) => BeanPage()));
    router.define(winWebviewPage, handler: Handler(handlerFunc: (_, params) => WindowsWebviewPage()));
  }
}
