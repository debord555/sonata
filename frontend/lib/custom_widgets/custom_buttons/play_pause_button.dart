import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<Data>(context).player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing;
        final processingState = playerState?.processingState;
        print("Processing state: $processingState");
        if (!(playing ?? false)) {
          return IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: () {
              if (Provider.of<Data>(context, listen: false).current_playing_id != -1) {
                Provider.of<Data>(context, listen: false).player.play();
              } else {
                if (Provider.of<Data>(context, listen: false).now_playing_queue.isNotEmpty) {
                  Provider.of<Data>(context, listen: false).forceTryToPlayNextSong();
                } else {
                  if (Provider.of<Data>(context, listen: false).song_ids.isNotEmpty) {
                    Provider.of<Data>(context, listen: false).playSongNow(Provider.of<Data>(context, listen: false).song_ids[0]);
                  }
                }
              }
            },
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.pause_rounded),
            onPressed: Provider.of<Data>(context, listen: false).player.pause,
          );
        }
      },
    );
  }
}
