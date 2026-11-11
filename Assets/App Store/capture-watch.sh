#!/bin/zsh
# Captures Apple Watch App Store screenshots into Watch/<language>/. They go to the App Store as captured, with no
# frame or text, so compose.swift leaves them alone.
# Usage: ./capture-watch.sh [languages...]   (defaults to en ja)
#
# Each language gets a freshly erased watch simulator of the harness's own. Folio Mini is launched once per shot with
# -FolioScreenshotSamples, which shows the same week as the iPhone shots, since EventKit can't add events on watchOS.
set -e

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h:h}/App
BUNDLE_ID=com.tsubuzaki.Folio.Mini
DERIVED_DATA=/tmp/folio-screenshots-watch-dd
LANGUAGES=($@)
(( $# )) || LANGUAGES=(en ja)
# 416 × 496, one of the sizes App Store Connect takes for the watch.
DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-11-46mm
RUNTIME=com.apple.CoreSimulator.SimRuntime.watchOS-27-2
SHOTS=(01-timeline 02-day 03-two-days)
typeset -A MODES=(01-timeline timeline 02-day day 03-two-days twoDays)

# MARK: - Simulator

simulator() {
  local name="Folio Screenshots Watch" udid
  udid=$(xcrun simctl list devices available | grep "$name (" | head -1 | grep -oE '[0-9A-F-]{36}' || true)
  if [[ -z $udid ]]; then
    udid=$(xcrun simctl create "$name" $DEVICE_TYPE $RUNTIME)
  fi
  echo $udid
}

# Erased, with the language set in the global preferences while it is shut down, as in capture.sh.
boot() {
  local locale=$([[ $2 == ja ]] && echo ja_JP || echo en_US)
  local preferences=~/Library/Developer/CoreSimulator/Devices/$1/data/Library/Preferences/.GlobalPreferences.plist
  xcrun simctl shutdown $1 2>/dev/null || true
  xcrun simctl erase $1
  xcrun simctl boot $1
  xcrun simctl bootstatus $1 -b >/dev/null
  xcrun simctl shutdown $1
  plutil -replace AppleLanguages -json "[\"$2\"]" "$preferences"
  plutil -replace AppleLocale -string $locale "$preferences"
  xcrun simctl boot $1
  xcrun simctl bootstatus $1 -b >/dev/null
}

# MARK: - Build

xcodebuild build -project "$PROJECT_DIR/Folio.xcodeproj" -scheme FolioMini \
  -destination "generic/platform=watchOS Simulator" -derivedDataPath $DERIVED_DATA -quiet
APP=$DERIVED_DATA/Build/Products/Debug-watchsimulator/FolioMini.app

# MARK: - Capture

udid=$(simulator)
for language in $LANGUAGES; do
  out_dir="$SCRIPT_DIR/Watch/$language"
  mkdir -p "$out_dir"
  boot $udid $language
  xcrun simctl install $udid $APP
  for shot in $SHOTS; do
    xcrun simctl launch --terminate-running-process $udid $BUNDLE_ID \
      -AppleLanguages "($language)" -AppleLocale $([[ $language == ja ]] && echo ja_JP || echo en_US) \
      -FolioScreenshotSamples -WatchViewMode $MODES[$shot] >/dev/null
    # Long enough for the events to load and the timeline to scroll to now.
    sleep 6
    xcrun simctl io $udid screenshot --type=png "$out_dir/$shot.png" >/dev/null
    echo "captured Watch/$language/$shot"
  done
done
xcrun simctl shutdown $udid
