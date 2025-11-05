import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool hasSwitch;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    this.hasSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: hasSwitch
          ? Switch(value: true, onChanged: (value) {}, activeThumbColor: Colors.purpleAccent)
          : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16.0),
      onTap: () {},
    );
  }
}
