#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec > >(tee build-apk.log) 2>&1
npm install --no-audit --no-fund
npm run build
if [ ! -d android ]; then node node_modules/@capacitor/cli/bin/capacitor add android; fi
cp native/*.java android/app/src/main/java/com/holidayhomemanager/app/
node node_modules/@capacitor/cli/bin/capacitor sync android
python3 - <<'PY'
import xml.etree.ElementTree as E
p='android/app/src/main/AndroidManifest.xml'
a='{http://schemas.android.com/apk/res/android}'
E.register_namespace('android',a[1:-1])
t=E.parse(p);r=t.getroot()
if not any(x.get(a+'name')=='android.permission.POST_NOTIFICATIONS' for x in r.findall('uses-permission')): E.SubElement(r,'uses-permission',{a+'name':'android.permission.POST_NOTIFICATIONS'})
app=r.find('application')
if not any(x.get(a+'name')=='.ReminderReceiver' for x in app.findall('receiver')): E.SubElement(app,'receiver',{a+'name':'.ReminderReceiver',a+'exported':'false'})
t.write(p,encoding='utf-8',xml_declaration=True)
PY
if [ -n "${HHM_KEYSTORE_B64:-}" ]; then
  mkdir -p "$HOME/.android"
  printf '%s' "$HHM_KEYSTORE_B64" | base64 -d > "$HOME/.android/debug.keystore"
  chmod 600 "$HOME/.android/debug.keystore"
fi
sed -i 's/versionCode 1/versionCode 7/' android/app/build.gradle
sed -i 's/versionName "1.0"/versionName "0.6.0"/' android/app/build.gradle
(cd android && ./gradlew assembleDebug)
cp android/app/build/outputs/apk/debug/app-debug.apk HolidayHomeManager_v0.6.0.apk
unzip -t HolidayHomeManager_v0.6.0.apk
unzip -l HolidayHomeManager_v0.6.0.apk | grep resources.arsc
"$(find "${ANDROID_HOME:-$ANDROID_SDK_ROOT}/build-tools" -name apksigner | sort -V | tail -1)" verify --verbose HolidayHomeManager_v0.6.0.apk
