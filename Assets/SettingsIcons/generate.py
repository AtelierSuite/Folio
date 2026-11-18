import math
import os
import sys

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "..", "App", "Folio", "Assets.xcassets", "SettingsIcons"
)
os.makedirs(OUT, exist_ok=True)


def svg(body, defs=""):
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120">'
        f"<defs>{defs}</defs>{body}</svg>"
    )


def grad(name, top, bottom, x1=0, y1=0, x2=0, y2=1):
    return (
        f'<linearGradient id="{name}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">'
        f'<stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/></linearGradient>'
    )


def background(top, bottom):
    return grad("bg", top, bottom), '<rect width="120" height="120" fill="url(#bg)"/>'


def white_background():
    return grad("bg", "#FFFFFF", "#ECECF0"), '<rect width="120" height="120" fill="url(#bg)"/>'


def gear_path(cx, cy, outer, inner, teeth, hole):
    points = []
    step = 2 * math.pi / teeth
    for index in range(teeth):
        base = index * step - math.pi / 2
        for offset, radius in ((-0.30, inner), (-0.17, outer), (0.17, outer), (0.30, inner)):
            angle = base + offset * step
            points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    path = "M" + " L".join(f"{px:.2f},{py:.2f}" for px, py in points) + "Z"
    path += (
        f"M{cx + hole},{cy} A{hole},{hole} 0 1,0 {cx - hole},{cy} A{hole},{hole} 0 1,0 {cx + hole},{cy}Z"
    )
    return path


def crescent(cx, cy, radius, cut_dx, cut_dy, cut_radius):
    bx, by = cx + cut_dx, cy + cut_dy
    distance = math.hypot(cut_dx, cut_dy)
    along = (radius**2 - cut_radius**2 + distance**2) / (2 * distance)
    height = math.sqrt(radius**2 - along**2)
    mx, my = cx + along * cut_dx / distance, cy + along * cut_dy / distance
    p1 = (mx + height * cut_dy / distance, my - height * cut_dx / distance)
    p2 = (mx - height * cut_dy / distance, my + height * cut_dx / distance)
    return (
        f"M{p1[0]:.2f},{p1[1]:.2f} A{radius},{radius} 0 1,0 {p2[0]:.2f},{p2[1]:.2f} "
        f"A{cut_radius},{cut_radius} 0 0,1 {p1[0]:.2f},{p1[1]:.2f}Z"
    )


def star(cx, cy, size):
    inner = size * 0.32
    points = []
    for index in range(8):
        radius = size if index % 2 == 0 else inner
        angle = index * math.pi / 4 - math.pi / 2
        points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    return "M" + " L".join(f"{px:.2f},{py:.2f}" for px, py in points) + "Z"


def bell(cx, top, width, height, fill):
    half = width / 2
    bottom = top + height
    return (
        f'<path d="M{cx},{top} C{cx + half * 0.72},{top} {cx + half * 0.78},{top + height * 0.3} '
        f"{cx + half * 0.78},{top + height * 0.55} L{cx + half * 0.8},{bottom - height * 0.14} "
        f"Q{cx + half},{bottom - height * 0.06} {cx + half},{bottom} L{cx - half},{bottom} "
        f"Q{cx - half},{bottom - height * 0.06} {cx - half * 0.8},{bottom - height * 0.14} "
        f"L{cx - half * 0.78},{top + height * 0.55} C{cx - half * 0.78},{top + height * 0.3} "
        f'{cx - half * 0.72},{top} {cx},{top}Z" fill="{fill}"/>'
        f'<circle cx="{cx}" cy="{bottom + height * 0.1}" r="{height * 0.13}" fill="{fill}"/>'
        f'<circle cx="{cx}" cy="{top - height * 0.02}" r="{height * 0.07}" fill="{fill}"/>'
    )


icons = {}

defs, bg = background("#A3A3AB", "#6E6E76")
icons["general"] = svg(
    bg
    + f'<path d="{gear_path(60, 60, 44, 34, 10, 13)}" fill="#E9E9EE" fill-rule="evenodd"/>'
    + '<circle cx="60" cy="60" r="24" fill="none" stroke="#B9B9C0" stroke-width="4"/>',
    defs,
)

defs, bg = background("#5AB0FF", "#1E6FE0")
icons["accounts"] = svg(
    bg
    + '<circle cx="60" cy="46" r="21" fill="#FFFFFF"/>'
    + '<path d="M18,120 C18,90 36,74 60,74 C84,74 102,90 102,120Z" fill="#FFFFFF"/>',
    defs,
)

