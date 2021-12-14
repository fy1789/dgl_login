import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'storage_info_card.dart';

class StarageDetails extends StatelessWidget {
  const StarageDetails({
    Key? key,
    required this.gonggao,
  }) : super(key: key);

  final String gonggao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "公告内容",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Text(
            gonggao,
            style: TextStyle(color: Colors.redAccent),
          ),
          SizedBox(height: defaultPadding),
          StorageInfoCard(
            svgSrc: "assets/icons/doc_file.svg",
            title: "github",
            url: "https://github.com/xiaojia21190/egg_jdc",
          ),
        ],
      ),
    );
  }
}
