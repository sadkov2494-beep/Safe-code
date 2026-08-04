enum SafeTool {
  fingerprintScanner,
  thermalViewer,
  decryptor,
  analyzer,
  stethoscope,
}

extension SafeToolLabel on SafeTool {
  String get title => switch (this) {
    SafeTool.fingerprintScanner => 'Сканер отпечатков',
    SafeTool.thermalViewer => 'Тепловизор',
    SafeTool.decryptor => 'Дешифратор',
    SafeTool.analyzer => 'Анализатор',
    SafeTool.stethoscope => 'Прослушка',
  };

  String get shortTitle => switch (this) {
    SafeTool.fingerprintScanner => 'Отпечатки',
    SafeTool.thermalViewer => 'Тепло',
    SafeTool.decryptor => 'Дешифр.',
    SafeTool.analyzer => 'Анализ',
    SafeTool.stethoscope => 'Звук',
  };
}
