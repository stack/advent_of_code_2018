import Foundation

public class ColorGenerator {
    let maxColors: CGFloat
    var saturationValue: CGFloat
    
    let stepFactor: CGFloat
    var currentHue: CGFloat
    
    public init(maxColors: Int, saturationValue: CGFloat) {
        self.maxColors = CGFloat(maxColors)
        self.saturationValue = saturationValue
        stepFactor = 360.0 / CGFloat(maxColors)
        currentHue = 0.0
    }
    
    public func makeNextColor() -> CGColor {
        // Get the next HSV values
        let s: CGFloat = saturationValue
        let v: CGFloat = saturationValue
        let h = currentHue
        
        // Increment the hue
        currentHue = (currentHue + stepFactor).truncatingRemainder(dividingBy: 360.0)
        
        // Conver to RGB
        let c = v * s
        let x = c * (1.0 - abs((h / 60.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = v - c
        
        var r, g, b: CGFloat
        if h >= 0.0 && h < 60.0 {
            r = c
            g = x
            b = 0.0
        } else if h >= 0.0 && h < 120.0 {
            r = x
            g = c
            b = 0.0
        } else if h >= 120.0 && h < 180.0 {
            r = 0.0
            g = c
            b = x
        } else if h >= 180.0 && h < 240.0 {
            r = 0.0
            g = x
            b = c
        } else if h >= 240.0 && h < 300.0 {
            r = x
            g = 0.0
            b = c
        } else {
            r = c
            g = 0.0
            b = x
        }
        
        r += m
        g += m
        b += m
        
        // Build the color
        return CGColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
