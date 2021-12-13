import 'dart:async';
import 'dart:developer';

import 'package:jdc/net/net.dart';
import 'package:jdc/routes/fluro_navigator.dart';
import 'package:jdc/util/log_utils.dart';
import 'package:jdc/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final CookieManager cookieManager = CookieManager();

  bool isLangu = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                var canGoBack = await snapshot.data!.canGoBack();
                if (canGoBack) {
                  // 网页可以返回时，优先返回上一页
                  await snapshot.data!.goBack();
                  return Future.value(false);
                }
              }
              return Future.value(true);
            },
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(widget.title),
                ),
                body: SafeArea(
                    child: Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      navigationDelegate: (NavigationRequest request) async {
                        return NavigationDecision.navigate;
                      },
                      onPageStarted: (String url) async {
                        Log.d(url);

                        if (url.indexOf("https://bean.m.jd.com/bean/signIndex.action") >= 0) {
                          final cookieManager = WebviewCookieManager();
                          final gotCookies = await cookieManager.getCookies('https://bean.m.jd.com/bean/signIndex.action');

                          String ptPin = "";
                          String ptKey = "";

                          for (var item in gotCookies) {
                            print(item);
                            switch (item.name) {
                              case "pt_pin":
                                ptPin = item.value;
                                break;
                              case "pt_key":
                                ptKey = item.value;
                                break;
                              default:
                            }
                          }
                          // 后台发送cookie
                          Log.d("pt_pin======>$ptPin");
                          Log.d("pt_key======>$ptKey");
                          if (ptPin != "" && ptKey != "") {
                            Clipboard.setData(ClipboardData(text: "pt_pin=$ptPin;pt_key=$ptKey;"));
                            Toast.show("获取凭证成功,并已经复制到剪切板");
                            NavigatorUtils.goBackWithParams(context, "pt_pin=$ptPin;pt_key=$ptKey;");
                          }
                        }
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onPageFinished: (finish) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                        _webViewController = webViewController;
                        _webViewController?.clearCache();
                        cookieManager.clearCookies();
                      },
                    ),
                    isLoading
                        ? Center(
                            heightFactor: 15,
                            child: Text(
                              "登陆跳转后,将自动获取登录凭证,自动上传. \n 如果自动上传失败,凭证会自动复制到剪切板.",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Align(
                            alignment: Alignment.bottomCenter,
                            heightFactor: 12,
                            child: Text(
                              "登陆跳转后,将自动获取登录凭证,上传. \n 如果自动上传失败,凭证会自动复制到剪切板.",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                    isLoading
                        ? Container(
                            color: Colors.black26,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(),
                  ],
                ))),
          );
        });
  }
}
