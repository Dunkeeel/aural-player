import Cocoa

/**
 Window accessors for convenience/conciseness
 */
extension NSWindow {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    /** X co-ordinate of location */
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    /** Y co-ordinate of location */
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var remainingHeight: CGFloat {
        return (NSScreen.main!.visibleFrame.height - self.height)
    }
    
    var remainingWidth: CGFloat {
        return (NSScreen.main!.visibleFrame.width - self.width)
    }
    
    func topRight(_ deltaX: CGFloat = 0, _ deltaY: CGFloat = 0) -> CGPoint {
        //return self.frame.origin.applying(CGAffineTransform(translationX: self.width, y: self.height))
        return CGPoint(x: self.frame.maxX + deltaX, y: self.frame.maxY + deltaY)
    }
    
    func topLeft(_ deltaX: CGFloat = 0, _ deltaY: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.frame.minX + deltaX, y: self.frame.maxY + deltaY)
    }
    
    func bottomRight(_ deltaX: CGFloat = 0, _ deltaY: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.frame.maxX + deltaX, y: self.frame.minY + deltaY)
    }
    
    func bottomLeft(_ deltaX: CGFloat = 0, _ deltaY: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.frame.minX + deltaX, y: self.frame.minY + deltaY)
    }
    
}
