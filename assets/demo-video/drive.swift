// Drives one take of the ScreenHint demo: hotkey, drag a selection over the Weather app's
// wind list, pause, drag the hint beside the window, pause, double-click it away, and put the
// cursor back where it started so the video loops.
//
// Coordinates are global CG points (top-left origin of the main display). The Dell sits above
// the laptop, so its y values are negative.
//
//   swift drive.swift setup   # park the cursor and make sure Weather isn't frontmost
//   swift drive.swift take    # perform the take (start the recording first)

import AppKit
import CoreGraphics

let rest = CGPoint(x: 1280, y: -420)           // where the cursor sits at the start and end
let selStart = CGPoint(x: 484, y: -938)         // top-left of the wind map card, with margin
let selEnd = CGPoint(x: 794, y: -466)           // bottom-right
let dragDX: CGFloat = 645                       // hint's left edge lands 48pt right of the window

let source = CGEventSource(stateID: .hidSystemState)

func post(_ type: CGEventType, _ p: CGPoint, clicks: Int64 = 1) {
    if type == .leftMouseDown { mark("down", p) }
    mark("pos", p)                                  // every position, for drawing the cursor afterwards
    let e = CGEvent(mouseEventSource: source, mouseType: type, mouseCursorPosition: p, mouseButton: .left)!
    e.setIntegerValueField(.mouseEventClickState, value: clicks)
    e.post(tap: .cghidEventTap)
}

func sleep(_ s: Double) { Thread.sleep(forTimeInterval: s) }

func ease(_ t: Double) -> Double { t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2 }

var cursor = rest

// Log of events (seconds since the take started) so click rings can be drawn in afterwards.
let t0 = Date()
var log: [String] = []
func mark(_ name: String, _ p: CGPoint) {
    log.append(String(format: "{\"event\":\"%@\",\"t\":%.3f,\"x\":%.1f,\"y\":%.1f}", name, Date().timeIntervalSince(t0), p.x, p.y))
}

/// Move (or drag, with the button down) along an eased path at 120 Hz.
func move(to p: CGPoint, over duration: Double, dragging: Bool = false) {
    let from = cursor
    let steps = max(1, Int(duration * 120))
    for i in 1...steps {
        let t = ease(Double(i) / Double(steps))
        let q = CGPoint(x: from.x + (p.x - from.x) * t, y: from.y + (p.y - from.y) * t)
        post(dragging ? .leftMouseDragged : .mouseMoved, q)
        sleep(duration / Double(steps))
    }
    cursor = p
}

func key(_ code: CGKeyCode, _ flags: CGEventFlags) {
    for down in [true, false] {
        let e = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down)!
        e.flags = flags
        e.post(tap: .cghidEventTap)
        sleep(0.05)
    }
}

switch CommandLine.arguments.dropFirst().first {
case "setup":
    NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first?.activate()
    sleep(0.3)
    // A small wiggle: macOS hides the pointer after keyboard input until the mouse moves.
    for dx in [0.0, 4, 8, 4, 0, -4, 0] {
        post(.mouseMoved, CGPoint(x: rest.x + dx, y: rest.y))
        sleep(0.03)
    }

case "take":
    sleep(1.0)                                              // opening beat

    mark("hotkey", cursor)
    key(19, [.maskCommand, .maskShift])                     // ⌘⇧2: ScreenHint's hotkey
    sleep(0.35)
    move(to: selStart, over: 0.9)
    sleep(0.25)
    post(.leftMouseDown, selStart)
    sleep(0.08)
    move(to: selEnd, over: 1.1, dragging: true)
    sleep(0.1)
    post(.leftMouseUp, selEnd)

    sleep(1.3)                                              // the hint appears; let it land

    let grab = CGPoint(x: (selStart.x + selEnd.x) / 2, y: (selStart.y + selEnd.y) / 2)
    move(to: grab, over: 0.5)
    sleep(0.15)
    post(.leftMouseDown, grab)
    sleep(0.08)
    let drop = CGPoint(x: grab.x + dragDX, y: grab.y)
    move(to: drop, over: 1.2, dragging: true)
    sleep(0.1)
    post(.leftMouseUp, drop)

    sleep(1.6)                                              // hint and original side by side

    post(.leftMouseDown, drop, clicks: 1); sleep(0.06)      // double-click to delete
    post(.leftMouseUp, drop, clicks: 1); sleep(0.1)
    post(.leftMouseDown, drop, clicks: 2); sleep(0.06)
    post(.leftMouseUp, drop, clicks: 2)

    sleep(0.7)
    move(to: rest, over: 0.8)
    sleep(1.0)                                              // closing beat, matches the opening
    mark("end", cursor)
    try! log.joined(separator: "\n").write(toFile: "events.jsonl", atomically: true, encoding: .utf8)

default:
    print("usage: drive.swift setup|take")
}
