/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

let padding:CGFloat = 0;

public enum VerticalPosition:Int{
    case top = 1
    case center = 2
    case bottom = 3
}

// Base class for all horizontal slider cells
@IBDesignable class CustomSliderCells: NSSlider {
    
    fileprivate var sliderCell:HorizontalSliderCell = HorizontalSliderCell()
    
    @IBInspectable var bufferStartValue:Double = 0
    @IBInspectable var bufferEndValue:Double = 0
    
    @IBInspectable var barRadius: CGFloat {return 1}
    @IBInspectable var barGradient: NSGradient {return Colors.sliderBarGradient}
    @IBInspectable var baseColor:NSColor = NSColor.lightGray
    @IBInspectable var barInsetX: CGFloat {return 0}
    @IBInspectable var barInsetY: CGFloat {return 0}
    
    @IBInspectable var knobWidth: CGFloat {return 10}
    @IBInspectable var knobHeightOutsideBar: CGFloat {return 2}
    @IBInspectable var knobRadius: CGFloat {return 1}
    @IBInspectable var knobColor: NSColor {return Colors.sliderKnobColor}
    
    @IBInspectable var borderWidth: Double = 0.5
    @IBInspectable var sliderHeight: Double = 2
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        baseColor.set()
        let rect = self.bounds.insetBy(dx: CGFloat(borderWidth)+padding, dy: CGFloat(borderWidth))
        let height = CGFloat(sliderHeight)
        let radius = height/2
        var sliderRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.height/2-radius), width: rect.width, height: rect.width) //default center
        let path = NSBezierPath()
        path.move(to: CGPoint(x: sliderRect.minX, y: sliderRect.minY+height))
        path.line(to: sliderRect.origin)
        path.line(to: CGPoint(x: sliderRect.maxX, y: sliderRect.minY))
        path.line(to: CGPoint(x: sliderRect.maxX, y: sliderRect.minY+height))
        path.line(to: CGPoint(x: sliderRect.minX, y: sliderRect.minY+height))
        baseColor.setStroke()
        path.lineWidth = CGFloat(borderWidth)
        path.stroke()
        path.addClip()
        
        var fillHeight = sliderRect.size.height-borderWidth.CGFloatValue
        if fillHeight < 0 {
            fillHeight = 0
        }
        
        let fillRect = CGRect(
            x: sliderRect.origin.x + sliderRect.size.width*CGFloat(bufferStartValue),
            y: sliderRect.origin.y + borderWidth.CGFloatValue/2,
            width: sliderRect.size.width*CGFloat(bufferEndValue-bufferStartValue),
            height: fillHeight)
        
        NSColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).setFill()
        
        NSBezierPath(rect: fillRect).fill()
        
    }
}

extension Double{
    var CGFloatValue: CGFloat {
        return CGFloat(self)
    }
}