defs, bg = white_background()
dots = ""
for row in range(3):
    for column in range(4):
        x = 27 + column * 22
        y = 60 + row * 19
        if (row, column) == (1, 2):
            dots += f'<circle cx="{x}" cy="{y}" r="9" fill="#FF3B30"/>'
        else:
            dots += f'<circle cx="{x}" cy="{y}" r="4.5" fill="#C7C7CC"/>'
icons["calendars"] = svg(
    bg
    + '<rect width="120" height="38" fill="#FF453A"/>'
    + '<rect x="30" y="14" width="8" height="14" rx="4" fill="#FFFFFF" fill-opacity="0.9"/>'
    + '<rect x="82" y="14" width="8" height="14" rx="4" fill="#FFFFFF" fill-opacity="0.9"/>'
    + dots,
    defs,
)

defs, bg = white_background()
rows = ""
for index, color in enumerate(("#FF9500", "#007AFF", "#FF3B30")):
    y = 30 + index * 30
    if index == 0:
        rows += f'<circle cx="28" cy="{y}" r="10" fill="{color}"/>'
        rows += f'<path d="M23,{y} l3.6,3.8 l7,-7.5" fill="none" stroke="#FFFFFF" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"/>'
    else:
        rows += f'<circle cx="28" cy="{y}" r="8.5" fill="none" stroke="{color}" stroke-width="3.4"/>'
    rows += f'<rect x="46" y="{y - 3.5}" width="{58 - index * 12}" height="7" rx="3.5" fill="#C7C7CC"/>'
icons["reminders"] = svg(bg + rows, defs)

defs, bg = background("#C99A6B", "#8E6239")
icons["workWeek"] = svg(
    bg
    + '<path d="M46,40 V32 a6,6 0 0,1 6,-6 h16 a6,6 0 0,1 6,6 V40" fill="none" stroke="#4A2F17" stroke-width="6"/>'
    + '<rect x="16" y="40" width="88" height="56" rx="10" fill="#5C3A1C"/>'
    + '<rect x="16" y="40" width="88" height="26" rx="10" fill="#6E4624"/>'
    + '<rect x="16" y="60" width="88" height="6" fill="#4A2F17"/>'
    + '<rect x="53" y="56" width="14" height="14" rx="3" fill="#F2C46D"/>',
    defs,
)

defs, bg = background("#6BE3CF", "#1FB59A")
icons["flexTime"] = svg(
    bg
    + '<path d="M95,60 A35,35 0 1,1 84.75,35.25" fill="none" stroke="#FFFFFF" stroke-width="7" stroke-linecap="round"/>'
    + '<path d="M80,20 L96,30 L80,44Z" fill="#FFFFFF" transform="rotate(8 88 32)"/>'
    + '<circle cx="60" cy="60" r="25" fill="#FFFFFF"/>'
    + '<path d="M60,44 V60 L71,67" fill="none" stroke="#1FB59A" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>',
    defs,
)

defs, bg = background("#FFFDF6", "#F4F0E2")
lines = "".join(
    f'<rect x="18" y="{y}" width="{width}" height="4" rx="2" fill="#D6D1C2"/>'
    for y, width in ((54, 84), (70, 84), (86, 84), (102, 52))
)
icons["notes"] = svg(
    bg
    + '<rect width="120" height="34" fill="#FFCC00"/>'
    + '<rect y="34" width="120" height="3" fill="#E6B400"/>'
    + lines,
    defs,
)

defs, bg = background("#FF6B8B", "#E8305A")
icons["notifications"] = svg(
    bg + bell(56, 26, 62, 60, "#FFFFFF") + '<circle cx="86" cy="32" r="13" fill="#FF3B30" stroke="#FFFFFF" stroke-width="4"/>',
    defs,
)

defs, bg = background("#FF7A70", "#E0352B")
icons["eventNotifications"] = svg(
    bg
    + '<rect x="18" y="22" width="70" height="70" rx="12" fill="#FFFFFF"/>'
    + '<path d="M18,40 V34 a12,12 0 0,1 12,-12 h46 a12,12 0 0,1 12,12 V40Z" fill="#FFB3AE"/>'
    + "".join(
        f'<circle cx="{32 + column * 14}" cy="{54 + row * 14}" r="3.6" fill="#D1D1D6"/>'
        for row in range(3)
        for column in range(4)
    )
    + '<circle cx="86" cy="86" r="22" fill="#FFCC00" stroke="#E0352B" stroke-width="5"/>'
    + bell(86, 74, 24, 20, "#FFFFFF"),
    defs,
)

