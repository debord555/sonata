import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return (Provider.of<Data>(context).shuffle)
        ? IconButton(
            onPressed: Provider.of<Data>(context, listen: false).toggleShuffle,
            icon: const Icon(
              Icons.shuffle_rounded,
              //color: Theme.of(context).primaryColor,
            ),
          )
        : IconButton(
            onPressed: Provider.of<Data>(context, listen: false).toggleShuffle,
            icon: const Icon(
              Icons.shuffle_on_rounded,
              //color: Colors.grey,
            ),
          );
  }
}
