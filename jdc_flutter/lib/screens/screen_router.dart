import 'package:jdc/routes/router_init.dart';
import 'package:fluro/fluro.dart';
import 'package:jdc/screens/bean_page.dart';
import 'package:jdc/screens/task_page.dart';
import 'package:jdc/screens/login_sms_page.dart';

class ScreenRouter implements IRouterProvider {
  static String taskPage = '/task';
  static String beanPage = '/bean';
  static String loginSmsPage = '/loginSmsPage';

  @override
  void initRouter(FluroRouter router) {
    router.define(taskPage, handler: Handler(handlerFunc: (_, params) => TaskPage()));
    router.define(beanPage, handler: Handler(handlerFunc: (_, params) => BeanPage()));
    router.define(loginSmsPage, handler: Handler(handlerFunc: (_, params) => LoginSmsPage()));
  }
}