defs, bg = background("#C08CFF", "#8A3FE0")
checks = ""
for index in range(3):
    y = 38 + index * 18
    checks += f'<circle cx="34" cy="{y}" r="5.5" fill="{"#8A3FE0" if index == 0 else "none"}" stroke="#8A3FE0" stroke-width="2.6"/>'
    checks += f'<rect x="46" y="{y - 2.5}" width="{36 - index * 8}" height="5" rx="2.5" fill="#D1D1D6"/>'
icons["reminderNotifications"] = svg(
    bg
    + '<rect x="18" y="22" width="70" height="70" rx="12" fill="#FFFFFF"/>'
    + checks
    + '<circle cx="86" cy="86" r="22" fill="#FFCC00" stroke="#8A3FE0" stroke-width="5"/>'
    + bell(86, 74, 24, 20, "#FFFFFF"),
    defs,
)

defs, bg = background("#FFB347", "#FF5E62")
icons["wakeUpAlarm"] = svg(
    bg
    + '<circle cx="60" cy="120" r="40" fill="#FFE27A" fill-opacity="0.55"/>'
    + '<path d="M26,40 a16,16 0 0,1 22,-16" fill="none" stroke="#FFFFFF" stroke-width="9" stroke-linecap="round"/>'
    + '<path d="M94,40 a16,16 0 0,0 -22,-16" fill="none" stroke="#FFFFFF" stroke-width="9" stroke-linecap="round"/>'
    + '<path d="M40,88 L32,100 M80,88 L88,100" stroke="#FFFFFF" stroke-width="7" stroke-linecap="round"/>'
    + '<circle cx="60" cy="62" r="32" fill="#FFFFFF"/>'
    + '<path d="M60,44 V62 L72,70" fill="none" stroke="#FF7A50" stroke-width="5.5" stroke-linecap="round" stroke-linejoin="round"/>',
    defs,
)

defs, bg = background("#E8F3DA", "#CFE6B8")
icons["travel"] = svg(
    bg
    + '<path d="M-5,88 C25,78 40,96 70,86 S110,70 125,74 V95 C105,90 90,104 70,104 S30,96 -5,108Z" fill="#7CC4F5"/>'
    + '<path d="M18,-5 C30,30 56,40 64,60 S70,100 96,125" fill="none" stroke="#FFFFFF" stroke-width="12"/>'
    + '<path d="M18,-5 C30,30 56,40 64,60 S70,100 96,125" fill="none" stroke="#FFC93C" stroke-width="7"/>'
    + '<path d="M84,16 C71,16 62,25 62,37 C62,52 84,72 84,72 C84,72 106,52 106,37 C106,25 97,16 84,16Z" fill="#FF3B30"/>'
    + '<circle cx="84" cy="37" r="8" fill="#FFFFFF"/>',
    defs,
)

defs, bg = background("#5DE07A", "#24B04A")
sweep = math.radians(250)
end_x = 60 + 30 * math.sin(sweep)
end_y = 66 - 30 * math.cos(sweep)
icons["countdowns"] = svg(
    bg
    + '<rect x="52" y="16" width="16" height="10" rx="3" fill="#FFFFFF"/>'
    + '<circle cx="60" cy="66" r="38" fill="#FFFFFF"/>'
    + f'<path d="M60,66 L60,36 A30,30 0 1,1 {end_x:.2f},{end_y:.2f}Z" fill="#34C759"/>'
    + '<circle cx="60" cy="66" r="4" fill="#FFFFFF"/>',
    defs,
)

defs, bg = white_background()
segments = ""
colors = ["#FF3B30", "#FF9500", "#FFCC00", "#A6DE3B", "#34C759"]
for index, color in enumerate(colors):
    start = math.pi + index * math.pi / 5 + 0.04
    end = math.pi + (index + 1) * math.pi / 5 - 0.04
    radius = 40
    x1, y1 = 60 + radius * math.cos(start), 82 + radius * math.sin(start)
    x2, y2 = 60 + radius * math.cos(end), 82 + radius * math.sin(end)
    segments += f'<path d="M{x1:.2f},{y1:.2f} A{radius},{radius} 0 0,1 {x2:.2f},{y2:.2f}" fill="none" stroke="{color}" stroke-width="14"/>'
needle_angle = math.pi + math.pi * 0.78
icons["focusLevel"] = svg(
    bg
    + segments
    + f'<path d="M60,82 L{60 + 34 * math.cos(needle_angle):.2f},{82 + 34 * math.sin(needle_angle):.2f}" stroke="#3A3A3C" stroke-width="5" stroke-linecap="round"/>'
    + '<circle cx="60" cy="82" r="8" fill="#3A3A3C"/>',
    defs,
)

