import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';
import 'package:kanbasu/widgets/common/future.dart';
import 'package:kanbasu/widgets/page.dart';
import 'package:kanbasu/models/page.dart' as p;
import 'package:kanbasu/widgets/file.dart';
import 'package:kanbasu/models/file.dart';
import 'package:kanbasu/widgets/assignment.dart';
import 'package:kanbasu/models/assignment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ComposedModuleData {
  Module module;
  List<ModuleItem> items;

  ComposedModuleData(this.module, this.items);
}

class ModuleWidget extends StatelessWidget {
  final ComposedModuleData item;
  ModuleWidget(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final Icon? icon;
    switch (item.module.state) {
      case 'started':
        icon = Icon(
          Icons.play_arrow_outlined,
          color: theme.warning,
          size: 15,
        );
        break;
      case 'completed':
        icon = Icon(
          Icons.done_all,
          color: theme.succeed,
          size: 15,
        );
        break;
      case 'locked':
        icon = Icon(
          Icons.lock,
          color: theme.primary,
          size: 15,
        );
        break;
      case 'unlock':
        icon = Icon(
          Icons.lock_open,
          color: theme.warning,
          size: 15,
        );
        break;
      default:
        icon = null;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SeparatedColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                separatorBuilder: (context, index) => SizedBox(height: 1),
                children: [
                  Text.rich(
                    TextSpan(
                        style: TextStyle(
                          fontSize: 17,
                          color: theme.text,
                        ),
                        children: [
                          TextSpan(text: item.module.name),
                        ]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Spacer(),
                      if (icon != null) icon,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ...item.items.map((moduleItem) => ModuleItemWidget(moduleItem))
      ]),
    );
  }
}

class ModuleItemWidget extends StatelessWidget {
  final ModuleItem item;
  ModuleItemWidget(this.item);
  @override
  Widget build(BuildContext context) {
    if (item.url == null) {
      return NormalModuleItemWidget(item, false);
    } else {
      final stringMatch =
          RegExp(r'/[0-9]+/[a-z]+/[0-9]+').stringMatch(item.url!);
      if (stringMatch == null) {
        final pageItemMatch =
            RegExp(r'/[0-9]+/pages/.*').stringMatch(item.url!);
        if (pageItemMatch == null) {
          return NormalModuleItemWidget(item, false);
        }
        final infoList = pageItemMatch.split('/');
        final courseId = int.parse(infoList[1]);
        final pageUrl = infoList[3];
        return PageItemWidget(courseId, pageUrl, item);
      } else {
        final infoList = stringMatch.split('/');
        final courseId = int.parse(infoList[1]);
        final tabType = infoList[2];
        final tabId = int.parse(infoList[3]);
        switch (tabType) {
          case 'files':
            return FileItemWidget(courseId, tabId, item);
          case 'assignments':
            return AssignmentItemWidget(courseId, tabId, item);
          default:
            return NormalModuleItemWidget(item, false);
        }
      }
    }
  }
}

class PageItemWidget extends StatelessWidget {
  final int courseId;
  final String pageUrl;
  final ModuleItem item;
  PageItemWidget(this.courseId, this.pageUrl, this.item);
  @override
  Widget build(BuildContext context) {
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
            child: RefPageContentWidget(courseId, pageUrl, item),
          );
        },
      ),
      child: NormalModuleItemWidget(item, true),
    );
  }
}

class AssignmentItemWidget extends StatelessWidget {
  final int courseId;
  final int assignmentId;
  final ModuleItem item;
  AssignmentItemWidget(this.courseId, this.assignmentId, this.item);
  @override
  Widget build(BuildContext context) {
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
            child: RefAssignmentContentWidget(courseId, assignmentId, item),
          );
        },
      ),
      child: NormalModuleItemWidget(item, true),
    );
  }
}

class FileItemWidget extends StatefulWidget {
  final int courseId;
  final int fileId;
  final ModuleItem item;
  FileItemWidget(this.courseId, this.fileId, this.item);
  @override
  _TapState createState() => _TapState(courseId, fileId, item);
}

class _TapState extends State<FileItemWidget> {
  final int courseId;
  final int fileId;
  final ModuleItem item;
  var tapped = false;
  _TapState(this.courseId, this.fileId, this.item);
  void _showRefFileWidget() {
    setState(() {
      if (!tapped) {
        tapped = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showRefFileWidget(),
      child: tapped
          ? RefFileWidget(courseId, fileId, item)
          : NormalModuleItemWidget(item, true),
    );
  }
}

class RefPageContentWidget extends FutureWidget<p.Page?> {
  final int courseId;
  final String pageUrl;
  final ModuleItem item;
  RefPageContentWidget(this.courseId, this.pageUrl, this.item);

  @override
  List<Future<p.Page?>> getFutures(BuildContext context) =>
      Provider.of<Model>(context).canvas.getPageByIdentifier(courseId, pageUrl);

  @override
  Widget buildWidget(BuildContext context, p.Page? pageItem) {
    if (pageItem == null) {
      return Text('page.no_details'.tr());
    }
    return PageContentWidget(courseId, pageItem.pageId);
  }
}

class RefAssignmentContentWidget extends FutureWidget<Assignment?> {
  final int courseId;
  final int assignmentId;
  final ModuleItem item;
  RefAssignmentContentWidget(this.courseId, this.assignmentId, this.item);

  @override
  List<Future<Assignment?>> getFutures(BuildContext context) =>
      Provider.of<Model>(context).canvas.getAssignment(courseId, assignmentId);

  @override
  Widget buildWidget(BuildContext context, Assignment? AssignmentItem) {
    if (AssignmentItem == null) {
      return Text('assignment.no_details'.tr());
    }
    return AssignmentContentWidget(AssignmentItem);
  }
}

class RefFileWidget extends FutureWidget<File?> {
  final int courseId;
  final int fileId;
  final ModuleItem item;
  RefFileWidget(this.courseId, this.fileId, this.item);

  @override
  List<Future<File?>> getFutures(BuildContext context) =>
      Provider.of<Model>(context).canvas.getFile(courseId, fileId);

  @override
  Widget buildWidget(BuildContext context, File? fileItem) {
    if (fileItem == null) {
      return NormalModuleItemWidget(item, false);
    }
    return FileWidget(fileItem);
  }
}

class NormalModuleItemWidget extends StatelessWidget {
  final ModuleItem item;
  final bool tappable;
  NormalModuleItemWidget(this.item, this.tappable);
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
                child: SeparatedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  separatorBuilder: (context, index) => SizedBox(height: 1),
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                              style: TextStyle(
                                fontSize: 17,
                                color: theme.text,
                              ),
                              children: [
                                TextSpan(text: item.title),
                              ]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Spacer(),
                        if (tappable)
                          Icon(
                            Icons.arrow_forward,
                            color: theme.tertiaryText,
                            size: 18,
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
