import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vampire_the_masquerade_character_sheet/advantages.dart';

import 'abilities.dart';
import 'attributes.dart';
import 'main_info.dart';

/// Controller for the whole character. Handles saving and loading data from files, and, possibly, any other character-wide operations
class VampireCharacter extends GetxController {
  // Comments mean: can save/can load. Not ++ means I'm not done
  late MostVariedController mostVariedController; // ++
  late VirtuesController virtuesController; // ++
  late MainInfo mainInfo; // ++
  // late AttributesController attributesController; // ++
  // late AbilitiesController abilitiesController; // ++
  late BackgroundsController backgroundsController;

  late String _characterFileName;
  late bool installed;

  Future<void> loadSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    installed = preferences.getBool('installed') ?? false;
  }

  void initialize() {
    print("Creating controllers!");
    mostVariedController = Get.put(MostVariedController());
    virtuesController = Get.put(VirtuesController());
    mainInfo = Get.put(MainInfo());
    // attributesController = Get.put(AttributesController());s
    // abilitiesController = Get.put(AbilitiesController());
    backgroundsController = Get.put(BackgroundsController());
  }

  void _loadToControllers(Map<String, dynamic> json) {
    mostVariedController.load(json["most_varied_variables"]);
    virtuesController.load(json["virtues"]);
    mainInfo.load(json["main_info"]);
  }

  Map<String, dynamic> _saveFromControllers() {
    Map<String, dynamic> json = Map();
    json["most_varied_variables"] = mostVariedController.save();
    json["virtues"] = virtuesController.save();
    json["main_info"] = mainInfo.save();
    // json["attributes"] = attributesController.save();
    // json["abilities"] = abilitiesController.save();
    return json;
  }

  Future<String> _loadAttributeList() async {
    var directory = await getApplicationDocumentsDirectory();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final attributeListFile = preferences.getString('attribute_dictionary') ??
        'default_attributes_en_US.json';
    File dictionaryFile = File(directory.path + '/' + attributeListFile);

    if (await dictionaryFile.exists()) {
      return dictionaryFile.readAsString();
    } else {
      throw ("Attribute dictionary $attributeListFile does not exist");
    }
  }

  Future<String> _loadAbilitiesList() async {
    var directory = await getApplicationDocumentsDirectory();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final abilitiesListFile = preferences.getString('abilities_dictionary') ??
        'default_abilities_en_US.json';
    File dictionaryFile = File(directory.path + '/' + abilitiesListFile);

    if (await dictionaryFile.exists()) {
      return dictionaryFile.readAsString();
    } else {
      throw ("Attribute dictionary $abilitiesListFile does not exist");
    }
  }

  Future<String> _loadBackgroundList() async {
    var directory = await getApplicationDocumentsDirectory();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final backgroundsListFile =
        preferences.getString('backgrounds_dictionary') ??
            'default_backgrounds_en_US.json';
    File dictionaryFile = File(directory.path + '/' + backgroundsListFile);

    if (await dictionaryFile.exists()) {
      return dictionaryFile.readAsString();
    } else {
      throw ("Attribute dictionary $backgroundsListFile does not exist");
    }
  }

  /// Loads a local JSON character file
  Future<void> load() async {
    Get.snackbar("Loading", "Loading character information");
    if (GetPlatform.isAndroid || GetPlatform.isWeb) {
      if (GetPlatform.isAndroid) {
        var direcrory = await getApplicationDocumentsDirectory();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        _characterFileName =
            preferences.getString('character_file') ?? "character.json";
        File characterFile = File(direcrory.path + '/' + _characterFileName);

        if (characterFile.existsSync()) {
          // // Attribute dictionary
          // AttributeDictionary atrd = AttributeDictionary();
          // var attributeList = await _loadAttributeList();
          // atrd.load(jsonDecode(attributeList));

          // // Abilities dictionary
          // AbilitiesDictionary abd = AbilitiesDictionary();
          // var abilitiesList = await _loadAbilitiesList();
          // abd.load(jsonDecode(abilitiesList));

          // Backgrounds dictionary
          BackgroundDictionary backd = BackgroundDictionary();
          var backgroundList = await _loadBackgroundList();
          backd.load(jsonDecode(backgroundList));

          Map<String, dynamic> json =
              jsonDecode(characterFile.readAsStringSync());

          _loadToControllers(json);

          // if (json["attributes"] != null)
          //   attributesController.load(json["attributes"], atrd);

          // if (json["abilities"] != null)
          //   abilitiesController.load(json["abilities"], abd);

          if (json["backgrounds"] != null)
            backgroundsController.load(json["backgrounds"], backd);
        }
        // else just use the defaults

      } else if (GetPlatform.isWeb) {
        // Web can't really store local files. Being in the, y'know, Web
        // But I use Chrome for debugging, so I kinda need it to not throw
        print("You are launching in Web. File operations are not available");
        // attributesController.initializeFromConstants();
        // abilitiesController.initializeFromConstants();
      }
    } else {
      Get.back();
      // I haven't handled this platform yet. It may or may not support local file access
      throw ("This platform is not supported in file handling yet");
    }
  }

  /// Saves back a local JSON character file
  void save() async {
    Get.snackbar("Saving...", "Saving character info");
    if (GetPlatform.isAndroid) {
      getApplicationDocumentsDirectory().then((value) {
        File characterFile = File(value.path + '/' + _characterFileName);
        Map<String, dynamic> json = _saveFromControllers();
        characterFile.writeAsStringSync(jsonEncode(json));
      });
    } else if (GetPlatform.isWeb) {
      throw ("Web can't store files");
    } else {
      // I haven't handled this platform yet. It may or may not support local file access
      throw ("This platform is not supported in file handling yet");
    }
    Get.back();
  }

  Future<void> install() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var directory = await getApplicationDocumentsDirectory();

    String attributeString =
        await rootBundle.loadString('assets/default_attributes_en_US.json');
    File attributeFile = File(directory.path +
        '/' +
        (preferences.getString('attribute_dictionary') ??
            'default_attributes_en_US.json'));

    attributeFile.writeAsStringSync(attributeString);

    attributeString =
        await rootBundle.loadString('assets/default_abilities_en_US.json');
    attributeFile = File(directory.path +
        '/' +
        (preferences.getString('default_abilities') ??
            'default_abilities_en_US.json'));

    attributeFile.writeAsStringSync(attributeString);

    attributeString =
        await rootBundle.loadString('assets/default_backgrounds_en_US.json');
    attributeFile = File(directory.path +
        '/' +
        (preferences.getString('default_backgrounds') ??
            'default_backgrounds_en_US.json'));

    attributeFile.writeAsStringSync(attributeString);

    attributeString =
        await rootBundle.loadString('assets/default_character_en_US.json');
    attributeFile = File(directory.path +
        '/' +
        (preferences.getString('default_character') ?? 'character.json'));

    attributeFile.writeAsStringSync(attributeString);

    await preferences.setBool('installed', true);
    print("Installation Done!");
  }

  Future<void> init() async {
    await loadSharedPreferences();
    // TEMP
    installed = false;
    if (!installed) {
      await install();
    }
    initialize();
    return load();
  }

  void onClose() {
    save();
    super.onClose();
  }
}
