import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/models/local_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kanbasu/models/resolver_model.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/loading.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:provider/provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PreviewScreen extends StatelessWidget {
  final String fileId;

  PreviewScreen({required this.fileId});

  @override
  Widget build(BuildContext context) {
    return PdfRenderPreviewScreen(fileId: fileId);
  }
}

class PdfRenderPreviewScreen extends FutureWidget<LocalFile?> {
  final String fileId;

  PdfRenderPreviewScreen({required this.fileId});

  @override
  Widget buildWidget(BuildContext context, LocalFile? data) {
    final title = data?.path.split('/').last ?? 'title.preview'.tr();

    final body = data == null
        ? LoadingWidget(isMore: false)
        : PdfViewer.openFile(
            data.path,
            viewerController: PdfViewerController(),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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

class NativePdfViewPreviewScreen extends FutureWidget<LocalFile?> {
  final String fileId;

  NativePdfViewPreviewScreen({required this.fileId});

  @override
  Widget buildWidget(BuildContext context, LocalFile? data) {
    final title = data?.path.split('/').last ?? 'title.preview'.tr();

    final horizontal = useState(false);
    final controller = useMemoized(
      () => data == null
          ? null
          : PdfController(
              document: PdfDocument.openFile(data.path),
            ),
      [data],
    ); // bug of `package:native_pdf_view`

    final body = controller == null
        ? LoadingWidget(isMore: false)
        : PdfView(
            controller: controller,
            scrollDirection: horizontal.value ? Axis.horizontal : Axis.vertical,
            pageSnapping: false,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(horizontal.value
                ? Icons.swap_horiz_outlined
                : Icons.swap_vert_outlined),
            tooltip: 'preview.change_dir'.tr(),
            onPressed: () {
              horizontal.value = !horizontal.value;
            },
          )
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
