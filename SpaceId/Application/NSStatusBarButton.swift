
import Foundation
import Cocoa

extension NSStatusBarButton {
    
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    // Fix "overshoot" scroll and fall onto adjacent monitor (and can't keep scrolling)
    // Have bounds on min and max scrollable based on currently active monitor
    open override func scrollWheel(with: NSEvent) {
        
        // Find kb focused display ("current")
        let spaceIdentifier = SpaceIdentifier()
        let spaceInfo = spaceIdentifier.getSpaceInfo()
        let focusedDisplayIdentifier = spaceInfo.keyboardFocusSpace?.displayIdentifier
        let focusedFriendlySpaceBeforeSwitch = spaceInfo.keyboardFocusSpace?.number

        if (with.deltaY < 0) {  // Down
            // Make sure we aren't at last space for this display
            var lastSpaceSeenOnCurrentDisplay : Int?
            for space in spaceInfo.allSpaces {
                if (space.displayIdentifier == focusedDisplayIdentifier) {  // We have iterated our way to current display
                    lastSpaceSeenOnCurrentDisplay = space.number
                } else if (lastSpaceSeenOnCurrentDisplay != nil) {  // We are on the display "past" current
                    if (lastSpaceSeenOnCurrentDisplay != focusedFriendlySpaceBeforeSwitch) { // Current space is not last, move
                        shell("/usr/local/bin/chunkc", "tiling::desktop", "-f", "next")
                    }
                    return
                }
            }
            
            // Arriving here, our display is rightmost anyway, so just let it go normally
            shell("/usr/local/bin/chunkc", "tiling::desktop", "-f", "next")

        } else {  // Up
            // Make sure we aren't at first space for this display
            for space in spaceInfo.allSpaces {
                if (space.displayIdentifier == focusedDisplayIdentifier) {  // We have iterated our way to current display
                    if (space.number != focusedFriendlySpaceBeforeSwitch) {  // Current space is not first, move
                        shell("/usr/local/bin/chunkc", "tiling::desktop", "-f", "prev")
                    }
                    return
                }
            }
        }
    }
    
    open override func mouseDown(with: NSEvent) {
        // Hacky way to tell which was clicked
        let index = ((with.locationInWindow.x - 6) / 18) + 1
        shell("/usr/local/bin/chunkc", "tiling::desktop", "-f", String(Int(floor(index))))
    }

}
