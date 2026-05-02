#!/bin/bash

# macOS app detection script with database-aware checks
apps_json=$1

python3 -c "
import json, sys, subprocess, shutil, os, socket

apps = json.loads(sys.argv[1])
results = []

# ── Database-specific config ──────────────────────────────────────────────────
DB_IDS = {'postgresql','mysql','redis','mongodb','cassandra','cockroachdb','elasticsearch','mariadb','neo4j','clickhouse'}

DB_PORTS = {
    'postgresql': 5432, 'mysql': 3306, 'redis': 6379, 'mongodb': 27017,
    'cassandra': 9042, 'cockroachdb': 26257, 'elasticsearch': 9200,
    'mariadb': 3306, 'neo4j': 7474, 'clickhouse': 8123,
}

# Homebrew service names
DB_BREW_SERVICES = {
    'postgresql': ['postgresql@17', 'postgresql@16', 'postgresql'],
    'mysql': ['mysql'],
    'redis': ['redis'],
    'mongodb': ['mongodb/brew/mongodb-community@8.0', 'mongodb-community'],
    'cassandra': ['cassandra'],
    'cockroachdb': ['cockroachdb/tap/cockroach'],
    'elasticsearch': ['elastic/tap/elasticsearch-full'],
    'mariadb': ['mariadb'],
    'neo4j': ['neo4j'],
    'clickhouse': ['clickhouse'],
}

# Known Homebrew cellar bin paths
DB_PATHS = {
    'postgresql': ['/opt/homebrew/opt/postgresql@17', '/usr/local/opt/postgresql@17'],
    'mysql': ['/opt/homebrew/opt/mysql', '/usr/local/opt/mysql'],
    'redis': ['/opt/homebrew/opt/redis', '/usr/local/opt/redis'],
    'mongodb': ['/opt/homebrew/opt/mongodb-community', '/usr/local/opt/mongodb-community'],
    'cassandra': ['/opt/homebrew/opt/cassandra', '/usr/local/opt/cassandra'],
    'cockroachdb': ['/opt/homebrew/bin/cockroach', '/usr/local/bin/cockroach'],
    'elasticsearch': ['/opt/homebrew/opt/elasticsearch-full', '/usr/local/opt/elasticsearch-full'],
    'mariadb': ['/opt/homebrew/opt/mariadb', '/usr/local/opt/mariadb'],
    'neo4j': ['/opt/homebrew/opt/neo4j', '/usr/local/opt/neo4j'],
    'clickhouse': ['/opt/homebrew/opt/clickhouse', '/usr/local/opt/clickhouse'],
}

def test_port(port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.5)
        r = s.connect_ex(('127.0.0.1', port))
        s.close()
        return r == 0
    except:
        return False

def test_brew_service(service_names):
    try:
        out = subprocess.check_output(['brew', 'services', 'list'], stderr=subprocess.DEVNULL).decode()
        for name in service_names:
            # Match service name prefix
            for line in out.splitlines():
                parts = line.split()
                if parts and (parts[0] == name or parts[0].startswith(name.split('/')[0])):
                    status = parts[1] if len(parts) > 1 else ''
                    if status in ('started', 'running'):
                        return 'Service running'
                    elif status == 'stopped':
                        return 'Service installed (stopped)'
    except:
        pass
    return None

def get_bundle_version(path):
    plist = os.path.join(path, 'Contents', 'Info.plist')
    if os.path.exists(plist):
        try:
            output = subprocess.check_output(['defaults', 'read', plist, 'CFBundleShortVersionString']).decode().strip()
            return output
        except:
            pass
    return 'Not detected'

for app in apps:
    is_installed = False
    version = 'Not detected'
    app_id = app.get('id', '')
    executable = app.get('executable_cmd', '')

    # ── Database-specific detection ─────────────────────────────────────────
    if app_id in DB_IDS:
        # a) Check brew services
        brew_status = test_brew_service(DB_BREW_SERVICES.get(app_id, []))
        if brew_status:
            is_installed = True
            version = brew_status

        # b) Check if port is open
        if not is_installed and app_id in DB_PORTS:
            if test_port(DB_PORTS[app_id]):
                is_installed = True
                version = f'Listening on port {DB_PORTS[app_id]}'

        # c) Check known Homebrew paths
        if not is_installed:
            for p in DB_PATHS.get(app_id, []):
                if os.path.exists(p):
                    is_installed = True
                    version = 'Installed (not running)'
                    break

        results.append({'id': app_id, 'installed': is_installed, 'version': version})
        continue

    # ── Standard app detection ──────────────────────────────────────────────
    # 1. Check PATH
    if executable and shutil.which(executable):
        is_installed = True
        try:
            ver_output = subprocess.check_output([executable, '--version'], stderr=subprocess.STDOUT).decode()
            version = ver_output.split('\n')[0].strip()
        except:
            pass

    # 2. Check /Applications
    if not is_installed or version == 'Not detected':
        search_name = app['program_name'].replace(' ', '')
        app_paths = [
            f'/Applications/{app[\"program_name\"]}.app',
            f'/Applications/{search_name}.app',
            os.path.expanduser(f'~/Applications/{app[\"program_name\"]}.app')
        ]
        for p in app_paths:
            if os.path.exists(p):
                is_installed = True
                version = get_bundle_version(p)
                break

    # 3. Use Spotlight mdfind
    if not is_installed or version == 'Not detected':
        try:
            query = f'kMDItemKind == \"Application\" && kMDItemFSName == \"*{app[\"program_name\"]}*\"'
            output = subprocess.check_output(['mdfind', query], stderr=subprocess.STDOUT).decode()
            paths = output.strip().split('\n')
            if paths and paths[0]:
                is_installed = True
                version = get_bundle_version(paths[0])
        except:
            pass

    results.append({'id': app_id, 'installed': is_installed, 'version': version})

print(json.dumps(results))
" "\$apps_json"
