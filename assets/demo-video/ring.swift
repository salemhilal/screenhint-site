// Renders a click ring as a 60fps PNG sequence (200x200px, 2x): a brand-yellow ring that
// expands and fades out over 0.4s.
import AppKit
let frames = 24, size = 200
for i in 0..<frames {
    let t = Double(i) / Double(frames - 1)
    let ease = 1 - pow(1 - t, 3)
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let r = 18 + 58 * ease
    let alpha = 1 - t
    let c = CGPoint(x: size / 2, y: size / 2)
    let circle = CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)
    ctx.setFillColor(CGColor(srgbRed: 0.992, green: 0.765, blue: 0.192, alpha: 0.28 * alpha))
    ctx.fillEllipse(in: circle)
    ctx.setStrokeColor(CGColor(srgbRed: 0.992, green: 0.765, blue: 0.192, alpha: alpha))
    ctx.setLineWidth(6)
    ctx.strokeEllipse(in: circle.insetBy(dx: 3, dy: 3))
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: String(format: "ring/%03d.png", i)))
}
