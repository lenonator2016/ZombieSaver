//
//  ZombieView.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

import ScreenSaver

struct Pixel {
    var r:UInt8 = 0
    var g:UInt8 = 0
    var b:UInt8 = 0
    var a:UInt8 = 0
}

class ZombieSaverView: ScreenSaverView {
    
    static var numBeings = 5000
    static var speed = 1
    static var panic = 5
    static var wall = NSColor(deviceRed: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)  // NSColor.darkGray
    static var beings:[Being] = []
    static var view:ZombieSaverView?
    
    var beingsPositioned = false
    var freeze = 0
    var circleZombies = false
    let numBigRects = 150
    let numSmallRects = 30
    
    var bigRects:[NSRect] = []
    var smallRects:[NSRect] = []
    var humanLabel:NSTextField!
    var zombieLabel:NSTextField!
    var showLabels = false
    var bitmapImageRep:NSBitmapImageRep?
    override var acceptsFirstResponder: Bool { return true }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.becomeFirstResponder()
        
        if isPreview {
            ZombieSaverView.numBeings = 1000
        }
        
        ZombieSaverView.view = self
        bitmapImageRep = bitmapImageRepForCachingDisplay(in: self.visibleRect)
        
        createBuildings()
        createLabels()
        createBeings()
        updateLabels()
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.resignFirstResponder()
    }
    
    private func createBuildings() {
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
    }
    
    private func createLabels() {
        // Add labels for Zombies and Humans
        humanLabel = NSTextField(labelWithString: "")
        humanLabel.isBezeled = false
        humanLabel.drawsBackground = false
        humanLabel.isEditable = false
        humanLabel.isSelectable = false
        humanLabel.textColor = NSColor(red: 0.0, green: 240.0/255.0, blue: 0.0, alpha: 1.0)
        humanLabel.alphaValue = 0.0
        humanLabel.alignment = .center
        humanLabel.frame = NSRect(x: (frame.size.width / 2.0) - 250, y: 0, width: 200, height: 50)
        self.addSubview(humanLabel)
        
        zombieLabel = NSTextField(labelWithString: "")
        zombieLabel.isBezeled = false
        zombieLabel.drawsBackground = false
        zombieLabel.isEditable = false
        zombieLabel.isSelectable = false
        zombieLabel.textColor = NSColor(red: 240.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        zombieLabel.alphaValue = 0.0
        zombieLabel.alignment = .center
        zombieLabel.frame = NSRect(x: (frame.size.width / 2.0) + 50, y: 0, width: 200, height: 50)
        self.addSubview(zombieLabel)
    }
    
    private func createBeings() {
        ZombieSaverView.beings.removeAll()
        beingsPositioned = false
        
        for i in 0..<ZombieSaverView.numBeings {
            ZombieSaverView.beings.append(Being.init(elementID: i))
        }
        
        ZombieSaverView.beings[0].infect()
    }
    
    // MARK: - Event Handling
    override func keyDown(with event: NSEvent) {
        // extract the key
        let keyCode = event.keyCode
        
        switch keyCode {
        case 37:        // l
            showLabels = !showLabels
            updateLabels()
            
        case 49:    // space
            for i in 0..<ZombieSaverView.numBeings {
                ZombieSaverView.beings[i].uninfect()
                }
            let index = Int(SSRandomIntBetween(0, Int32(ZombieSaverView.numBeings - 1)))
            ZombieSaverView.beings[index].infect()
            
        case 1:     // s
                ZombieSaverView.speed = ZombieSaverView.speed + 1
                if ZombieSaverView.speed > 4 { ZombieSaverView.speed = 1 }
            
        case 35:    // p
            ZombieSaverView.panic = 5 - ZombieSaverView.panic
            
        case 5:     // g
            break
            
        case 24:        // +
            fallthrough
        case 69:        // +
            if ZombieSaverView.numBeings < 5000 {
                ZombieSaverView.numBeings = ZombieSaverView.numBeings + 100
                createBeings()
                updateLabels()
            }
            
        case 27 :    // -
            fallthrough
        case 78:    // -
            if ZombieSaverView.numBeings > 100 {
                ZombieSaverView.numBeings = ZombieSaverView.numBeings - 100
                createBeings()
                updateLabels()
            }
        case 6:     // z
            freeze = 1
            
        case 8:     // c
            // set a flag to draw circle around each zombie
            circleZombies = true
            
            // turn off after five seconds
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (_) in
                self.circleZombies = false
            }
        
        default:
                super.keyDown(with: event)
        }
    }
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        
        // Draw a single frame in this function
        drawBackground()
        
        if beingsPositioned {
            for i in 0..<ZombieSaverView.numBeings {
                ZombieSaverView.beings[i].draw()
                
                if circleZombies && ZombieSaverView.beings[i].type == 1 {
                    let origin = CGPoint(x: Int(ZombieSaverView.beings[i].xpos), y: Int(ZombieSaverView.beings[i].ypos))
                    var rect = NSRect(x: origin.x, y: origin.y, width: 1, height: 1)
                    rect = rect.insetBy(dx: -3, dy: -3)
                    let path = NSBezierPath(ovalIn: rect)
                    path.lineWidth = 1
                    NSColor.white.setStroke()
                    path.stroke()
                }
            }
        }
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        // get the current state of the world
        self.cacheDisplay(in: self.visibleRect, to: bitmapImageRep!)
        
        if beingsPositioned == false {
            for i in 0..<ZombieSaverView.numBeings {
                ZombieSaverView.beings[i].position()
            }
            beingsPositioned = true
        }
        
        // Update the "state" of the screensaver in this function
        if (freeze == 0)
        {
            for i in 0..<ZombieSaverView.numBeings {
                ZombieSaverView.beings[i].move()
            }
            
            if (ZombieSaverView.speed == 2) { sleep(20/1000) }
            else if (ZombieSaverView.speed == 3) { sleep(50/1000) }
            else if (ZombieSaverView.speed == 4) { sleep(100/1000) }
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
    
    func updateLabels() {
        
        var humanCount = 0
        var zombieCount = 0
        
        for i in 0..<ZombieSaverView.numBeings {
            if ZombieSaverView.beings[i].type == 1 {
                zombieCount = zombieCount + 1
            }
            else {
                humanCount = humanCount + 1
            }
        }
        
        humanLabel.stringValue = "Humans: \(humanCount)"
        zombieLabel.stringValue = "Zombies: \(zombieCount)"
        
        if showLabels {
            NSAnimationContext.runAnimationGroup { (_) in
                NSAnimationContext.current.duration = 1.0
                humanLabel.animator().alphaValue = 1.0
                zombieLabel.animator().alphaValue = 0.75
            }
        }
        else {
            NSAnimationContext.runAnimationGroup { (_) in
                NSAnimationContext.current.duration = 1.0
                humanLabel.animator().alphaValue = 0.0
                zombieLabel.animator().alphaValue = 0.0
            }
        }
    }
    
    // Note - this function is correct. We pass in X and Y coordinates already multiplied by two to account for the
    // retina scale of the bitmap
    func pixelOfPoint( p: UnsafeMutablePointer<Int>, xpos: Int, ypos: Int) {
        bitmapImageRep?.getPixel(p, atX: xpos, y: Int(self.visibleRect.size.height * 2) - ypos)
    }
    
//    func rawPixelOfPoint(xpos: Int, ypos: Int) -> Pixel {
//        let bitmapData = bitmapImageRep?.bitmapData
//        let index = xpos + (Int(self.visibleRect.size.height * 2) - ypos) * Int(self.visibleRect.size.width)
//
//        return Pixel(r: bitmapData![index], g: bitmapData![index+1], b: bitmapData![index + 2], a: bitmapData![index+3])
//    }
}
