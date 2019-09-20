//
//  ZombieView.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

import ScreenSaver

class ZombieSaverView: ScreenSaverView {
    
    var beingsPositioned = false
    var freeze = 0
    static var num = 100
    static var speed = 1
    static var panic = 5
    static var wall = NSColor.init(red: 50, green: 50, blue: 50, alpha: 1.0)
    static var beings = Array(repeating: Being(), count: ZombieSaverView.num)
    var bigRects:[NSRect] = []
    var smallRects:[NSRect] = []
    
//    static var width = UInt32(NSScreen.main?.visibleFrame.size.width ?? 0)
//    static var height = UInt32(NSScreen.main?.visibleFrame.size.height ?? 0)
    static var view:ZombieSaverView?
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        ZombieSaverView.view = self
        var maxWidth = CGFloat(frame.size.width) * 0.24
        var maxHeight = CGFloat(frame.size.height) * 0.24
        
        for i in 0..<100 {
            let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)) + 1.0,
                                 y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)) + 1.0)
            
            let size = NSSize(width: SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.04, height: SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.04)
            
            bigRects.append(NSRect(origin: origin, size: size))
        }
        
        // set small building params
        maxWidth = CGFloat(frame.size.width) * 0.08
        maxHeight = CGFloat(frame.size.height) * 0.08
        
        for i in 0..<30 {
            let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)) + 1.0,
                                 y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)) + 1.0)
            
            let size = NSSize(width: SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.08, height: SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.08)
            
            smallRects.append(NSRect(origin: origin, size: size))
        }
        
        ZombieSaverView.beings[0].infect()
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        // Draw a single frame in this function
        drawBackground()
        
        for i in 0..<ZombieSaverView.num {
            ZombieSaverView.beings[i].draw()
        }
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        if beingsPositioned == false {
            for i in 0..<ZombieSaverView.num {
                ZombieSaverView.beings[i].position()
            }
            beingsPositioned = true
        }
        
        // Update the "state" of the screensaver in this function
//        if (freeze == 0)
//        {
//            for i in 0..<ZombieSaverView.num {
//                ZombieSaverView.beings[i].move()
//            }
//            
//            if (ZombieSaverView.speed == 2) { sleep(20) }
//            else if (ZombieSaverView.speed == 3) { sleep(50) }
//            else if (ZombieSaverView.speed == 4) { sleep(100) }
//        }
    }
    
    func drawBackground() {
        
        // Do nothing but draw. Do not calculate anything requiring getPixel
        NSColor.black.setFill()
        self.frame.fill()
        
        for i in 0..<100 {
            NSColor.darkGray.setFill()
            bigRects[i].fill()
            NSColor.black.setStroke()
            let bp = NSBezierPath.init(rect: bigRects[i])
            bp.lineWidth = 2.0
            bp.stroke()
        }
        
        NSColor.black.setFill()
        smallRects.fill()
    }
}
