import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vampire_the_masquerade_character_sheet/common_widget.dart';
import 'package:vampire_the_masquerade_character_sheet/database.dart';
import 'package:vampire_the_masquerade_character_sheet/xp.dart';

import 'drawer_menu.dart';

class XpSectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final XpController xpc = Get.find();

    final deleteCallback = (int index) {
      Get.find<DatabaseController>().database.delete(
        'player_xp',
        where: 'id = ?',
        whereArgs: [xpc.log[index].id],
      );
      xpc.log.removeAt(index);
    };

    return Column(
      children: [
        Obx(() => Text(
              "Total: ${xpc.xpTotal.value}, spent: ${xpc.xpSpent.value}, left: ${xpc.xpTotal.value - xpc.xpSpent.value}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            )),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemBuilder: (context, i) {
                var logEntry = xpc.log[i];
                if (logEntry is XpEntryNewAbility)
                  return XpEntryNewAbilityWidget(logEntry, deleteCallback, i);
                else if (logEntry is XpEntryUpgradedAbility)
                  return XpEntryUpgradedAbilityWidget(
                      logEntry, deleteCallback, i);
                else if (logEntry is XpEntryGained)
                  return XpEntryGainedWidget(logEntry, deleteCallback, i);
                return Obx(() => Text("${xpc.log[i - 1].description}"));
              },
              itemCount: xpc.log.length,
              primary: true,
            ),
          ),
        ),
      ],
    );
  }
}

class XpEntryNewAbilityWidget extends StatelessWidget {
  XpEntryNewAbilityWidget(this.ability, this.deleteCallback, this.index);

  final XpEntryNewAbility ability;
  final Function(int) deleteCallback;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ability = this.ability.obs;

    return Dismissible(
      key: ValueKey<XpEntryNewAbility>(ability.value),
      child: ListTile(
        leading: Icon(
          Icons.add_circle_outline,
          color: Colors.red,
        ),
        title: Obx(() => Text(ability.value.name)),
        subtitle: Obx(() => Text(ability.value.description)),
        trailing: Obx(() => Text(
              ability.value.cost.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            )),
        onTap: () async {
          var ca = await Get.dialog<XpEntryNewAbility>(XpEntryNewAbilityDialog(
            entryNewAbility: ability.value,
          ));
          if (ca != null) {
            final XpController xpc = Get.find();
            Get.find<DatabaseController>().database.update(
                  'player_xp',
                  {
                    'description': ca.description,
                    'cost': ca.cost,
                    'name': ca.name
                  },
                  where: 'id = ?',
                  whereArgs: [ca.id],
                );
            xpc.xpSpent.value += ca.cost - ability.value.cost;
            ability.update((val) => val?.copy(ca));
          }
        },
      ),
      onDismissed: (direction) => deleteCallback(index),
      confirmDismiss: (direction) =>
          Get.dialog<bool>(DeleteDialog(name: "log entry")),
    );
  }
}

class XpEntryNewAbilityDialog extends Dialog {
  XpEntryNewAbilityDialog({this.entryNewAbility});

  final XpEntryNewAbility? entryNewAbility;

  @override
  Widget build(BuildContext context) {
    var entry = (entryNewAbility ??
            XpEntryNewAbility(id: 0, cost: 0, name: "", description: ""))
        .obs;

    return SimpleDialog(
      title: entryNewAbility == null
          ? Text("Spend XP on a new ability")
          : Obx(() => Text("Edit ${entry.value.name}")),
      children: [
        // name
        TextField(
          controller: TextEditingController()..text = entry.value.name,
          onChanged: (value) => entry.update((val) => val?.name = value),
          decoration: InputDecoration(
              hintText: "What you spent XP on", labelText: "Name"),
        ),
        // cost
        TextFormField(
          controller: TextEditingController()
            ..text = entry.value.cost.toString(),
          onChanged: (value) => entry.update((val) {
            var result = int.tryParse(value);
            if (result != null) val?.cost = result;
          }),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (value != null &&
                  value.isNumericOnly &&
                  int.tryParse(value) != null &&
                  int.tryParse(value)! > 0)
              ? null
              : "This should be a number",
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "XP cost"),
        ),
        // description
        TextField(
          controller: TextEditingController()..text = entry.value.description,
          onChanged: (value) => entry.update((val) => val?.description = value),
          decoration: InputDecoration(
              hintText: "(Optional) Additional information",
              labelText: "Description"),
        ),
        Row(
          children: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Get.back(result: null),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (entry.value.name.isNotEmpty && entry.value.cost != 0)
                  Get.back(result: entry.value);
                else
                  Get.back(result: null);
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    );
  }
}

class XpEntryNewAbilityButton extends CommonSpeedDialChild {
  XpEntryNewAbilityButton()
      : super(
          child: Icon(Icons.add_circle_outline),
          backgroundColor: Colors.red.shade300,
          label: "Spend XP on an ability",
          onTap: () async {
            final ca =
                await Get.dialog<XpEntryNewAbility>(XpEntryNewAbilityDialog());
            if (ca != null) {
              XpController xpc = Get.find();
              xpc.xpSpent.value += ca.cost;
              ca.id = await Get.find<DatabaseController>().addXpEntry(ca);
              xpc.log.add(ca);
            }
          },
        );
}

class XpEntryUpgradedAbilityWidget extends StatelessWidget {
  XpEntryUpgradedAbilityWidget(this.ability, this.deleteCallback, this.index);

