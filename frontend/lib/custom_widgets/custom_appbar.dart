import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/misc/constants.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        screen_names[Provider.of<Data>(context).screen],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const DrawerButton(),
      actions: [
        Visibility(
          visible: (Provider.of<Data>(context).screen != SEARCH_SCREEN),
          child: IconButton(
            onPressed: () {
              Provider.of<Data>(context, listen: false).updateScreen(SEARCH_SCREEN);
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ),
        IconButton(
            onPressed: () {
              //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refreshing library... The app may lag.")));
              Provider.of<Data>(context, listen: false).update(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refreshing complete!")));
            },
            icon: const Icon(Icons.refresh_rounded)),
      ],
      elevation: 1.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
