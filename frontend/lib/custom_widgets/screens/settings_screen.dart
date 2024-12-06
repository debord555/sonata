import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sonata/custom_classes/data.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set themeMode = {};
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Library",
          style: TextStyle(fontSize: 24),
        ),
        const Text("These paths will be searched for music files."),
        const SizedBox.square(
          dimension: 16,
        ),
        for (int i = 0; i < Provider.of<Data>(context).search_paths.length; i++)
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(Provider.of<Data>(context).search_paths[i]),
            trailing: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: const Icon(Icons.question_mark),
                    content: const Text("Are you sure you want to delete the path?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<Data>(context, listen: false).removeSearchPath(i);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Center(
          child: TextButton(
            onPressed: () async {
              String? newSearchPath = await FilePicker.platform.getDirectoryPath();
              if (newSearchPath != null) {
                if (Provider.of<Data>(context, listen: false).addSearchPath(newSearchPath) == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Search path already exists!")));
                }
              }
            },
            child: const Text("Add Folder"),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Divider(),
        ),
        const Text(
          "Theme",
          style: TextStyle(fontSize: 24),
        ),
        const Text("Set your app to light or dark themes. Or let Windows decide it for you."),
        const SizedBox.square(dimension: 16),
        Center(
          child: SegmentedButton(
            expandedInsets: const EdgeInsets.fromLTRB(32, 0, 32, 0),
            onSelectionChanged: (valueSet) {
              Provider.of<Data>(context, listen: false).setThemeMode(valueSet.first);
            },
            segments: const [
              ButtonSegment(value: 1, label: Text("Light")),
              ButtonSegment(value: 0, label: Text("System")),
              ButtonSegment(value: -1, label: Text("Dark")),
            ],
            selected: {Provider.of<Data>(context).themeMode},
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
          ),
        )
      ],
    );
  }
}
