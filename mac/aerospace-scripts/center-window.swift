import Cocoa
import CoreGraphics

// Get actual screen size
guard let mainScreen = NSScreen.main else {
    print("Could not get main screen")
    exit(1)
}
let screenFrame = mainScreen.visibleFrame
let screenWidth = screenFrame.width
let screenHeight = screenFrame.height
let menuBarHeight = mainScreen.frame.height - screenFrame.height

// Target size: 75% of screen
let targetW = screenWidth * 0.75
let targetH = screenHeight * 0.75

// Target position (centered)
let targetX = (screenWidth - targetW) / 2
let targetY = menuBarHeight + (screenHeight - targetH) / 2

// Get frontmost application
guard let frontApp = NSWorkspace.shared.frontmostApplication else {
    print("Could not get frontmost app")
    exit(1)
}
let frontAppName = frontApp.localizedName ?? "Unknown"
let frontPid = frontApp.processIdentifier

let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
    print("Failed to get window list")
    exit(1)
}

// Find windows from the frontmost app that are on-screen and NOT already centered
var candidates: [(pid: Int32, x: Double, y: Double, w: Double, h: Double)] = []

for window in windowList {
    guard let pid = window["kCGWindowOwnerPID"] as? Int32,
          pid == frontPid,
          let bounds = window["kCGWindowBounds"] as? [String: Any],
          let x = bounds["X"] as? Double,
          let y = bounds["Y"] as? Double,
          let w = bounds["Width"] as? Double,
          let h = bounds["Height"] as? Double else { continue }
    
    // Skip windows that are off the visible screen (on non-existent monitors)
    if x >= Double(screenWidth) { continue }
    
    // Skip very small windows (likely UI elements, not real windows)
    if w < 100 || h < 100 { continue }
    
    // Skip windows already at target center position (within tolerance)
    if abs(x - Double(targetX)) < 20 && abs(y - Double(targetY)) < 20 &&
       abs(w - Double(targetW)) < 20 && abs(h - Double(targetH)) < 20 {
        continue
    }
    
    candidates.append((pid: pid, x: x, y: y, w: w, h: h))
}

guard let floating = candidates.first else {
    print("No \(frontAppName) window to center")
    exit(1)
}

print("Found \(frontAppName) window at (\(Int(floating.x)),\(Int(floating.y))) size \(Int(floating.w))x\(Int(floating.h))")
print("Resizing to \(Int(targetW))x\(Int(targetH)) and centering at (\(Int(targetX)),\(Int(targetY)))")

// Move via accessibility API
let appElement = AXUIElementCreateApplication(floating.pid)
var windowsRef: CFTypeRef?
let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

if result == .success, let windows = windowsRef as? [AXUIElement] {
    for win in windows {
        var posRef: CFTypeRef?
        AXUIElementCopyAttributeValue(win, kAXPositionAttribute as CFString, &posRef)
        if let posVal = posRef {
            var pos = CGPoint.zero
            AXValueGetValue(posVal as! AXValue, .cgPoint, &pos)
            
            // Match by position
            if abs(pos.x - CGFloat(floating.x)) < 10 && abs(pos.y - CGFloat(floating.y)) < 10 {
                // Center first
                var newPos = CGPoint(x: targetX, y: targetY)
                let newPosVal = AXValueCreate(.cgPoint, &newPos)!
                AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, newPosVal)
                
                // Then resize
                var newSize = CGSize(width: targetW, height: targetH)
                let newSizeVal = AXValueCreate(.cgSize, &newSize)!
                AXUIElementSetAttributeValue(win, kAXSizeAttribute as CFString, newSizeVal)
                
                // Re-center after resize (size change might shift position)
                AXUIElementSetAttributeValue(win, kAXPositionAttribute as CFString, newPosVal)
                print("Resized and centered!")
                exit(0)
            }
        }
    }
}

print("Could not move window")
exit(1)
