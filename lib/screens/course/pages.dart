import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/buffer_api/canvas.dart';
import 'package:kanbasu/aggregation.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/widgets/page.dart';
import 'package:kanbasu/widgets/common/refreshable_stream_list.dart';
import 'package:provider/provider.dart';

class CoursePagesScreen extends RefreshableStreamListWidget<ComposedPageData> {
  final int courseId;

  CoursePagesScreen(this.courseId);

  Stream<ComposedPageData> getPagesStream(
      CanvasBufferClient canvas, int courseId, bool useOnlineData) async* {
    final pages =
        await getListDataFromApi(canvas.getPages(courseId), useOnlineData);
    for (final page in pages) {
      final detailedPage = await getItemDataFromApi(
          canvas.getPage(courseId, page.pageId), useOnlineData);
      yield ComposedPageData(page, detailedPage);
    }
  }

  @override
  List<Stream<ComposedPageData>> getStreams(context) => [
        getPagesStream(Provider.of<Model>(context).canvas, courseId, false),
        getPagesStream(Provider.of<Model>(context).canvas, courseId, true),
      ];

  @override
  Widget buildItem(context, ComposedPageData item) {
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
            child: PageContentWidget(item.page, item.detailedPage),
          );
        },
      ),
      child: PageWidget(item.page, false),
    );
  }
}
