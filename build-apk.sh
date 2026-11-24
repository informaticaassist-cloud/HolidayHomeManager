#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec > >(tee build-apk.log) 2>&1
npm install --no-audit --no-fund
npm run build
if [ ! -d android ]; then node node_modules/@capacitor/cli/bin/capacitor add android; fi
cp native/*.java android/app/src/main/java/com/holidayhomemanager/app/
node node_modules/@capacitor/cli/bin/capacitor sync android
sed -i 's/versionName "1.0"/versionName "0.1.0"/' android/app/build.gradle
(cd android && ./gradlew assembleDebug)
cp android/app/build/outputs/apk/debug/app-debug.apk HolidayHomeManager_v0.1.0.apk
unzip -t HolidayHomeManager_v0.1.0.apk
unzip -l HolidayHomeManager_v0.1.0.apk | grep resources.arsc
"$(find "${ANDROID_HOME:-$ANDROID_SDK_ROOT}/build-tools" -name apksigner | sort -V | tail -1)" verify --verbose HolidayHomeManager_v0.1.0.apk
