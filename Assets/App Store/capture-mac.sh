#!/bin/zsh
# Captures raw Mac App Store screenshots into Raw/Mac/<language>/, in the Parallels VM "macOS", never on this Mac.
# Usage: ./capture-mac.sh [languages...]   (defaults to en ja)
#
# Holds the VM lock from App/Scripts/mac-vm.sh for the whole run, deploys a debug build, then launches Folio once with
# -FolioScreenshotSamples to seed Sensei's week at Schale and once more per shot with -FolioScreenshotStage <name>.
# The VM can't capture its own screen, so the host captures it and crop.swift cuts out the window, which is set to
# 1280 × 800 points: 2560 × 1600 pixels on the VM's Retina display. Run compose.swift afterwards to frame them.
set -e

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h:h}/App
MAC_VM=$PROJECT_DIR/Scripts/mac-vm.sh
LANGUAGES=($@)
(( $# )) || LANGUAGES=(en ja)
WORK=$(mktemp -d /tmp/folio-mac-screenshots.XXXXXX)
# Where the window goes, in points from the top left of the VM's screen, and its size and corner radius.
WINDOW_ORIGIN="{115, 50}"
WINDOW_SIZE="{1280, 800}"
CORNER_RADIUS=26
SHOTS=(01-week 02-lists 03-notes 04-notifications)
typeset -A STAGES=(01-week week 02-lists lists 03-notes notes 04-notifications notifications)

# The VM is shared, so its own notes are set aside while the samples are shown, and put back at the end.
NOTES_DIR='~/Library/Containers/com.tsubuzaki.Folio/Data/Documents'
NOTES_BACKUP='~/FolioScreenshotNotesBackup'

$MAC_VM acquire "App Store screenshots"
finish() {
  $MAC_VM run "pkill -x Folio; mkdir -p $NOTES_DIR; \
    find $NOTES_BACKUP -maxdepth 1 -type f -exec mv -f {} $NOTES_DIR/ \\; 2>/dev/null; rmdir $NOTES_BACKUP 2>/dev/null; true"
  $MAC_VM release
  rm -rf $WORK
}
trap finish EXIT

vm() {
  $MAC_VM run "$1"
}

# MARK: - Build

FOLIO_DERIVED_DATA=/tmp/folio-screenshots-mac-dd $MAC_VM deploy
swiftc -O "$SCRIPT_DIR/crop.swift" -o $WORK/crop

# Accepts whatever access prompt is up. Its buttons come in no fixed order and it has no default button, so Allow is
# found as the named button that isn't Don't Allow, in the VM's Japanese or in English.
prlctl exec macOS --current-user 'cat > /tmp/folio-allow.applescript' <<'EOF'
tell application "System Events" to tell process "UserNotificationCenter"
	if (count of windows) > 0 then
		repeat with candidate in buttons of window 1
			set buttonName to name of candidate
			if buttonName is not missing value and buttonName does not contain "しない" and buttonName does not contain "Don" then
				click candidate
				exit repeat
			end if
		end repeat
	end if
end tell
EOF

# Each ad hoc build is a new app to privacy, which keeps whatever was last chosen for reminders without asking again.
# tccutil refuses to run from a VM shell, so Terminal runs it, and the next launch asks afresh.
prlctl exec macOS --current-user 'cat > /tmp/folio-reset-access.command; chmod +x /tmp/folio-reset-access.command' <<'EOF'
#!/bin/zsh
tccutil reset Calendar com.tsubuzaki.Folio
tccutil reset Reminders com.tsubuzaki.Folio
touch /tmp/folio-reset-access.done
osascript -e 'quit app "Terminal"' &
EOF

reset_access() {
  vm 'rm -f /tmp/folio-reset-access.done; open -a Terminal /tmp/folio-reset-access.command'
  local waited
  for waited in {1..20}; do
    prlctl exec macOS --current-user 'test -f /tmp/folio-reset-access.done' 2>/dev/null && return
    sleep 1
  done
  echo "couldn't reset calendar and reminders access" >&2
}

# MARK: - Steps

# Folio opened with `open -n` from a VM shell starts without a window, so it is opened again to make one.
launch() {
  local language=$1 stage=$2 locale=$([[ $1 == ja ]] && echo ja_JP || echo en_US)
  vm "pkill -x Folio; sleep 1; open -n ~/FolioTest/Folio.app --args -AppleLanguages '($language)' \
    -AppleLocale $locale -NSRequiresAquaSystemAppearance YES -ApplePersistenceIgnoreState YES \
    -FolioSkipOnboarding -FolioSampleWeather -FolioScreenshotStage $stage $3; sleep 3; open ~/FolioTest/Folio.app"
  local attempt
  for attempt in 1 2 3 4; do
    sleep 2
    vm 'osascript /tmp/folio-allow.applescript' >/dev/null
  done
  vm "osascript -e 'tell application \"Folio\" to activate' \
    -e 'tell application \"System Events\" to tell process \"Folio\" to set position of window 1 to $WINDOW_ORIGIN' \
    -e 'tell application \"System Events\" to tell process \"Folio\" to set size of window 1 to $WINDOW_SIZE'"
  # Long enough for the samples to load and the window to settle at its new size.
  sleep 5
}

# Captures the frontmost Folio window into the given file.
capture() {
  local frame
  frame=$(vm "osascript -e 'tell application \"System Events\" to tell process \"Folio\" to get {position, size} of window 1'")
  prlctl capture macOS --file $WORK/screen.png >/dev/null
  $WORK/crop $WORK/screen.png "$1" ${(s:, :)frame} $CORNER_RADIUS
}

# MARK: - Capture

vm "mkdir -p $NOTES_BACKUP $NOTES_DIR; find $NOTES_DIR -maxdepth 1 -type f \\( -name '*.md' -o -name '*.markdown' \\) \
  -exec mv -n {} $NOTES_BACKUP/ \\;"
for language in $LANGUAGES; do
  raw_dir="$SCRIPT_DIR/Raw/Mac/$language"
  mkdir -p "$raw_dir"
  reset_access
  launch $language week -FolioScreenshotSamples
  # Seeding writes the calendars, reminders, notes and alert styles; give it time to finish before quitting.
  sleep 5
  echo "seeded Mac/$language"

  for shot in $SHOTS; do
    launch $language $STAGES[$shot]
    capture "$raw_dir/$shot.png"
    if [[ $shot == 04-notifications ]]; then
      # The per-calendar settings open over the calendar window, in a Settings window of their own.
      vm "osascript -e 'tell application \"System Events\" to tell process \"Folio\" to keystroke \",\" using command down'"
      sleep 4
      capture "$raw_dir/$shot-extra.png"
    fi
    echo "captured Mac/$language/$shot"
  done
done
