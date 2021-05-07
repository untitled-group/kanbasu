import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kanbasu/widgets/link.dart';
import 'package:kanbasu/models/model.dart';
import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';
import 'package:provider/provider.dart';
import 'package:separated_column/separated_column.dart';

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
    final RegUrl = RegExp(r'/[0-9]*/[a-z]*');
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
          ...item.items.map((moduleItem) => moduleItem.url == null
              ? ModuleItemWidget(moduleItem, false)
              : Link(
                  path: '/course' +
                      (RegUrl.stringMatch(moduleItem.url!.substring(37)) ?? ''),
                  child: ModuleItemWidget(moduleItem, true)))
        ],
      ),
    );
  }
}

class ModuleItemWidget extends StatelessWidget {
  final ModuleItem item;
  final bool hasUrl;
  ModuleItemWidget(this.item, this.hasUrl);
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
                        if (hasUrl)
                          Icon(
                            Icons.arrow_forward,
                            color: theme.tertiaryText,
                            size: 18,
                          ),
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
