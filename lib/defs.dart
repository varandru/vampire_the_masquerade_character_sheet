import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bloodPoolProvider = StateProvider((ref) => 0);
final willpowerProvider = StateProvider((ref) => 0);

class BloodNotifier extends StateNotifier<int> {
  BloodNotifier(int? bloodCount) : super(bloodCount ?? 0);
}

class WillPowerNotifier extends StateNotifier<int> {
  WillPowerNotifier(int? will) : super(will ?? 0);
}

class Attribute {
  Attribute(
      {required String name,
      int current = 1,
      int max = 5,
      String specialization = ""})
      : this.name = name,
        this.current = current,
        this.max = max,
        this.specialization = specialization;
  String name;
  int current;
  int max;
  String specialization;
}

List<Widget> makeIconRow(
    int current, int max, IconData filled, IconData empty) {
  List<Widget> row = [];
  for (int i = 0; i < current; i++) {
    row.add(Icon(filled, size: 20));
  }
  for (int i = current; i < max; i++) {
    row.add(Icon(empty, size: 20));
  }
  return row;
}

List<Widget> makeBloodPoolRow(
    int current, int localMax, int max, BuildContext context) {
  List<Widget> row = [];
  for (int i = 0; i < current; i++) {
    row.add(IconButton(
      icon: Icon(Icons.add_box),
      iconSize: 20,
      onPressed: () => context.read(bloodPoolProvider).state = i + 1,
    ));
  }
  for (int i = current; i < localMax; i++) {
    row.add(IconButton(
      icon: Icon(Icons.check_box_outline_blank),
      iconSize: 20,
      onPressed: () {
        context.read(bloodPoolProvider).state = i + 1;
      },
    ));
  }
  for (int i = localMax; i < max; i++) {
    row.add(Icon(Icons.select_all, size: 20));
  }

  row.insert(0, Spacer());
  row.add(Spacer());

  return row;
}

List<Widget> makeWillPowerRow(
    int current, int localMax, int max, BuildContext context) {
  List<Widget> row = [];
  for (int i = 0; i < current; i++) {
    row.add(IconButton(
      icon: Icon(Icons.add_box),
      iconSize: 20,
      onPressed: () => context.read(willpowerProvider).state = i + 1,
    ));
  }
  for (int i = current; i < localMax; i++) {
    row.add(IconButton(
      icon: Icon(Icons.check_box_outline_blank),
      iconSize: 20,
      onPressed: () {
        context.read(willpowerProvider).state = i + 1;
      },
    ));
  }
  for (int i = localMax; i < max; i++) {
    row.add(Icon(Icons.select_all, size: 20));
  }

  return row;
}

class AttributeWidget extends StatelessWidget {
  AttributeWidget({Key? key, required Attribute attribute})
      : this.attribute = attribute,
        super(key: key);

  final Attribute attribute;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = makeIconRow(
        attribute.current, attribute.max, Icons.circle, Icons.circle_outlined);
    final header = Text(
      attribute.name +
          (attribute.specialization.isNotEmpty
              ? " (" + attribute.specialization + ")"
              : ""),
      overflow: TextOverflow.fade,
      softWrap: false,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      child: ListTile(
        title: header,
        trailing: Row(
          children: row,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}

class NoTitleCounterWidget extends StatelessWidget {
  NoTitleCounterWidget({int current = 0, int max = 10})
      : _current = current,
        _max = max;

  final _current;
  final _max;

  @override
  Widget build(BuildContext context) {
    List<Widget> row =
        makeIconRow(_current, _max, Icons.circle, Icons.circle_outlined);
    row.insert(0, Spacer());
    row.add(Spacer());

    return Row(
      children: row,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}
