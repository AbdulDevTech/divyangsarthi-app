#!/usr/bin/env bash
set -euo pipefail
echo "ensure_android.sh args: $@"
PROJECT_DIR="${1:-.}"
echo "Project dir: $PROJECT_DIR"
cd "$PROJECT_DIR"

# determine project name
PROJECT_NAME=""
if [ -f pubspec.yaml ]; then
  PROJECT_NAME=$(grep '^name:' pubspec.yaml | head -n1 | awk '{print $2}' || true)
fi
if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME=$(basename "$(pwd)")
fi
PROJECT_NAME=${PROJECT_NAME//-/_}
PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/[^a-zA-Z0-9_]/_/g' | tr '[:upper:]' '[:lower:]')
if echo "$PROJECT_NAME" | grep -q '^[0-9]'; then
  PROJECT_NAME="app_$PROJECT_NAME"
fi

MANIFEST_DIR=android/app/src/main
MANIFEST_FILE="$MANIFEST_DIR/AndroidManifest.xml"
mkdir -p "$MANIFEST_DIR"

if [ -f "$MANIFEST_FILE" ]; then
  echo "Found existing AndroidManifest.xml"
  if ! grep -q 'android.permission.INTERNET' "$MANIFEST_FILE"; then
    sed -i '/<manifest /a \    <uses-permission android:name="android.permission.INTERNET" \/>' "$MANIFEST_FILE" || true
    echo "Inserted INTERNET permission into existing manifest"
  else
    echo "INTERNET permission already present in manifest"
  fi
else
  cat > "$MANIFEST_FILE" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.$PROJECT_NAME">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="$PROJECT_NAME"
        android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF
  echo "Created AndroidManifest.xml with INTERNET permission at $MANIFEST_FILE"
fi

# Patch compileSdkVersion / targetSdkVersion to 34 if build.gradle exists
if [ -f android/app/build.gradle ]; then
  if grep -q 'compileSdkVersion' android/app/build.gradle; then
    sed -i 's/compileSdkVersion [0-9]\+/compileSdkVersion 34/' android/app/build.gradle || true
  fi
  if grep -q 'targetSdkVersion' android/app/build.gradle; then
    sed -i 's/targetSdkVersion [0-9]\+/targetSdkVersion 34/' android/app/build.gradle || true
  fi
  echo "Patched android/app/build.gradle (if present) to prefer SDK 34"
else
  echo "android/app/build.gradle not found; flutter create should generate it earlier"
fi

echo "ensure_android.sh finished"
