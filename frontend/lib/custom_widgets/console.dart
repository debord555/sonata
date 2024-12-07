import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/custom_buttons/play_pause_button.dart';
import 'package:sonata/custom_widgets/custom_buttons/repeat_button.dart';
import 'package:sonata/custom_widgets/custom_buttons/shuffle_button.dart';
import 'package:sonata/custom_widgets/custom_progress_bar.dart';
import 'package:provider/provider.dart';

class Console extends StatelessWidget {
  const Console({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).splashColor,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CustomProgressBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder(
                  future: getCurrentSongDetails(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image(
                              image: snapshot.data!["album_art"],
                              height: 50,
                            ),
                          ),
                          //Image(image: snapshot.data!["album_art"], height: 50,),
                          const SizedBox.square(dimension: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!["title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("${snapshot.data!["contributing_artists"]} - ${snapshot.data!["album"]}"),
                            ],
                          )
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: (Provider.of<Data>(context).rewind_stack.isNotEmpty)
                          ? () {
                              Provider.of<Data>(context, listen: false).playPreviousSong();
                            }
                          : null,
                    ),
                    const PlayPauseButton(),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: (Provider.of<Data>(context).now_playing_queue.isNotEmpty)
                          ? () {
                              Provider.of<Data>(context, listen: false).forceTryToPlayNextSong();
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_rounded),
                      onPressed: (Provider.of<Data>(context).player.playerState.playing ?? false)
                          ? () {
                              Provider.of<Data>(context, listen: false).stopPlaying();
                            }
                          : null,
                    ),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepeatButton(),
                    ShuffleButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getCurrentSongDetails(BuildContext context) async {
    Map<String, dynamic> answer = (Provider.of<Data>(context).current_playing_id == -1)
        ? {
            "id": -1,
            "title": "Not Playing",
            "track_number": -1,
            "disc_number": -1,
            "album": "NA",
            "album_artist": "NA",
            "contributing_artists": "NA",
            "location": "NA",
            "album_art_location": null,
            "album_art": const AssetImage(
              "assets/images/album_placeholder.jpg",
            )
          }
        : await DbHelper.instance.getSong(Provider.of<Data>(context).current_playing_id);
    return answer;
  }
}