defs, bg = background("#D7F75B", "#A5D610")
icons["workouts"] = svg(
    bg
    + '<g transform="rotate(-35 60 60)">'
    + '<rect x="30" y="54" width="60" height="12" rx="4" fill="#3A3A3C"/>'
    + '<rect x="14" y="34" width="16" height="52" rx="6" fill="#2C2C2E"/>'
    + '<rect x="90" y="34" width="16" height="52" rx="6" fill="#2C2C2E"/>'
    + '<rect x="4" y="44" width="12" height="32" rx="5" fill="#48484A"/>'
    + '<rect x="104" y="44" width="12" height="32" rx="5" fill="#48484A"/>'
    + "</g>",
    defs,
)

defs, bg = background("#4B46C8", "#1C1A5E")
icons["sleep"] = svg(
    bg
    + f'<path d="{crescent(56, 62, 34, 18, -14, 30)}" fill="#FFE27A"/>'
    + f'<path d="{star(88, 28, 8)}" fill="#FFFFFF"/>'
    + f'<path d="{star(100, 56, 5)}" fill="#FFFFFF" fill-opacity="0.85"/>'
    + f'<path d="{star(28, 22, 4)}" fill="#FFFFFF" fill-opacity="0.7"/>',
    defs,
)

defs, bg = background("#7FE0E0", "#2AAFB8")
icons["medications"] = svg(
    bg
    + '<g transform="rotate(-40 54 58)">'
    + '<path d="M54,40 H34 a18,18 0 0,0 0,36 H54Z" fill="#FFFFFF"/>'
    + '<path d="M54,40 H74 a18,18 0 0,1 0,36 H54Z" fill="#FF6B5E"/>'
    + "</g>"
    + '<circle cx="88" cy="88" r="16" fill="#FFFFFF"/>'
    + '<rect x="76" y="86" width="24" height="4" rx="2" fill="#2AAFB8" transform="rotate(-40 88 88)"/>',
    defs,
)

defs, bg = background("#5CC8FF", "#2D8CF0")
icons["weather"] = svg(
    bg
    + '<circle cx="44" cy="44" r="22" fill="#FFD60A"/>'
    + '<path d="M38,96 a18,18 0 0,1 2,-36 a24,24 0 0,1 44,-4 a20,20 0 0,1 4,40Z" fill="#FFFFFF"/>',
    defs,
)

defs, bg = white_background()
icons["search"] = svg(
    bg
    + '<path d="M74,74 L98,98" stroke="#636366" stroke-width="14" stroke-linecap="round"/>'
    + '<circle cx="52" cy="52" r="28" fill="#D5ECFF" stroke="#636366" stroke-width="9"/>'
    + '<path d="M38,46 a16,16 0 0,1 12,-11" fill="none" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>',
    defs,
)

defs, bg = background("#A3A3AB", "#6E6E76")
sliders = ""
for index, knob in enumerate((76, 40, 64)):
    y = 34 + index * 26
    sliders += f'<rect x="20" y="{y - 3}" width="80" height="6" rx="3" fill="#4F4F55"/>'
    sliders += f'<circle cx="{knob}" cy="{y}" r="10" fill="#FFFFFF"/>'
icons["advanced"] = svg(bg + sliders, defs)

defs, bg = background("#7AD957", "#3E9E2C")
spots = "".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#1C1C1E"/>' for x, y, r in ((46, 60, 6), (74, 60, 6), (50, 82, 5), (70, 82, 5)))
icons["debug"] = svg(
    bg
    + '<path d="M44,40 L32,26 M76,40 L88,26" stroke="#1C1C1E" stroke-width="4" stroke-linecap="round"/>'
    + '<circle cx="60" cy="42" r="14" fill="#1C1C1E"/>'
    + '<ellipse cx="60" cy="70" rx="30" ry="32" fill="#FF3B30"/>'
    + '<path d="M60,40 V102" stroke="#1C1C1E" stroke-width="3"/>'
    + spots,
    defs,
)

CONTENTS = """{
  "images" : [
    {
      "filename" : "%s.svg",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
"""

for name, content in icons.items():
    asset = "Settings" + name[0].upper() + name[1:]
    folder = os.path.join(OUT, asset + ".imageset")
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder, asset + ".svg"), "w") as handle:
        handle.write(content)
    with open(os.path.join(folder, "Contents.json"), "w") as handle:
        handle.write(CONTENTS % asset)
