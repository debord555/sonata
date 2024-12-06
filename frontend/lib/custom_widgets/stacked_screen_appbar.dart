import 'package:flutter/material.dart';

class StackedScreenAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const StackedScreenAppbar(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        onPressed: Navigator.of(context).pop,
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
