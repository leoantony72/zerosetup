import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../services/detection_service.dart';

/// Configuration data for a database field shown in the connection dialog.
class _DbField {
  final String label;
  final String key;
  final String defaultValue;
  final bool isPassword;
  final TextInputType inputType;

  const _DbField({
    required this.label,
    required this.key,
    required this.defaultValue,
    this.isPassword = false,
    this.inputType = TextInputType.text,
  });
}

/// Per-database default config fields.
const Map<String, List<_DbField>> _dbConfigs = {
  'postgresql': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: 'localhost'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '5432',    inputType: TextInputType.number),
    _DbField(label: 'Database', key: 'database', defaultValue: 'postgres'),
    _DbField(label: 'User',     key: 'user',     defaultValue: 'postgres'),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
  ],
  'mysql': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: 'localhost'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '3306',    inputType: TextInputType.number),
    _DbField(label: 'Database', key: 'database', defaultValue: ''),
    _DbField(label: 'User',     key: 'user',     defaultValue: 'root'),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
  ],
  'mariadb': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: 'localhost'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '3306',    inputType: TextInputType.number),
    _DbField(label: 'Database', key: 'database', defaultValue: ''),
    _DbField(label: 'User',     key: 'user',     defaultValue: 'root'),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
  ],
  'redis': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: '127.0.0.1'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '6379',    inputType: TextInputType.number),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
    _DbField(label: 'Database', key: 'db',       defaultValue: '0',       inputType: TextInputType.number),
  ],
  'mongodb': [
    _DbField(label: 'Host',           key: 'host',           defaultValue: 'localhost'),
    _DbField(label: 'Port',           key: 'port',           defaultValue: '27017',   inputType: TextInputType.number),
    _DbField(label: 'Database',       key: 'database',       defaultValue: 'test'),
    _DbField(label: 'User',           key: 'user',           defaultValue: ''),
    _DbField(label: 'Password',       key: 'password',       defaultValue: '',  isPassword: true),
  ],
  'cassandra': [
    _DbField(label: 'Host',      key: 'host',      defaultValue: '127.0.0.1'),
    _DbField(label: 'Port',      key: 'port',      defaultValue: '9042',    inputType: TextInputType.number),
    _DbField(label: 'Keyspace',  key: 'keyspace',  defaultValue: ''),
    _DbField(label: 'User',      key: 'user',      defaultValue: 'cassandra'),
    _DbField(label: 'Password',  key: 'password',  defaultValue: 'cassandra', isPassword: true),
  ],
  'cockroachdb': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: 'localhost'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '26257',   inputType: TextInputType.number),
    _DbField(label: 'Database', key: 'database', defaultValue: 'defaultdb'),
    _DbField(label: 'User',     key: 'user',     defaultValue: 'root'),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
  ],
  'elasticsearch': [
    _DbField(label: 'Host',     key: 'host',     defaultValue: 'localhost'),
    _DbField(label: 'Port',     key: 'port',     defaultValue: '9200',    inputType: TextInputType.number),
    _DbField(label: 'User',     key: 'user',     defaultValue: ''),
    _DbField(label: 'Password', key: 'password', defaultValue: '',  isPassword: true),
  ],
  'neo4j': [
    _DbField(label: 'Host',      key: 'host',      defaultValue: 'localhost'),
    _DbField(label: 'HTTP Port', key: 'http_port', defaultValue: '7474',    inputType: TextInputType.number),
    _DbField(label: 'Bolt Port', key: 'bolt_port', defaultValue: '7687',    inputType: TextInputType.number),
    _DbField(label: 'User',      key: 'user',      defaultValue: 'neo4j'),
    _DbField(label: 'Password',  key: 'password',  defaultValue: 'neo4j',   isPassword: true),
  ],
  'clickhouse': [
    _DbField(label: 'Host',      key: 'host',      defaultValue: 'localhost'),
    _DbField(label: 'HTTP Port', key: 'http_port', defaultValue: '8123',    inputType: TextInputType.number),
    _DbField(label: 'TCP Port',  key: 'tcp_port',  defaultValue: '9000',    inputType: TextInputType.number),
    _DbField(label: 'Database',  key: 'database',  defaultValue: 'default'),
    _DbField(label: 'User',      key: 'user',       defaultValue: 'default'),
    _DbField(label: 'Password',  key: 'password',   defaultValue: '',  isPassword: true),
  ],
};

