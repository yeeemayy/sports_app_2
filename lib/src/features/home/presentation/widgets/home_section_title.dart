import 'package:flutter/material.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

class HomeSectionTitle extends StatelessWidget {
  final String? icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;
  const HomeSectionTitle({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Row(
        spacing: 10,
        children: [
          CircleAvatar(radius: 20, child: icon != null ? Image.asset(icon!, height: 20) : null),
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) Text(subtitle!),
              ],
            ),
          ),
          // if (onPressed != null)
          //   IconButton(
          //     onPressed: onPressed,
          //     icon: Icon(Icons.play_circle_fill_outlined),
          //     color: Colors.grey.shade300,
          //     style: IconButton.styleFrom(padding: EdgeInsets.zero),
          //     constraints: BoxConstraints(),
          //     visualDensity: VisualDensity(vertical: -4),
          //   ),
        ],
      ),
    );
  }
}
