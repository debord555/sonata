import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon_data;
  final int screen_reference;
  final String screen_name;

  const DrawerItem(this.icon_data, this.screen_name, this.screen_reference, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon_data),
      title: Text(screen_name),
      onTap: () {
        Provider.of<Data>(context, listen: false).updateScreen(screen_reference);
        Navigator.pop(context);
      },
      tileColor: (Provider.of<Data>(context).screen == screen_reference) ? Theme.of(context).splashColor : null,
    );
  }
}
