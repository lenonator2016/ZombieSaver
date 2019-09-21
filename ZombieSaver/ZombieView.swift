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
    var allowAnimation = false
    var freeze = 0
    let numBigRects = 100
    let numSmallRects = 30
    static var num = 5000
    static var speed = 1
    static var panic = 5
    static var wall = NSColor(deviceRed: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)  // NSColor.darkGray
    static var beings:[Being] = []
    var bigRects:[NSRect] = []
    var smallRects:[NSRect] = []
    
    var bitmapImageRep:NSBitmapImageRep?
    static var view:ZombieSaverView?
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        ZombieSaverView.view = self
        bitmapImageRep = bitmapImageRepForCachingDisplay(in: self.visibleRect)
        var maxWidth = CGFloat(frame.size.width) * 0.24
        var maxHeight = CGFloat(frame.size.height) * 0.24
        
        for _ in 0..<numBigRects {
            let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)) + 1.0,
                                 y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)) + 1.0)
            
            let size = NSSize(width: SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.04, height: SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.04)
            
            bigRects.append(NSRect(origin: origin, size: size))
        }
        
        // set small building params
        maxWidth = CGFloat(frame.size.width) * 0.08
        maxHeight = CGFloat(frame.size.height) * 0.08
        
        for _ in 0..<numSmallRects {
            let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)) + 1.0,
                                 y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)) + 1.0)
            
            let size = NSSize(width: SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.08, height: SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.08)
            
            smallRects.append(NSRect(origin: origin, size: size))
        }
        
        for i in 0..<ZombieSaverView.num {
            ZombieSaverView.beings.append(Being.init(elementID: i))
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
        
        if beingsPositioned {
            for i in 0..<ZombieSaverView.num {
                ZombieSaverView.beings[i].draw()
            }
        }
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        // get the current state of the world
        self.cacheDisplay(in: self.visibleRect, to: bitmapImageRep!)
        
        if beingsPositioned == false {
            for i in 0..<ZombieSaverView.num {
                ZombieSaverView.beings[i].position()
            }
            beingsPositioned = true
        }
        
        // Update the "state" of the screensaver in this function
        if (freeze == 0 && allowAnimation)
        {
            for i in 0..<ZombieSaverView.num {
                ZombieSaverView.beings[i].move()
            }
            
            if (ZombieSaverView.speed == 2) { sleep(20/1000) }
            else if (ZombieSaverView.speed == 3) { sleep(50/1000) }
            else if (ZombieSaverView.speed == 4) { sleep(100/1000) }
        }
        
        if beingsPositioned == true {
            allowAnimation = true
        }
        
        setNeedsDisplay(self.bounds)
    }
    
    func drawBackground() {
        
        // Do nothing but draw. Do not calculate anything requiring getPixel
        NSColor.black.setFill()
        self.visibleRect.fill()
        
        for i in 0..<numBigRects {
            ZombieSaverView.wall.setFill()
            bigRects[i].fill()
            NSColor.black.setStroke()
            let bp = NSBezierPath.init(rect: bigRects[i])
            bp.lineWidth = 2.0
            bp.stroke()
        }

        NSColor.black.setFill()
        smallRects.fill()
    }
    
    func colorOfPoint(xpos: Int, ypos: Int) -> NSColor? {
        return bitmapImageRep?.colorAt(x: xpos, y: ypos)
    }
    
    // Note - this function is correct. We pass in X and Y coordinates already multiplied by two to account for the
    // retina scale of the bitmap
    func pixelOfPoint(p: UnsafeMutablePointer<Int>, xpos: Int, ypos: Int) {
        bitmapImageRep?.getPixel(p, atX: xpos, y: Int(self.visibleRect.size.height * 2) - ypos)
    }
}
