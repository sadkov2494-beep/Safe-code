enum PanelMarkType { fingerprint, heat, scratch, worn, dust }

class PanelMark {
  const PanelMark({
    required this.digit,
    required this.type,
    required this.label,
  });

  final String digit;
  final PanelMarkType type;
  final String label;
}
