import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteHistoryTile extends StatelessWidget {
  const DeleteHistoryTile({super.key});

  Future<void> _deleteGameHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje povijesti'),
        content: const Text('Jesi li siguran da želiš izbrisati povijest igara?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((key) => key.startsWith('saved_game_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Povijest igara je izbrisana.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(HugeIcons.strokeRoundedDelete01),
      title: const Text('Izbrisi povijest igara'),
      trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
      onTap: () => _deleteGameHistory(context),
    );
  }
}
