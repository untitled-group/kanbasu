import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/page.dart' as page_model;
import 'package:kanbasu/models/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:separated_column/separated_column.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';

class PageWidget extends StatelessWidget {
  final page_model.Page item;
  final bool showDetails;
  PageWidget(this.item, this.showDetails);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                      style: TextStyle(
                        fontSize: 17,
                        color: theme.text,
                      ),
                      children: [
                        TextSpan(text: item.title.trim()),
                      ]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PageContentWidget extends StatelessWidget {
  final page_model.Page item;

  PageContentWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        PageWidget(item, true),
        Html(data: item.body ?? '<h3> ${'assignment.no_details'.tr()} </h3>'),
      ],
    );
  }
}
