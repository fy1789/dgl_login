import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jdc/constants.dart';
import 'package:jdc/routes/404.dart';
import 'package:jdc/routes/application.dart';
import 'package:jdc/routes/routers.dart';
import 'package:jdc/util/handle_error_utils.dart';
import 'package:jdc/util/store.dart';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:jdc/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdc/util/toast.dart';
import 'package:sp_util/sp_util.dart';

import 'net/dio_utils.dart';
import 'net/intercept.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SpUtil.getInstance();

  handleError(runApp(Store.init(MyApp())));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
}

class MyApp extends StatelessWidget {
  MyApp() {
    initDio();
    Toast.initLoadingToast();

    final FluroRouter router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  void initDio() async {
    final List<Interceptor> interceptors = [];

    /// 打印Log(生产模式去除)
    if (!inProduction) {
      interceptors.add(LoggingInterceptor());
    }

    configDio(
      //adb kill-server && adb server && adb shell
      baseUrl: inProduction ? 'http://127.0.0.1:9997' : 'http://192.168.1.109:9997',
      interceptors: interceptors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '呆瓜佬',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MainScreen(),
      onGenerateRoute: Application.router!.generator,
      builder: EasyLoading.init(builder: (context, Widget? child) {
        /// 保证文字大小不受手机系统设置影响 https://www.kikt.top/posts/flutter/layout/dynamic-text/
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0), // 或者 MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      }),

      /// 因为使用了fluro，这里设置主要针对Web
      onUnknownRoute: (_) {
        return MaterialPageRoute(
          builder: (BuildContext context) => PageNotFound(),
        );
      },
    );
  }
}
