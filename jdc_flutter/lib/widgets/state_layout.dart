import 'package:jdc/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:jdc/res/gaps.dart';
import 'package:jdc/util/image_utils.dart';

typedef RefreshCallback = Future<void> Function();

class StateLayout extends StatelessWidget {
  const StateLayout({Key? key, required this.type, this.hintText, this.onRefresh}) : super(key: key);

  final StateType type;
  final String? hintText;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (type == StateType.loading)
          const CircularProgressIndicator()
        else if (type != StateType.empty)
          Opacity(
            opacity: 0.5,
            child: type != StateType.network
                ? Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ImageUtils.getAssetImage('state/${type.img}'),
                      ),
                    ),
                  )
                : MyButton(
                    text: "点击刷新",
                    minWidth: 60,
                    minHeight: 30,
                    onPressed: () {
                      onRefresh!();
                    },
                  ),
          ),
        const SizedBox(
          width: double.infinity,
          height: Dimens.gap_dp16,
        ),
        Text(
          hintText ?? type.hintText,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: Dimens.font_sp14),
        ),
        Gaps.vGap50,
      ],
    );
  }
}

enum StateType { order, network, account, loading, empty }

extension StateTypeExtension on StateType {
  String get img => ['zwdd', 'zwwl', 'zwzh', '', ''][this.index];

  String get hintText => ['暂无资源', '无网络连接', '没有页面', '正在加载中...', ''][this.index];
}
