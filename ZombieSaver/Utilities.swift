//
//  Utilities.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

import Foundation
import ScreenSaver

extension ScreenSaverView {
    func colorOfPoint(point: CGPoint) -> NSColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        // TODO: This triggers another draw and puts us in an infinite loop!
        self.layer?.render(in: context!)
        
        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)
                
        return color
    }
}

//extension NSColor: Equatable {
//    static func == (lhs: NSColor, rhs: NSColor) -> Bool {
//        return
//            lhs.redComponent == rhs.redComponent &&
//                lhs.greenComponent == rhs.greenComponent &&
//                lhs.blueComponent == rhs.blueComponent &&
//        lhs.alphaComponent == rhs.alphaComponent
//    }
//}
