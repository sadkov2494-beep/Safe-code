import 'package:flutter/material.dart';

import '../models/safe_tool.dart';

class ToolPanel extends StatelessWidget {
  const ToolPanel({super.key, required this.tools, required this.onUseTool});

  final List<SafeTool> tools;
  final ValueChanged<SafeTool> onUseTool;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tool = tools[index];
          final icon = switch (tool) {
            SafeTool.fingerprintScanner => Icons.fingerprint,
            SafeTool.thermalViewer => Icons.thermostat,
            SafeTool.decryptor => Icons.key_off_outlined,
            SafeTool.analyzer => Icons.analytics_outlined,
            SafeTool.stethoscope => Icons.graphic_eq,
          };
          return ActionChip(
            avatar: Icon(icon, size: 18),
            label: Text(tool.shortTitle),
            onPressed: () => onUseTool(tool),
          );
        },
      ),
    );
  }
}
