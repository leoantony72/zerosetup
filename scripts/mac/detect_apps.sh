#!/bin/bash

# macOS app detection script with version discovery
apps_json=$1

python3 -c "
import json, sys, subprocess, shutil, os

apps = json.loads(sys.argv[1])
results = []

def get_bundle_version(path):
    plist = os.path.join(path, 'Contents', 'Info.plist')
    if os.path.exists(plist):
        try:
            # Simple plist parsing for version
            output = subprocess.check_output(['defaults', 'read', plist, 'CFBundleShortVersionString']).decode().strip()
            return output
        except:
            pass
    return 'Not detected'

for app in apps:
    is_installed = False
    version = 'Not detected'
    
    # 1. Check PATH
    if shutil.which(app['executable_cmd']):
        is_installed = True
        try:
            ver_output = subprocess.check_output([app['executable_cmd'], '--version'], stderr=subprocess.STDOUT).decode()
            version = ver_output.split('\n')[0].strip()
        except:
            pass
    
    # 2. Check /Applications
    if not is_installed or version == 'Not detected':
        search_name = app['program_name'].replace(' ', '')
        app_paths = [
            f'/Applications/{app["program_name"]}.app',
            f'/Applications/{search_name}.app',
            os.path.expanduser(f'~/Applications/{app["program_name"]}.app')
        ]
        for p in app_paths:
            if os.path.exists(p):
                is_installed = True
                version = get_bundle_version(p)
                break

    # 3. Use Spotlight mdfind
    if not is_installed or version == 'Not detected':
        try:
            query = f'kMDItemKind == \"Application\" && kMDItemFSName == \"*{app["program_name"]}*\"'
            output = subprocess.check_output(['mdfind', query], stderr=subprocess.STDOUT).decode()
            paths = output.strip().split('\n')
            if paths and paths[0]:
                is_installed = True
                version = get_bundle_version(paths[0])
        except:
            pass

    results.append({'id': app['id'], 'installed': is_installed, 'version': version})

print(json.dumps(results))
" "$apps_json"
