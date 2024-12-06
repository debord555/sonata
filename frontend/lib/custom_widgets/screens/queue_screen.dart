import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_widgets/tiles/queue_tile.dart';
import 'package:provider/provider.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return (Provider.of<Data>(context).now_playing_queue.isNotEmpty)
        ? ListView.builder(
            itemBuilder: (context, index) => QueueTile(index, Provider.of<Data>(context).now_playing_queue[index]),
            itemCount: Provider.of<Data>(context).now_playing_queue.length,
          )
        : const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_off, color: Colors.grey,),
                Text("Queue is empty"),
              ],
            ),
          );
  }
}