  final XpEntryUpgradedAbility ability;
  final Function(int) deleteCallback;
  final int index;

  @override
  Widget build(BuildContext context) {
    final entry = ability.obs;

    return Dismissible(
      key: ValueKey<XpEntryUpgradedAbility>(entry.value),
      child: ListTile(
        leading: Icon(
          Icons.arrow_circle_up,
          color: Colors.red,
        ),
        title: Text(
            "${entry.value.name}: ${entry.value.oldLevel} -> ${entry.value.newLevel}"),
        trailing: Text(
          entry.value.cost.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        onTap: () async {
          var ca = await Get.dialog<XpEntryUpgradedAbility>(
              XpEntryUpgradedAbilityDialog(
            entryUpgradedAbility: entry.value,
          ));
          if (ca != null) {
            final XpController xpc = Get.find();
            xpc.xpSpent.value += ca.cost - entry.value.cost;
            Get.find<DatabaseController>().database.update(
                  'player_xp',
                  {
                    'description': ca.description,
                    'cost': ca.cost,
                    'name': ca.name,
                    'old_level': ca.oldLevel,
                    'new_level': ca.newLevel,
                  },
                  where: 'id = ?',
                  whereArgs: [ca.id],
                );
            entry.update((val) => val?.copy(ca));
          }
        },
      ),
      onDismissed: (direction) => deleteCallback(index),
      confirmDismiss: (direction) =>
          Get.dialog<bool>(DeleteDialog(name: "log entry")),
    );
  }
}

class XpEntryUpgradedAbilityDialog extends Dialog {
  XpEntryUpgradedAbilityDialog({this.entryUpgradedAbility});

  final XpEntryUpgradedAbility? entryUpgradedAbility;

  @override
  Widget build(BuildContext context) {
    var entry = (entryUpgradedAbility ??
            XpEntryUpgradedAbility(
                id: 0,
                cost: 0,
                name: "",
                description: "",
                oldLevel: 1,
                newLevel: 1))
        .obs;

    return SimpleDialog(
      title: entryUpgradedAbility == null
          ? Text("Spend XP on a new ability")
          : Obx(() => Text("Edit ${entry.value.name}")),
      children: [
        // name
        TextField(
          controller: TextEditingController()..text = entry.value.name,
          onChanged: (value) => entry.update((val) => val?.name = value),
          decoration: InputDecoration(
              hintText: "What you spent XP on", labelText: "Name"),
        ),
        // old and new level go here
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: TextEditingController()
                  ..text = entry.value.oldLevel.toString(),
                onChanged: (value) => entry.update((val) {
                  var result = int.tryParse(value);
                  if (result != null) val?.oldLevel = result;
                }),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value != null &&
                        value.isNumericOnly &&
                        int.tryParse(value) != null &&
                        int.tryParse(value)! > 0)
                    ? null
                    : "This should be a number",
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Old level"),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: TextEditingController()
                  ..text = entry.value.newLevel.toString(),
                onChanged: (value) => entry.update((val) {
                  var result = int.tryParse(value);
                  if (result != null) val?.newLevel = result;
                }),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value != null &&
                        value.isNumericOnly &&
                        int.tryParse(value) != null &&
                        int.tryParse(value)! > 0)
                    ? null
                    : "This should be a number",
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "New level"),
              ),
            ),
          ],
        ),
        // cost
        TextFormField(
          controller: TextEditingController()
            ..text = entry.value.cost.toString(),
          onChanged: (value) => entry.update((val) {
            var result = int.tryParse(value);
            if (result != null) val?.cost = result;
          }),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (value != null &&
                  value.isNumericOnly &&
                  int.tryParse(value) != null &&
                  int.tryParse(value)! > 0)
              ? null
              : "This should be a number",
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "XP cost"),
        ),
        // description
        TextField(
          controller: TextEditingController()..text = entry.value.description,
          onChanged: (value) => entry.update((val) => val?.description = value),
          decoration: InputDecoration(
              hintText: "(Optional) Additional information",
              labelText: "Description"),
        ),
        Row(
          children: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Get.back(result: null),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (entry.value.name.isNotEmpty && entry.value.cost != 0)
                  Get.back(result: entry.value);
                else
                  Get.back(result: null);
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    );
  }
}

