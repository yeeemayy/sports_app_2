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
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Row(
          spacing: 10,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 20,
              child: icon != null ? Image.asset(icon!, height: 20) : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            if (onPressed != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
