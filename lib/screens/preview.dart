import 'package:flutter/material.dart';
import 'package:kanbasu/models/local_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends FutureWidget<LocalFile?> {
  final String fileId;

  PreviewScreen({required this.fileId});

  @override
  Widget buildWidget(BuildContext context, LocalFile? data) {
    final title = data?.path.split('/').last ?? 'File';
    final body = data == null
        ? LoadingWidget(isMore: false)
        : PdfView(
            controller: PdfController(
              document: PdfDocument.openFile(data.path),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              tooltip: 'title.settings'.tr(),
              onPressed: () {})
        ],
      ),
      body: body,
    );
  }

  @override
  List<Future<LocalFile?>> getFutures(BuildContext context) => [
        Provider.of<ResolverModel>(context)
            .fileResolver
            .getDownloadedFileById(fileId),
      ];
}
