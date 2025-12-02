import 'package:flutter/material.dart';

/// Widget reutilizável para o header da tabela com gradiente
class TableHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const TableHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon = Icons.table_chart_outlined,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.green;
    Color color1;
    Color color2;

    if (effectiveColor is MaterialColor) {
      color1 = effectiveColor.shade600;
      color2 = effectiveColor.shade400;
    } else {
      color1 = effectiveColor;
      color2 = effectiveColor.withOpacity(0.8);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
