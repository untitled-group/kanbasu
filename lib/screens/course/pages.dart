import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/page.dart' as page_model;
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/page.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CoursePagesScreen extends RefreshableStreamListWidget<page_model.Page> {
  final int courseId;

  CoursePagesScreen(this.courseId);

  @override
  List<Stream<page_model.Page>> getStreams(context) =>
      Provider.of<Model>(context).canvas.getPages(courseId);

  @override
  Widget buildItem(context, page_model.Page item) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: PageContentWidget(item),
          );
        },
      ),
      child: PageWidget(item, false),
    );
  }
}
