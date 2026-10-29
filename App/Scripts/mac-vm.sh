#!/bin/zsh
# Builds the Mac app and runs it in the Parallels VM "macOS", never on the host.
# Only one agent may use the VM at a time, so every command holds a lock.
#
#   Scripts/mac-vm.sh acquire <owner>    wait for the VM lock and take it
#   Scripts/mac-vm.sh deploy             build, copy into the VM and launch
#   Scripts/mac-vm.sh capture <file.png> screenshot the VM display
#   Scripts/mac-vm.sh run '<command>'    run a shell command in the VM as the user
#   Scripts/mac-vm.sh release            quit Folio in the VM and free the lock
set -e

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
VM=macOS
LOCK=/tmp/folio-parallels-vm.lock
DERIVED_DATA=${FOLIO_DERIVED_DATA:-/tmp/folio-dd-mac-vm-$USER}
APP=$DERIVED_DATA/Build/Products/Debug/Folio.app

vm() {
  local attempt
  for attempt in 1 2 3 4 5; do
    prlctl exec $VM --current-user "$1" && return 0
    sleep 1
  done
  return 1
}

# The VM has no provisioning profile, so the app is signed ad hoc without the
# entitlements that need one. Features behind them (iCloud, WeatherKit, HealthKit,
# Time Sensitive notifications) can't be tested in the VM.
sign() {
  local entitlements=/tmp/folio-vm-${1:t:r}.entitlements key
  cp $2 $entitlements
  for key in com.apple.developer.icloud-container-identifiers com.apple.developer.icloud-services \
    com.apple.developer.ubiquity-container-identifiers com.apple.developer.ubiquity-kvstore-identifier \
    com.apple.developer.weatherkit com.apple.developer.healthkit com.apple.developer.healthkit.access \
    com.apple.developer.usernotifications.time-sensitive com.apple.developer.siri aps-environment \
    com.apple.developer.aps-environment com.apple.application-identifier com.apple.developer.team-identifier; do
    /usr/libexec/PlistBuddy -c "Delete :$key" $entitlements 2>/dev/null || true
  done
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.app-sandbox bool true" $entitlements 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.get-task-allow bool true" $entitlements 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.files.user-selected.read-write bool true" $entitlements 2>/dev/null || true
  find $1/Contents/Frameworks -maxdepth 1 \( -name '*.framework' -o -name '*.dylib' \) 2>/dev/null \
    | while read -r nested; do codesign --force --sign - $nested; done
  codesign --force --sign - --entitlements $entitlements $1
}

require_lock() {
  [[ -d $LOCK ]] || { echo "Run '$0 acquire <owner>' first." >&2; exit 1; }
}

main() {
case $1 in
  acquire)
    until mkdir $LOCK 2>/dev/null; do
      echo "VM in use by $(cat $LOCK/owner 2>/dev/null), waiting..."
      sleep 30
    done
    echo ${2:-unknown} > $LOCK/owner
    echo "VM lock acquired by ${2:-unknown}."
    ;;
  deploy)
    require_lock
    xcodebuild build -project "$PROJECT_DIR/Folio.xcodeproj" -scheme Folio \
      -destination "platform=macOS" -derivedDataPath $DERIVED_DATA -quiet CODE_SIGNING_ALLOWED=NO
    sign $APP/Contents/PlugIns/FolioWidgets.appex "$PROJECT_DIR/Widgets/Widgets.entitlements"
    sign $APP "$PROJECT_DIR/Folio/Folio.entitlements"
    vm 'pkill -x Folio; rm -rf ~/FolioTest; mkdir -p ~/FolioTest' || true
    tar -C ${APP:h} -czf /tmp/folio-vm-app.tgz Folio.app
    local attempt
    for attempt in 1 2 3 4 5; do
      prlctl exec $VM --current-user 'cat > ~/FolioTest/Folio.tgz' < /tmp/folio-vm-app.tgz 2>/dev/null || true
      vm 'tar xzf ~/FolioTest/Folio.tgz 2>/dev/null -C ~/FolioTest && test -x ~/FolioTest/Folio.app/Contents/MacOS/Folio' && break
      sleep 2
    done
    vm 'xattr -cr ~/FolioTest/Folio.app; rm ~/FolioTest/Folio.tgz'
    vm '(open ~/FolioTest/Folio.app >/dev/null 2>&1 &)'
    echo "Folio launched in the VM."
    ;;
  capture)
    require_lock
    prlctl capture $VM --file ${2:-/tmp/folio-vm.png}
    ;;
  run)
    require_lock
    vm "$2"
    ;;
  release)
    vm 'pkill -x Folio' 2>/dev/null || true
    rm -rf $LOCK
    echo "VM lock released."
    ;;
  *)
    sed -n '2,10p' $0
    exit 1
    ;;
esac
}
main "$@"
