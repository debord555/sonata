import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:provider/provider.dart';

class QueueTile extends StatefulWidget {
  final int index;
  final int song_id;

  const QueueTile(this.index, this.song_id, {super.key});

  @override
  State<QueueTile> createState() => _QueueTileState();
}

class _QueueTileState extends State<QueueTile> {
  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    if (widget.index < Provider.of<Data>(context).now_playing_queue.length) {
      bgColor = (Provider.of<Data>(context).already_played[widget.index]) ? Theme.of(context).splashColor : null;
    }
    bgColor = (Provider.of<Data>(context).current_playing_index == widget.index) ? Theme.of(context).primaryColor.withOpacity(0.2) : bgColor;
    return FutureBuilder<Map<String, dynamic>>(
      future: DbHelper.instance.getSong(widget.song_id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () {
              Provider.of<Data>(context, listen: false).playQueueEntryNow(widget.index);
            },
            tileColor: bgColor,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image(
                image: snapshot.data!["album_art"],
                fit: BoxFit.contain,
              ),
            ),
            title: Text(snapshot.data!['title']),
            subtitle: Text(snapshot.data!['album'] + " - " + snapshot.data!['contributing_artists']),
            trailing: PopupMenuButton<int>(
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Provider.of<Data>(context, listen: false).deleteSongFromQueue(widget.index);
                    break;
                  case 1:
                    Provider.of<Data>(context, listen: false).playQueueEntryNext(widget.index);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Remove"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Play Next"),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