/// Builds a human-readable connection string for the given database.
String _buildConnectionString(String dbId, Map<String, String> values) {
  final h = values['host'] ?? 'localhost';
  final p = values['port'] ?? '';
  final db = values['database'] ?? values['keyspace'] ?? '';
  final u = values['user'] ?? '';

  switch (dbId) {
    case 'postgresql':
      return 'postgresql://$u@$h:$p/$db';
    case 'mysql':
    case 'mariadb':
      return 'mysql://$u@$h:$p/$db';
    case 'redis':
      return 'redis://$h:$p/${values['db'] ?? '0'}';
    case 'mongodb':
      return u.isEmpty ? 'mongodb://$h:$p/$db' : 'mongodb://$u@$h:$p/$db';
    case 'cassandra':
      return 'cassandra://$h:$p${db.isNotEmpty ? '/$db' : ''}';
    case 'cockroachdb':
      return 'postgresql://$u@$h:$p/$db?sslmode=disable';
    case 'elasticsearch':
      return 'http://$h:$p';
    case 'neo4j':
      final bolt = values['bolt_port'] ?? '7687';
      return 'bolt://$u@$h:$bolt';
    case 'clickhouse':
      final httpPort = values['http_port'] ?? '8123';
      return 'http://$u@$h:$httpPort/$db';
    default:
      return '$h:$p';
  }
}

/// Shows the database connection config dialog.
class DatabaseConnectionDialog extends StatefulWidget {
  final Program program;

  const DatabaseConnectionDialog({super.key, required this.program});

  static Future<void> show(BuildContext context, Program program) {
    return showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(24),
          child: DatabaseConnectionDialog(program: program),
        ),
      ),
    );
  }

  @override
  State<DatabaseConnectionDialog> createState() => _DatabaseConnectionDialogState();
}

