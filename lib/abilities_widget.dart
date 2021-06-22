import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'abilities.dart';
import 'common_logic.dart';
import 'common_widget.dart';

class AbilitiesSectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Abilities", style: Theme.of(context).textTheme.headline4),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            AbilitiesColumnWidget(AbilityColumnType.Talents),
            AbilitiesColumnWidget(AbilityColumnType.Skills),
            AbilitiesColumnWidget(AbilityColumnType.Knowledges),
          ],
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class AbilitiesColumnWidget extends ComplexAbilityColumnWidget {
  AbilitiesColumnWidget(AbilityColumnType this.type) {
    AbilitiesController ac = Get.find();
    super.name = ac.getColumnByType(type).name;
    super.values = ac.getColumnByType(type).values;
    super.editValue = ac.getColumnByType(type).editValue;
    super.deleteValue = ac.getColumnByType(type).deleteValue;
  }

  final type;
}

class AddTalentButton extends SpeedDialChild {
  AddTalentButton(BuildContext context)
      : super(
          child: Icon(Icons.person_add_alt),
          backgroundColor: Colors.red.shade300,
          label: "Add custom talent",
          labelBackgroundColor: Theme.of(context).colorScheme.surface,
          onTap: () async {
            final ca = await Get.dialog<ComplexAbility>(
                ComplexAbilityDialog(name: 'New talent'));
            if (ca != null) {
              AbilitiesController ac = Get.find();
              ac.talents.add(ca);
            }
          },
        );
}

class AddSkillsButton extends SpeedDialChild {
  AddSkillsButton(BuildContext context)
      : super(
          child: Icon(Icons.psychology_outlined),
          backgroundColor: Colors.green.shade300,
          label: "Add custom skill",
          labelBackgroundColor: Theme.of(context).colorScheme.surface,
          onTap: () async {
            final ca = await Get.dialog<ComplexAbility>(
                ComplexAbilityDialog(name: 'New skill'));
            if (ca != null) {
              AbilitiesController ac = Get.find();
              ac.skills.add(ca);
            }
          },
        );
}

class AddKnowledgeButton extends SpeedDialChild {
  AddKnowledgeButton(BuildContext context)
      : super(
          child: Icon(Icons.menu_book),
          backgroundColor: Colors.blue.shade300,
          label: "Add custom knowledge",
          labelBackgroundColor: Theme.of(context).colorScheme.surface,
          onTap: () async {
            final ca = await Get.dialog<ComplexAbility>(
                ComplexAbilityDialog(name: 'New Knowledge'));
            if (ca != null) {
              AbilitiesController ac = Get.find();
              ac.knowledges.add(ca);
            }
          },
        );
}
