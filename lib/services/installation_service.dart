import 'dart:async';
import 'dart:io';
import '../models/program.dart';

class InstallationService {
  // Simulates or handles actual installation progress
  static Stream<double> install(Program program) async* {
    double progress = 0.0;
    
    // 1. Initializing
    yield 0.1;
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2. Fetching script path based on OS
    String scriptPath = '';
    String executable = '';
    List<String> arguments = [];

    if (Platform.isWindows) {
      scriptPath = program.windowsScript;
      executable = 'powershell.exe';
      arguments = ['-ExecutionPolicy', 'Bypass', '-File', scriptPath];
    } else if (Platform.isLinux) {
      scriptPath = program.linuxScript;
      executable = 'bash';
      arguments = [scriptPath];
    } else if (Platform.isMacOS) {
      scriptPath = program.macScript;
      executable = 'bash';
      arguments = [scriptPath];
    }

    // 3. Simulated progress while waiting for process (since real stdout parsing is complex)
    // In a real app, you'd parse stdout for percentage strings if the installer provides them.
    final processFuture = Process.run(executable, arguments);
    
    // Simulate progress filling up to 90% while process runs
    while (progress < 0.9) {
      await Future.delayed(const Duration(milliseconds: 800));
      progress += 0.05;
      if (progress > 0.9) progress = 0.9;
      yield progress;
    }

    // Wait for actual process to finish
    final result = await processFuture;
    
    if (result.exitCode != 0) {
      throw Exception('Installation failed (Code ${result.exitCode}): ${result.stderr}');
    }

    // 4. Completed
    yield 1.0;
  }
}
