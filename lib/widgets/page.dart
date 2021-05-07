import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/page.dart' as p;
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:easy_localization/easy_localization.dart';

class PageWidget extends StatelessWidget {
  final p.Page item;
  PageWidget(this.item);

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

class PageContentWidget extends FutureWidget<p.Page?> {
  final int pageId;
  final int courseId;

  PageContentWidget(this.courseId, this.pageId);

  @override
  List<Future<p.Page?>> getFutures(BuildContext context) =>
      Provider.of<Model>(context).canvas.getPage(courseId, pageId);

  @override
  Widget buildWidget(BuildContext context, p.Page? data) {
    String htmlData;
    if (data == null) {
      htmlData = '<h3> ${'page.no_details'.tr()} </h3>';
    } else {
      htmlData = data.body ?? '<h3> ${'page.no_details'.tr()} </h3>';
    }
    return ListView(
      shrinkWrap: true,
      children: [
        if (data != null) PageWidget(data),
        Html(data: htmlData),
      ],
    );
  }
}
