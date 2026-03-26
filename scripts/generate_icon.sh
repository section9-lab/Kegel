#!/bin/bash
set -e

# Generate a Kegel icon with chrysanthemum flower 🌼 on transparent background
# Create a temporary Swift script to generate the icon

cat > /tmp/generate_kegel_icon.swift << 'EOF'
import AppKit
import CoreGraphics
import CoreText

let size: CGFloat = 1024
// macOS icon grid: ~80% of canvas for the icon body, with ~10% padding on each side
let padding: CGFloat = size * 0.1
let iconSize: CGFloat = size - padding * 2

let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()

// No background - transparent by default

// Draw chrysanthemum flower emoji centered (original color - yellow)
let center = CGPoint(x: size / 2, y: size / 2)
let fontSize: CGFloat = iconSize * 0.7

// Create attributed string with flower emoji - no color override to keep original yellow
let flowerEmoji = "🌼"
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: fontSize)
]
let attributedString = NSAttributedString(string: flowerEmoji, attributes: attributes)

// Calculate text bounds to center it
let textSize = attributedString.size()
let textRect = NSRect(
    x: center.x - textSize.width / 2,
    y: center.y - textSize.height / 2,
    width: textSize.width,
    height: textSize.height
)

// Draw the emoji
attributedString.draw(in: textRect)

image.unlockFocus()

// Save as PNG (preserves transparency)
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    try? pngData.write(to: URL(fileURLWithPath: "/tmp/kegel_icon_1024.png"))
}
EOF

swift /tmp/generate_kegel_icon.swift

# Generate iconset
mkdir -p App/Kegel.iconset
cd App/Kegel.iconset

sips -z 16 16 /tmp/kegel_icon_1024.png --out icon_16x16.png
sips -z 32 32 /tmp/kegel_icon_1024.png --out icon_16x16@2x.png
sips -z 32 32 /tmp/kegel_icon_1024.png --out icon_32x32.png
sips -z 64 64 /tmp/kegel_icon_1024.png --out icon_32x32@2x.png
sips -z 128 128 /tmp/kegel_icon_1024.png --out icon_128x128.png
sips -z 256 256 /tmp/kegel_icon_1024.png --out icon_128x128@2x.png
sips -z 256 256 /tmp/kegel_icon_1024.png --out icon_256x256.png
sips -z 512 512 /tmp/kegel_icon_1024.png --out icon_256x256@2x.png
sips -z 512 512 /tmp/kegel_icon_1024.png --out icon_512x512.png
sips -z 1024 1024 /tmp/kegel_icon_1024.png --out icon_512x512@2x.png

cd ../..
iconutil -c icns App/Kegel.iconset -o App/KegelTimer.icns

echo "Icon generated at App/KegelTimer.icns"
