import 'package:jdc/controllers/AppStateController.dart';
import 'package:jdc/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<AppStateController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "运行面板",
            style: Theme.of(context).textTheme.headline6,
          ),
        if (!Responsive.isMobile(context)) Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        // Expanded(child: SearchField()),
        // ProfileCard()
      ],
    );
  }
}
