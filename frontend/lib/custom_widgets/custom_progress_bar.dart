import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_classes/data.dart';

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<Data>(context).player.positionStream,
      builder: (context, snapshot) {
        return ProgressBar(
          progress: snapshot.data ?? Duration.zero,
          total: Provider.of<Data>(context).player.duration ?? Duration.zero,
          timeLabelLocation: TimeLabelLocation.sides,
          onSeek: (duration) {
            Provider.of<Data>(context, listen: false).player.seek(duration);
          },
        );
      },
    );
  }
}
