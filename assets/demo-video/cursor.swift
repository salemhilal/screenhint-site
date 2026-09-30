// Renders a cursor layer for the start of take 8, before the recording picks up the real
// (enlarged) pointer: macOS's own arrow, matched to the real pointer's size, following the
// logged mouse path. One transparent PNG per source frame (from the trim start), sized to the
// cropped frame.
import AppKit

_ = NSApplication.shared
let args = CommandLine.arguments
let drawScale = Double(args[1])!                // applied to the 280x400 arrow image; 0.43 matches the real pointer
let frames = Int(args[2])!                       // how many frames to draw (until the real pointer appears)
let frameW = 2352, frameH = 1764                // cropped frame, 2 px per pt
let origin = CGPoint(x: 316, y: -1195)          // frame's top-left in global CG points
let fps = 60.0
let logOffset = 0.35                            // time since trim start + this = driver log time
let rest = CGPoint(x: 1280, y: -420)

struct Pos { let t: Double; let p: CGPoint }
let positions: [Pos] = try! String(contentsOfFile: "events.jsonl", encoding: .utf8)
    .split(separator: "\n").compactMap { line in
        guard let obj = try? JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any],
              obj["event"] as? String == "pos" else { return nil }
        return Pos(t: obj["t"] as! Double, p: CGPoint(x: obj["x"] as! Double, y: obj["y"] as! Double))
    }

func position(at time: Double) -> CGPoint {
    positions.last(where: { $0.t <= time + logOffset })?.p ?? rest
}

// The largest representation is 280x400 px; the arrow's black tip starts at (50, 49) in it.
var rect = NSRect(x: 0, y: 0, width: 280, height: 400)
let cursorImage = NSCursor.arrow.image.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
let px = NSSize(width: 280 * drawScale, height: 400 * drawScale)
let hot = CGPoint(x: 50 * drawScale + 0.5, y: 49 * drawScale + 0.5)   // +0.5px lines the tip up with the real pointer

for i in 0..<frames {
    let p = position(at: Double(i) / fps)
    // Top-left origin in frame pixels.
    let x = (p.x - origin.x) * 2 - hot.x
    let y = (p.y - origin.y) * 2 - hot.y
    let ctx = CGContext(data: nil, width: frameW, height: frameH, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(cursorImage, in: CGRect(x: x, y: Double(frameH) - y - px.height, width: px.width, height: px.height))
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: String(format: "cursor2/%04d.png", i)))
}
print("drew \(frames) frames at \(px) px")
