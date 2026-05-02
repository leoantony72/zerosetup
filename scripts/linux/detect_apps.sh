#!/bin/bash

# Linux app detection script with version discovery and database-aware checks
apps_json=$1

if [ -z "$apps_json" ]; then
    echo "[]"
    exit
fi

python3 -c "
import json, sys, subprocess, shutil, os, socket

try:
    apps = json.loads(sys.argv[1])
except:
    print('[]')
    sys.exit(0)

# ── Database-specific config ──────────────────────────────────────────────────
DB_IDS = {'postgresql','mysql','redis','mongodb','cassandra','cockroachdb','elasticsearch','mariadb','neo4j','clickhouse'}

DB_PORTS = {
    'postgresql': 5432, 'mysql': 3306, 'redis': 6379, 'mongodb': 27017,
    'cassandra': 9042, 'cockroachdb': 26257, 'elasticsearch': 9200,
    'mariadb': 3306, 'neo4j': 7474, 'clickhouse': 8123,
}

DB_SERVICES = {
    'postgresql': ['postgresql', 'postgres'],
    'mysql': ['mysql', 'mysqld'],
    'redis': ['redis', 'redis-server'],
    'mongodb': ['mongod', 'mongodb'],
    'cassandra': ['cassandra'],
    'cockroachdb': ['cockroach', 'cockroachdb'],
    'elasticsearch': ['elasticsearch'],
    'mariadb': ['mariadb', 'mysql'],
    'neo4j': ['neo4j'],
    'clickhouse': ['clickhouse-server'],
}

DB_PATHS = {
    'postgresql': ['/var/lib/postgresql', '/usr/lib/postgresql'],
    'mysql': ['/var/lib/mysql', '/usr/bin/mysqld'],
    'redis': ['/var/lib/redis', '/usr/bin/redis-server'],
    'mongodb': ['/var/lib/mongodb', '/usr/bin/mongod'],
    'cassandra': ['/var/lib/cassandra', '/opt/cassandra'],
    'cockroachdb': ['/usr/local/bin/cockroach', '/var/lib/cockroach'],
    'elasticsearch': ['/var/lib/elasticsearch', '/usr/share/elasticsearch'],
    'mariadb': ['/var/lib/mysql', '/usr/bin/mariadbd'],
    'neo4j': ['/var/lib/neo4j', '/usr/share/neo4j'],
    'clickhouse': ['/var/lib/clickhouse', '/usr/bin/clickhouse-server'],
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

def test_service(service_names):
    for name in service_names:
        try:
            out = subprocess.check_output(['systemctl', 'is-active', name], stderr=subprocess.DEVNULL).decode().strip()
            if out in ('active', 'activating'):
                return name, 'Service running'
        except:
            pass
        try:
            out = subprocess.check_output(['systemctl', 'status', name], stderr=subprocess.DEVNULL).decode()
            if 'active (running)' in out or 'Loaded:' in out:
                return name, 'Service installed'
        except:
            pass
    return None, None

results = []

for app in apps:
    is_installed = False
    version = 'Not detected'
    executable = app.get('executable_cmd')
    app_id = app.get('id', '')

    # ── Database-specific detection ─────────────────────────────────────────
    if app_id in DB_IDS:
        # a) Check systemd service
        svc_names = DB_SERVICES.get(app_id, [])
        svc, svc_version = test_service(svc_names)
        if svc:
            is_installed = True
            version = svc_version

        # b) Check if port is listening
        if not is_installed and app_id in DB_PORTS:
            if test_port(DB_PORTS[app_id]):
                is_installed = True
                version = f'Listening on port {DB_PORTS[app_id]}'

        # c) Check known install paths
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
    if executable:
        path = shutil.which(executable)
        if path:
            is_installed = True
            try:
                ver_output = subprocess.check_output([executable, '--version'], stderr=subprocess.STDOUT).decode()
                version = ver_output.split('\n')[0].strip()
            except:
                pass

    # 2. Check dpkg
    if not is_installed or version == 'Not detected':
        try:
            cmd = ['dpkg-query', '-W', '-f=\${Status}|\${Version}', app_id]
            output = subprocess.check_output(cmd, stderr=subprocess.STDOUT).decode()
            status, ver = output.split('|')
            if 'install ok installed' in status:
                is_installed = True
                version = ver
        except:
            pass

    # 3. Check snap
    if not is_installed or version == 'Not detected':
        try:
            output = subprocess.check_output(['snap', 'list', app_id], stderr=subprocess.STDOUT).decode()
            lines = output.strip().split('\n')
            if len(lines) > 1:
                cols = lines[1].split()
                if len(cols) > 1:
                    is_installed = True
                    version = cols[1]
        except:
            pass

    # 4. Check common bin locations
    if not is_installed:
        for p in [f'/usr/bin/{executable}', f'/usr/local/bin/{executable}', f'/snap/bin/{executable}']:
            if executable and os.path.exists(p):
                is_installed = True
                break

    results.append({'id': app_id, 'installed': is_installed, 'version': version})

print(json.dumps(results))
" "\$apps_json"