class _DatabaseConnectionDialogState extends State<DatabaseConnectionDialog> {
  late final List<_DbField> _fields;
  late final Map<String, TextEditingController> _controllers;
  final Map<String, bool> _obscured = {};
  bool _connecting = false;
  String? _connectionResult;
  bool _connectionSuccess = false;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _isRunning = DetectionService.isRunning(widget.program.id);
    _fields = _dbConfigs[widget.program.id] ?? [
      const _DbField(label: 'Host', key: 'host', defaultValue: 'localhost'),
      const _DbField(label: 'Port', key: 'port', defaultValue: '0', inputType: TextInputType.number),
    ];
    _controllers = {
      for (final f in _fields) f.key: TextEditingController(text: f.defaultValue),
    };
    for (final f in _fields) {
      if (f.isPassword) _obscured[f.key] = true;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _values =>
      {for (final f in _fields) f.key: _controllers[f.key]!.text};

  String get _connectionString => _buildConnectionString(widget.program.id, _values);

  Future<void> _testConnection() async {
    setState(() { _connecting = true; _connectionResult = null; });

    try {
      // Use dart:io to test TCP port
      final host = _controllers['host']?.text ?? 'localhost';
      final portStr = _controllers['port']?.text
          ?? _controllers['http_port']?.text
          ?? _controllers['bolt_port']?.text
          ?? '0';
      final port = int.tryParse(portStr) ?? 0;

      if (port > 0) {
        final socket = await Socket.connect(host, port,
            timeout: const Duration(seconds: 3));
        socket.destroy();
        setState(() {
          _connectionResult = 'Connection successful on $host:$port';
          _connectionSuccess = true;
        });
      } else {
        setState(() {
          _connectionResult = 'Invalid port number';
          _connectionSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _connectionResult = 'Could not connect: ${e.toString().split(']').last.trim()}';
        _connectionSuccess = false;
      });
    } finally {
      setState(() => _connecting = false);
    }
  }

  void _copyConnectionString() {
    Clipboard.setData(ClipboardData(text: _connectionString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection string copied!',
          style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.surfaceContainerLow),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isRunning) ...[
                      _buildFieldsGrid(),
                      const SizedBox(height: 20),
                      _buildConnectionStringRow(),
                    ] else ...[
                      _buildRunningStatus(),
                      const SizedBox(height: 20),
                      _buildConnectionStringRow(),
                    ],
                    if (_connectionResult != null) ...[
                      const SizedBox(height: 12),
                      _buildConnectionResult(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerLow),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cable_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.program.programName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                Text('Connection Configuration',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsGrid() {
    // Lay out fields in 2 columns where possible
    final rows = <Widget>[];
    final List<_DbField> normalFields = _fields.where((f) => !f.isPassword).toList();
    final List<_DbField> passwordFields = _fields.where((f) => f.isPassword).toList();

    // Pair normal fields into rows of 2
    for (int i = 0; i < normalFields.length; i += 2) {
      final left = normalFields[i];
      final right = i + 1 < normalFields.length ? normalFields[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildField(left)),
            if (right != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildField(right)),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    // Password fields full-width
    for (final f in passwordFields) {
      rows.add(_buildField(f));
      rows.add(const SizedBox(height: 12));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildField(_DbField field) {
    final ctrl = _controllers[field.key]!;
    final isObscured = _obscured[field.key] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: isObscured,
          keyboardType: field.inputType,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurface),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            hintText: field.defaultValue.isEmpty ? field.label : field.defaultValue,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: field.isPassword
                ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 16, color: AppColors.outline),
                    onPressed: () => setState(() => _obscured[field.key] = !isObscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStringRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connection String',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(_connectionString,
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11.5, color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
                ),
              ),
              IconButton(
                onPressed: _copyConnectionString,
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_rounded, size: 15),
                color: AppColors.outline,
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRunningStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Service is Running',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text('The ${widget.program.programName} instance is active and ready.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildConnectionResult() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _connectionSuccess
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _connectionSuccess
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _connectionSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
            size: 16,
            color: _connectionSuccess ? AppColors.primary : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_connectionResult!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: _connectionSuccess ? AppColors.primary : AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Row(
        children: [
          if (!_isRunning) ...[
            // Cancel/Close
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Close',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            // RUN (Start Service) button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await DetectionService.startService(widget.program.id);
                  if (success) {
                    setState(() {
                      _isRunning = true;
                      _connectionResult = null;
                    });
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text('RUN',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ] else ...[
            // Close button (Visible in running mode too for better UX)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Close',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            // STOP Service button
            OutlinedButton.icon(
              onPressed: () async {
                final success = await DetectionService.stopService(widget.program.id);
                if (success) {
                  setState(() {
                    _isRunning = false;
                    _connectionResult = null;
                    _connectionSuccess = false;
                  });
                }
              },
              icon: const Icon(Icons.stop_rounded, size: 16),
              label: Text('STOP',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(width: 6),
            // Test button
            OutlinedButton.icon(
              onPressed: _connecting ? null : _testConnection,
              icon: _connecting
                  ? const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Icon(Icons.bolt_rounded, size: 16),
              label: Text(_connecting ? 'Testing...' : 'Test',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const Spacer(),
            // RUN CLI button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openCli(),
                icon: const Icon(Icons.terminal_rounded, size: 14),
                label: Text('RUN CLI',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openCli() {
    final v = _values;
    final host = v['host'] ?? 'localhost';
    final port = v['port'] ?? v['bolt_port'] ?? v['http_port'] ?? '';
    final user = v['user'] ?? '';
    final db   = v['database'] ?? v['keyspace'] ?? '';

    final components = _buildCliCommand(host, port, user, db);
    if (components.isEmpty) return;

    try {
      if (Platform.isWindows) {
        // Use the list form with cmd.exe to let Dart handle quoting of each component correctly
        Process.start('cmd.exe', [
          '/c', 'start', '""', 'cmd', '/k', ...components
        ]);
      } else if (Platform.isMacOS) {
        // For macOS, we need to join them for the Terminal app
        final cliCmd = components.join(' ');
        Process.start('open', ['-a', 'Terminal', '--args', 'bash', '-c', '$cliCmd; exec bash']);
      } else {
        final cliCmd = components.join(' ');
        final terminals = ['gnome-terminal', 'konsole', 'xterm'];
        Process.start(terminals.first, ['--', 'bash', '-c', '$cliCmd; exec bash']);
      }
    } catch (_) {}

    Navigator.of(context).pop();
  }

  List<String> _buildCliCommand(String host, String port, String user, String db) {
    final binPath = DetectionService.getBinPath(widget.program.id);

    switch (widget.program.id) {
      case 'postgresql':
      case 'cockroachdb':
        String binary = 'psql';
        if (binPath != null) {
          final parent = p.dirname(binPath);
          final fullPath = p.join(parent, 'psql.exe');
          if (File(fullPath).existsSync()) binary = fullPath;
        }
        final args = ['-h', host, '-p', port, '-U', user];
        if (db.isNotEmpty) args.addAll(['-d', db]);
        return [binary, ...args];

      case 'mysql':
      case 'mariadb':
        String binary = 'mysql';
        if (binPath != null) {
          final parent = p.dirname(binPath);
          final fullPath = p.join(parent, 'mysql.exe');
          if (File(fullPath).existsSync()) binary = fullPath;
        }
        final args = ['-h', host, '-P', port];
        if (user.isNotEmpty) args.addAll(['-u', user]);
        args.add('-p'); // Prompt for password
        if (db.isNotEmpty) args.add(db);
        return [binary, ...args];

      case 'redis':
        final svc = DetectionService.getServiceName('redis');
        String binary = (svc == 'Memurai') ? 'memurai-cli' : 'redis-cli';
        if (binPath != null) {
          final parent = p.dirname(binPath);
          final exeName = (svc == 'Memurai') ? 'memurai-cli.exe' : 'redis-cli.exe';
          final fullPath = p.join(parent, exeName);
          if (File(fullPath).existsSync()) binary = fullPath;
        }
        return [binary, '-h', host, '-p', port];

      case 'mongodb':
        String binary = 'mongosh';
        if (binPath != null) {
          final parent = p.dirname(binPath);
          final fullPath = p.join(parent, 'mongosh.exe');
          if (File(fullPath).existsSync()) binary = fullPath;
        }
        final args = ['--host', host, '--port', port];
        if (db.isNotEmpty) args.add(db);
        return [binary, ...args];

      case 'cassandra':
        return ['cqlsh', host, port];
      case 'elasticsearch':
        return ['curl', '-X', 'GET', 'http://$host:$port/_cluster/health?pretty'];
      case 'neo4j':
        final boltPort = _controllers['bolt_port']?.text ?? '7687';
        return ['cypher-shell', '-a', 'bolt://$host:$boltPort', '-u', user];
      case 'clickhouse':
        final tcpPort = _controllers['tcp_port']?.text ?? '9000';
        final args = ['--host=$host', '--port=$tcpPort'];
        if (user.isNotEmpty) args.add('--user=$user');
        return ['clickhouse-client', ...args];
      default:
        // Split simple commands by space as a fallback
        return widget.program.executableCmd.split(' ');
    }
  }
}
