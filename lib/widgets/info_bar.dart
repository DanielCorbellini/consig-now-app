import 'package:flutter/material.dart';

/// Widget reutilizável para exibir barra de informações com estatísticas
class InfoBar extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String mainText;
  final Color backgroundColor;
  final Color borderColor;
  final List<Widget> chips;

  const InfoBar({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.mainText,
    required this.backgroundColor,
    required this.borderColor,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              mainText,
              style: TextStyle(
                color: iconColor.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(width: 16),
              ...chips.map(
                (chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: chip,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
