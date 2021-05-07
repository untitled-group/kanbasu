import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';
import 'package:kanbasu/widgets/page.dart';
import 'package:kanbasu/models/page.dart' as p;
import 'package:kanbasu/widgets/file.dart';
import 'package:kanbasu/models/file.dart';

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
          ...item.items.map((moduleItem) => ModuleItemWidget(moduleItem)),
        ],
      ),
    );
  }
}

class ModuleItemWidget extends StatelessWidget {
  final ModuleItem item;
  ModuleItemWidget(this.item);
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context).theme;
    final hasUrl = item.url != null;
    return NormalModuleItemWidget(item);
    // if (!hasUrl) {
    //   return NormalModuleItemWidget(item);
    // } else {
    //   final infoList =
    //       RegExp(r'[0-9]*/[a-z]*/[0-9]*').stringMatch(item.url!)!.split('/');
    //   final courseId = int.parse(infoList[0]);
    //   final tabType = infoList[1];
    //   final tabId = int.parse(infoList[2]);
    //   switch (tabType) {
    //     case 'pages':
    //       return PageWidget(getPageItem(courseId, tabId));
    //     case 'files':
    //       return FileWidget(getFileItem(courseId, tabId));
    //   }
    // }
  }

//   p.Page getPageItem(int courseId, int tabId){

//   }

//   File getFileItem(int courseId, int tabId){

//   }
}

class NormalModuleItemWidget extends StatelessWidget {
  final ModuleItem item;
  NormalModuleItemWidget(this.item);
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Spacer(),
                      ],
                    ),
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
