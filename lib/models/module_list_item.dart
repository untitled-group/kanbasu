library module_list_item;

import 'package:kanbasu/models/module.dart';
import 'package:kanbasu/models/module_item.dart';

class ModuleListItem {
  Module? module;
  ModuleItem? moduleItem;
  ModuleListItem.ModuleIs(Module module) {
    this.module = module;
  }
  ModuleListItem.ModuleItemIs(ModuleItem moduleItem) {
    this.moduleItem = moduleItem;
  }
}
