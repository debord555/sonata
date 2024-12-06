import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Provider.of<Data>(context).repeat) {
      case 1:
        return IconButton(
          onPressed: Provider.of<Data>(context, listen: false).changeRepeat,
          icon: const Icon(
            Icons.repeat_one_on_rounded,
            //color: Theme.of(context).primaryColor,
          ),
        );
      case 2:
        return IconButton(
          onPressed: Provider.of<Data>(context, listen: false).changeRepeat,
          icon: const Icon(
            Icons.repeat_on_rounded,
            
          ),
        );
      default:
        return IconButton(
          onPressed: Provider.of<Data>(context, listen: false).changeRepeat,
          icon: const Icon(
            Icons.repeat_rounded,
            //color: Colors.grey,
          ),
        );
    }
  }
}
