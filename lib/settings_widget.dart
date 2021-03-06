import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database.dart';
import 'vampire_character.dart';

class Settings extends GetxController {
  var query = 'db query here'.obs;
  var exception = ''.obs;
  var results = RxList<Map<String, Object?>>();
}

class PlaceholderWithIssue extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(children: [
          new TextSpan(text: 'If you see this, notify the author at '),
          new TextSpan(
            text:
                'https://github.com/varandru/vampire_the_masquerade_character_sheet/issues',
            style: Theme.of(context).textTheme.bodyText1,
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(
                    'https://github.com/varandru/vampire_the_masquerade_character_sheet/issues');
              },
          )
        ], style: Theme.of(context).textTheme.bodyText2),
      );
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return SwitchListTile(
              value: Get.isDarkMode,
              onChanged: (isDark) {
                Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
              },
              title: Text("Dark theme"),
            );

          case 1:
            return ListTile(
              title: Text('Pick a character portrait'),
              trailing: Icon(Icons.navigate_next),
              onTap: () => Get.to(() => Scaffold(
                    appBar: AppBar(
                      title: Text('Pick a character portrait'),
                    ),
                    body: CharacterImagePicker(),
                  )),
            );
          case 2:
            return ListTile(
              title: Text('Check the database directly'),
              trailing: Icon(Icons.navigate_next),
              onTap: () => Get.to(() => Scaffold(
                    appBar: AppBar(
                      title: Text('Settings'),
                    ),
                    body: CheckDatabaseWidget(),
                  )),
            );
          default:
            return PlaceholderWithIssue();
        }
      },
      shrinkWrap: true,
    );
  }
}

DataRow dataRow(Map<String, Object?> input) => DataRow(
      cells: List.generate(
        input.length,
        (i) => DataCell(
          TextButton(
            child: Container(
              child: Text(input.values.elementAt(i)?.toString() ?? ''),
              constraints: BoxConstraints(maxWidth: 100),
            ),
            onPressed: () => Get.dialog(
              Dialog(
                  child: SingleChildScrollView(
                      child:
                          Text(input.values.elementAt(i)?.toString() ?? ''))),
            ),
          ),
        ),
      ),
    );

class CheckDatabaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Settings settings = Get.find();
    return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, i) {
          if (i == 0)
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                  child: TextField(
                controller: TextEditingController()
                  ..text = settings.query.value,
                onChanged: (value) => settings.query.value = value,
              )),
              TextButton(
                  onPressed: () async {
                    try {
                      settings.results.value =
                          await Get.find<DatabaseController>()
                              .database
                              .rawQuery(settings.query.value);
                    } catch (e) {
                      settings.exception.value = e.toString();
                    }
                  },
                  child: Text('Execute')),
            ]);
          if (i == 1) return Obx(() => Text(settings.exception.value));
          if (i == 2)
            return Obx(() => settings.results.length == 0
                ? Table()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: List.generate(
                          settings.results[0].keys.length,
                          (index) => DataColumn(
                              label: Text(
                                  settings.results[0].keys.elementAt(index)))),
                      rows: List.generate(settings.results.length,
                          (index) => dataRow(settings.results[index])),
                    )));
          if (i == 3)
            return TextButton(
              onPressed: () => Get.back(),
              child: Text('Back'),
            );
          return PlaceholderWithIssue();
        });
  }
}

class CharacterImagePicker extends StatelessWidget {
  const CharacterImagePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  Get.find<VampireCharacter>().characterImageFileName.value =
                      image.path;
                }
              },
              child: Text("Pick an image")),
          Obx(() => Text(
              'Current: ${Get.find<VampireCharacter>().characterImageFileName}')),
        ],
      ),
    );
  }
}
