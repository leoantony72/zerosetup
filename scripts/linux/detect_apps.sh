#!/bin/bash

# Linux app detection script with version discovery
apps_json=$1

if [ -z "$apps_json" ]; then
    echo "[]"
    exit
fi

python3 -c "
import json, sys, subprocess, shutil, os

try:
    apps = json.loads(sys.argv[1])
except:
    print('[]')
    sys.exit(0)

results = []

for app in apps:
    is_installed = False
    version = 'Not detected'
    executable = app.get('executable_cmd')
    
    # 1. Check PATH
    if executable:
        path = shutil.which(executable)
        if path:
            is_installed = True
            try:
                # Common flag for version
                ver_output = subprocess.check_output([executable, '--version'], stderr=subprocess.STDOUT).decode()
                version = ver_output.split('\n')[0].strip()
            except:
                pass
    
    # 2. Check dpkg
    if not is_installed or version == 'Not detected':
        try:
            cmd = ['dpkg-query', '-W', '-f=${Status}|${Version}', app['id']]
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
            output = subprocess.check_output(['snap', 'list', app['id']], stderr=subprocess.STDOUT).decode()
            lines = output.strip().split('\n')
            if len(lines) > 1:
                cols = lines[1].split()
                if len(cols) > 1:
                    is_installed = True
                    version = cols[1]
        except:
            pass

    # 4. Check common bin locations if not in PATH
    if not is_installed:
        alt_paths = [
            f'/usr/bin/{executable}',
            f'/usr/local/bin/{executable}',
            f'/snap/bin/{executable}'
        ]
        for p in alt_paths:
            if executable and os.path.exists(p):
                is_installed = True
                break

    results.append({'id': app['id'], 'installed': is_installed, 'version': version})

print(json.dumps(results))
" "$apps_json"
