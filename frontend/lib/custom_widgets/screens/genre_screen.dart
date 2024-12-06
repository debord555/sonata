import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:sonata/custom_classes/db_helper.dart';
import 'package:sonata/custom_widgets/screens/genre_view_screen.dart';
import 'package:provider/provider.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Provider.of<Data>(context).genre_ids.length,
      itemBuilder: (context, index) => FutureBuilder(
        future: DbHelper.instance.getGenreDetails(Provider.of<Data>(context).genre_ids[index]),
        builder: (context, snapshot) {
          return (!snapshot.hasData)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GenreViewScreen(
                          genre_id: Provider.of<Data>(context).genre_ids[index],
                          genre_name: snapshot.data!["name"],
                        ),
                      ),
                    );
                  },
                  leading: const Icon(Icons.lightbulb_rounded),
                  title: Text("${snapshot.data!["name"]}"),
                  subtitle: Text("${snapshot.data!["num_songs"]} songs"),
                );
        },
      ),
    );
  }
}
