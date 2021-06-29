import 'package:get/get.dart';

class XPController extends GetxController {
  var xpTotal = 0.obs;
  var xpSpent = 0.obs;

  RxList<XpEntry> log = RxList();

  void calculateXp() {
    xpTotal.value = 0;
    xpSpent.value = 0;
    for (XpEntry entry in log) {
      if (entry is XpEntryUpgradedAbility) {
        xpSpent.value += entry.cost;
      } else if (entry is XpEntryNewAbility) {
        xpSpent.value += entry.cost;
      } else if (entry is XpEntryGained) {
        xpTotal += entry.gained;
      }
    }
  }

  void load(Map<String, dynamic> json) {
    log.clear();
    if (json["log"] != null) {
      for (var entry in json["log"]) {
        if (entry["old_level"] != null) {
          log.add(XpEntryUpgradedAbility.fromJson(entry));
        } else if (entry["cost"] != null) {
          log.add(XpEntryNewAbility.fromJson(entry));
        } else if (entry["gained"] != null) {
          log.add(XpEntryGained.fromJson(entry));
        }
      }
    }

    if (json["total"] != null && json["spent"] != null) {
      xpTotal.value = json["total"];
      xpSpent.value = json["spent"];
    } else {
      calculateXp();
    }
  }

  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map();

    json["total"] = xpTotal.value;
    json["spent"] = xpSpent.value;
    json["log"] = log;

    return json;
  }
}

class XpEntry {
  XpEntry(this.description);

  String description;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map();

    json["description"] = description;

    return json;
  }

  void copy(XpEntry other) {
    description = other.description;
  }
}

class XpEntryNewAbility extends XpEntry {
  XpEntryNewAbility({
    required this.cost,
    required this.name,
    required String description,
  }) : super(description);

  XpEntryNewAbility.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        cost = json["cost"],
        super(json["description"] ?? "");

  String name;
  int cost;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    json["cost"] = cost;
    json["name"] = name;

    return json;
  }

  @override
  void copy(XpEntry other) {
    if (other is XpEntryNewAbility) {
      cost = other.cost;
      name = other.name;
    }
    super.copy(other);
  }
}

class XpEntryUpgradedAbility extends XpEntry {
  XpEntryUpgradedAbility({
    required this.cost,
    required this.name,
    required this.oldLevel,
    required this.newLevel,
    required String description,
  }) : super(description);

  XpEntryUpgradedAbility.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        cost = json["cost"],
        oldLevel = json["old_level"],
        newLevel = json["new_level"],
        super(json["description"] ?? "");

  int cost;
  String name;

  int oldLevel;
  int newLevel;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    json["cost"] = cost;
    json["name"] = name;
    json["old_level"] = oldLevel;
    json["new_level"] = newLevel;

    return json;
  }
}

class XpEntryGained extends XpEntry {
  XpEntryGained({
    required this.gained,
    required String description,
  }) : super(description);

  XpEntryGained.fromJson(Map<String, dynamic> json)
      : gained = json["gained"],
        super(json["description"] ?? "");

  int gained;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    json["gained"] = gained;

    return json;
  }
}