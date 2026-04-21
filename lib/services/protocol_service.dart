import 'dart:io';

class ProtocolService {
  static const String protocolName = 'zerosetup';

  /// Automatically registers the custom URI protocol in the Windows registry (HKCU).
  /// This does not require administrative privileges.
  static Future<void> register() async {
    if (!Platform.isWindows) return;

    try {
      final String exePath = Platform.resolvedExecutable;
      final String registryPath = 'HKCU\\Software\\Classes\\$protocolName';
      final String commandPath = '$registryPath\\shell\\open\\command';

      // 1. Create the base protocol key
      await _runReg('add', [registryPath, '/f', '/ve', '/d', 'URL:$protocolName Protocol']);
      await _runReg('add', [registryPath, '/f', '/v', 'URL Protocol', '/d', '']);

      // 2. Create the shell open command key
      await _runReg('add', [commandPath, '/f', '/ve', '/d', '"$exePath" "%1"']);

      print('Protocol $protocolName registered successfully to $exePath');
    } catch (e) {
      print('Error registering protocol: $e');
    }
  }

  static Future<void> _runReg(String cmd, List<String> args) async {
    final result = await Process.run('reg', [cmd, ...args]);
    if (result.exitCode != 0) {
      throw Exception('Registry command failed: ${result.stderr}');
    }
  }
}
