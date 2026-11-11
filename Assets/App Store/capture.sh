#!/bin/zsh
# Captures raw App Store screenshots into Raw/<device>/<language>/, for the iPhone and the iPad.
# Usage: ./capture.sh [languages...]   (defaults to en ja)
#        DEVICES=iPad ./capture.sh ja  (defaults to iPhone iPad)
#
# Each device and language gets a freshly erased simulator of the harness's own, with calendar and reminder access granted.
# The AppStoreScreenshots UI test then launches Folio once with -FolioScreenshotSamples, which seeds Sensei's week
# at Schale (calendars, reminders, notes, alarms and alert styles), and once more per shot with
# -FolioScreenshotStage <name>, made-up weather and made-up sleep. Run compose.swift afterwards to frame them.
set -e

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h:h}/App
BUNDLE_ID=com.tsubuzaki.Folio
DERIVED_DATA=/tmp/folio-screenshots-dd
LANGUAGES=($@)
(( $# )) || LANGUAGES=(en ja)
DEVICES=(${=DEVICES:-iPhone iPad})
typeset -A DEVICE_TYPES=(
  iPhone com.apple.CoreSimulator.SimDeviceType.iPhone-18-Pro-Max
  iPad com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB
)
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-27-2

# MARK: - Simulator

# One simulator of the harness's own per device, made on first use, so a capture never disturbs the ones used for
# development.
simulator() {
  local name="Folio Screenshots $1" udid
  udid=$(xcrun simctl list devices available | grep "$name (" | head -1 | grep -oE '[0-9A-F-]{36}' || true)
  if [[ -z $udid ]]; then
    udid=$(xcrun simctl create "$name" $DEVICE_TYPES[$1] $RUNTIME)
  fi
  echo $udid
}

# Erased, so the samples and Health data of the last language are gone. The language is set in the global
# preferences while it is shut down: a `defaults write` through simctl spawn does not survive the restart.
boot() {
  local locale=$([[ $2 == ja ]] && echo ja_JP || echo en_US)
  local preferences=~/Library/Developer/CoreSimulator/Devices/$1/data/Library/Preferences/.GlobalPreferences.plist
  xcrun simctl shutdown $1 2>/dev/null || true
  xcrun simctl erase $1
  # The first boot is what creates the preferences.
  xcrun simctl boot $1
  xcrun simctl bootstatus $1 -b >/dev/null
  xcrun simctl shutdown $1
  plutil -replace AppleLanguages -json "[\"$2\"]" "$preferences"
  plutil -replace AppleLocale -string $locale "$preferences"
  xcrun simctl boot $1
  xcrun simctl bootstatus $1 -b >/dev/null
  # The iPad's status bar shows the date as well, and simctl gets the weekday of an overridden time wrong.
  if [[ $3 == iPad ]]; then
    status_bar $1
  else
    status_bar $1 $(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 09:41:00" +%s)
  fi
}

# Fixed at a moment given in seconds since 1970, if any, which also sets the Lock Screen's date. simctl only
# takes it in UTC with fractional seconds.
status_bar() {
  local time=()
  [[ -n $2 ]] && time=(--time "$(date -u -r $2 +%Y-%m-%dT%H:%M:%S.000Z)")
  xcrun simctl status_bar $1 override $time \
    --batteryState discharging --batteryLevel 100 \
    --cellularMode active --cellularBars 4 --wifiBars 3 --operatorName ""
}

# MARK: - Build

xcodebuild build-for-testing -project "$PROJECT_DIR/Folio.xcodeproj" -scheme Folio \
  -destination "generic/platform=iOS Simulator" -derivedDataPath $DERIVED_DATA -quiet
APP=$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Folio.app
XCTESTRUN=$(ls $DERIVED_DATA/Build/Products/*.xctestrun | head -1)

# Prints only the assertion that failed, if any; -quiet would hide it. The whole log is kept in /tmp.
run_test_once() {
  local log=/tmp/folio-screenshots-${3:h:t}-$2-$4.log test_status=0
  TEST_RUNNER_SCREENSHOT_DIR=$3 TEST_RUNNER_SCREENSHOT_LANGUAGE=$2 \
    xcodebuild test-without-building -xctestrun $XCTESTRUN -destination "id=$1" \
    -only-testing:FolioUITests/AppStoreScreenshots/$4 \
    -test-timeouts-enabled YES -maximum-test-execution-time-allowance 900 >$log 2>&1 || test_status=$?
  grep -E "error: -\[" $log || true
  return $test_status
}

# MARK: - Capture

for device in $DEVICES; do
  udid=$(simulator $device)
  for language in $LANGUAGES; do
    raw_dir="$SCRIPT_DIR/Raw/$device/$language"
    mkdir -p "$raw_dir"
    boot $udid $language $device
    xcrun simctl install $udid $APP
    xcrun simctl privacy $udid grant calendar $BUNDLE_ID
    xcrun simctl privacy $udid grant reminders $BUNDLE_ID
    # UI tests on a freshly booted simulator now and then miss a tap, so a failed run is given one more go.
    if run_test_once $udid $language "$raw_dir" testScreens || run_test_once $udid $language "$raw_dir" testScreens; then
      echo "captured $device/$language"
    else
      echo "failed to capture $device/$language"
    fi
    # The App Store shows the countdown only on the iPhone, where Live Activities are always on.
    [[ $device == iPhone ]] || continue
    # The Live Activity shows the event's real start time, so the Lock Screen shows the real time and date too.
    # An overridden time would also set the date, and simctl gets its weekday wrong.
    xcrun simctl status_bar $udid clear
    status_bar $udid
    if run_test_once $udid $language "$raw_dir" testCountdown; then
      echo "captured $device/$language countdown"
    else
      echo "failed to capture $device/$language countdown"
    fi
  done
  xcrun simctl shutdown $udid
done
