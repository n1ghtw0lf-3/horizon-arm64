#!/bin/bash
set -e
MC_DIR="$HOME/.minecraft"
VER="26.3"
mkdir -p "$MC_DIR/versions/$VER" "$MC_DIR/libraries" "$MC_DIR/assets/indexes" "$MC_DIR/assets/objects"
curl -sL "https://piston-meta.mojang.com/v1/packages/ead839cbccf0ddf013c3f935f2840080b5cb0d26/26.3.json" -o "$MC_DIR/versions/$VER/$VER.json"
CLIENT_URL=$(python3 -c "import json; print(json.load(open('$MC_DIR/versions/$VER/$VER.json'))['downloads']['client']['url'])")
curl -sL "$CLIENT_URL" -o "$MC_DIR/versions/$VER/$VER.jar"
python3 -c "
import json, os, urllib.request
data = json.load(open('$MC_DIR/versions/$VER/$VER.json'))
for lib in data['libraries']:
    art = lib.get('downloads',{}).get('artifact',{})
    if not art.get('url'): continue
    path = '$MC_DIR/libraries/' + art['path']
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if not os.path.exists(path): urllib.request.urlretrieve(art['url'], path)
"
python3 -c "
import json, os, urllib.request
data = json.load(open('$MC_DIR/versions/$VER/$VER.json'))
obj = data['assetIndex']
os.makedirs('$MC_DIR/assets/indexes', exist_ok=True)
urllib.request.urlretrieve(obj['url'], '$MC_DIR/assets/indexes/' + obj['id'] + '.json')
idx = json.load(open('$MC_DIR/assets/indexes/' + obj['id'] + '.json'))
for name, o in idx['objects'].items():
    h = o['hash']
    path = f'$MC_DIR/assets/objects/{h[:2]}/{h}'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        urllib.request.urlretrieve(f'https://resources.download.minecraft.net/{h[:2]}/{h}', path)
print(f'Assets: {len(idx[\"objects\"])} files')
"
mkdir -p "$HOME/Downloads"
SERVER_URL=$(python3 -c "import json; print(json.load(open('$MC_DIR/versions/$VER/$VER.json'))['downloads']['server']['url'])")
curl -sL "$SERVER_URL" -o "$HOME/Downloads/server-26.3.jar"
echo "Setup done."