class XpEntryUpgradedAbilityButton extends CommonSpeedDialChild {
  XpEntryUpgradedAbilityButton()
      : super(
          child: Icon(Icons.arrow_circle_up),
          backgroundColor: Colors.red.shade300,
          label: "Spend XP to improve an ability",
          onTap: () async {
            final ca = await Get.dialog<XpEntryUpgradedAbility>(
                XpEntryUpgradedAbilityDialog());
            if (ca != null) {
              XpController xpc = Get.find();
              xpc.xpSpent.value += ca.cost;
              ca.id = await Get.find<DatabaseController>().addXpEntry(ca);
              xpc.log.add(ca);
            }
          },
        );
}

class XpEntryGainedWidget extends StatelessWidget {
  XpEntryGainedWidget(this.ability, this.deleteCallback, this.index);

  final XpEntryGained ability;
  final Function(int) deleteCallback;
  final int index;

  @override
  Widget build(BuildContext context) {
    final entry = ability.obs;
    return Dismissible(
      key: ValueKey<XpEntryGained>(entry.value),
      child: ListTile(
        leading: Icon(
          Icons.add_circle_outline,
          color: Colors.green,
        ),
        title: Text(entry.value.description),
        trailing: Text(
          entry.value.gained.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        onTap: () async {
          var ca = await Get.dialog<XpEntryGained>(XpEntryGainedDialog(
            entryGained: entry.value,
          ));
          if (ca != null) {
            final XpController xpc = Get.find();
            xpc.xpTotal.value += ca.gained - entry.value.gained;
            Get.find<DatabaseController>().database.update(
                  'player_xp',
                  {'cost': ca.gained, 'description': ca.description},
                  where: 'id = ?',
                  whereArgs: [ca.id],
                );
            entry.update((val) => val?.copy(ca));
          }
        },
      ),
      onDismissed: (direction) => deleteCallback(index),
      confirmDismiss: (direction) =>
          Get.dialog<bool>(DeleteDialog(name: "log entry")),
    );
  }
}

class XpEntryGainedDialog extends Dialog {
  XpEntryGainedDialog({this.entryGained});

  final XpEntryGained? entryGained;

  @override
  Widget build(BuildContext context) {
    var entry =
        (entryGained ?? XpEntryGained(id: 0, gained: 0, description: "")).obs;

    return SimpleDialog(
      title: entryGained == null ? Text("Gain XP") : Text("Edit XP gain"),
      children: [
        // cost
        TextFormField(
          controller: TextEditingController()
            ..text = entry.value.gained.toString(),
          onChanged: (value) => entry.update((val) {
            var result = int.tryParse(value);
            if (result != null) val?.gained = result;
          }),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (value != null &&
                  value.isNumericOnly &&
                  int.tryParse(value) != null &&
                  int.tryParse(value)! > 0)
              ? null
              : "This should be a number",
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "XP gained"),
        ),
        // description
        TextField(
          controller: TextEditingController()..text = entry.value.description,
          onChanged: (value) => entry.update((val) => val?.description = value),
          decoration: InputDecoration(
              hintText: "(Optional) When did you gain the experience?",
              labelText: "Description"),
        ),
        Row(
          children: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Get.back(result: null),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (entry.value.gained > 0)
                  Get.back(result: entry.value);
                else
                  Get.back(result: null);
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    );
  }
}

class XpEntryFailedWidget extends StatelessWidget {
  XpEntryFailedWidget(this.ability, this.deleteCallback, this.index);

  final XpEntryGained ability;
  final Function(int) deleteCallback;
  final int index;

  @override
  Widget build(BuildContext context) {
    final entry = ability.obs;
    return Dismissible(
      key: ValueKey<XpEntryGained>(entry.value),
      child: ListTile(
        title: Text(
          entry.value.description,
          style: TextStyle(color: Colors.red),
        ),
      ),
      onDismissed: (direction) => deleteCallback(index),
      confirmDismiss: (direction) =>
          Get.dialog<bool>(DeleteDialog(name: "log entry")),
    );
  }
}

class AddXpEntryGainedButton extends CommonSpeedDialChild {
  AddXpEntryGainedButton()
      : super(
          child: Icon(Icons.add_circle_outline),
          backgroundColor: Colors.green.shade300,
          label: "Log XP gained",
          onTap: () async {
            final ca = await Get.dialog<XpEntryGained>(XpEntryGainedDialog());
            if (ca != null) {
              XpController xpc = Get.find();
              xpc.xpTotal.value += ca.gained;
              ca.id = await Get.find<DatabaseController>().addXpEntry(ca);
              xpc.log.add(ca);
            }
          },
        );
}

class RecalculateXpButton extends IconButton {
  RecalculateXpButton()
      : super(
            icon: Icon(Icons.refresh),
            onPressed: () => Get.find<XpController>().calculateXp());
}
