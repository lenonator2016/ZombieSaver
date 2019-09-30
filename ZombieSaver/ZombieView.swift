//
//  ZombieView.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

/* Ideas for future:
 
    Add the ability to add a "Zombie Killer" human who hunts and kills zombies
        When zombies are killed, openGL type fireworks explosion
 
    Add a keystroke that will toggle on/off two pixel mode
        beings are two pixels wide and tall
 
 */

import ScreenSaver

class ZombieSaverView: ScreenSaverView {
    
    static var numBeings = 6000
    static var speed = 1
    static var panic = 5
    static var wall = NSColor(deviceRed: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)  // NSColor.darkGray
    static var beings:[Being] = []
    static var view:ZombieSaverView?
    
    static var zombieColor:NSColor!     // red
    static var humanColor:NSColor!      // green
    static var panicHumanColor:NSColor! // blue
    
    var beingsPositioned = false
    var freeze = 0
    var circleZombies = false
    let numBigRects = 150
    let numSmallRects = 30
    
    var bigRects:[NSRect] = []
    var smallRects:[NSRect] = []
    var humanLabel:NSTextField!
    var panickedLabel:NSTextField!
    var zombieLabel:NSTextField!
    var showLabels = false
    var initialNumberOfZombies = 1
    var makeBuildings = true
    var bitmapImageRep:NSBitmapImageRep?
    override var acceptsFirstResponder: Bool { return true }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.becomeFirstResponder()
        animationTimeInterval = 0.06
        
        if isPreview {
            ZombieSaverView.numBeings = 1000
        }
        
        ZombieSaverView.view = self
        bitmapImageRep = bitmapImageRepForCachingDisplay(in: self.visibleRect)
        
        createColors()
        createSimulation()
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.resignFirstResponder()
    }
    
    private func createColors() {
        let pointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
        pointer[0] = 1.0
        pointer[1] = 0.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        ZombieSaverView.zombieColor = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        
        pointer[0] = 0.0
        pointer[1] = 1.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        ZombieSaverView.humanColor = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        
        pointer[0] = 1.0
        pointer[1] = 1.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        ZombieSaverView.panicHumanColor = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        
        pointer.deallocate()
    }
    
    private func createSimulation() {
        createBuildings()
        createLabels()
        createBeings()
        updateLabels()
    }
    
    private func createBuildings() {
        bigRects.removeAll()
        smallRects.removeAll()
        
        if makeBuildings {
            var maxWidth = CGFloat(frame.size.width) * 0.24
            var maxHeight = CGFloat(frame.size.height) * 0.24
            
            for _ in 0..<numBigRects {
                let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)).rounded() + 1.0,
                                     y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)).rounded() + 1.0)
                
                let size = NSSize(width: (SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.04).rounded(),
                                  height: (SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.04).rounded())
                
                bigRects.append(NSRect(origin: origin, size: size))
            }
            
            // set small building params
            maxWidth = CGFloat(frame.size.width) * 0.08
            maxHeight = CGFloat(frame.size.height) * 0.08
            
            for _ in 0..<numSmallRects {
                let origin = CGPoint(x: SSRandomFloatBetween(0.0, CGFloat(frame.size.width - 1)).rounded() + 1.0,
                                     y: SSRandomFloatBetween(0.0, CGFloat(frame.size.height - 1)).rounded() + 1.0)
                
                let size = NSSize(width: (SSRandomFloatBetween(0.0, maxWidth) + CGFloat(frame.size.width) * 0.08).rounded(),
                                  height: (SSRandomFloatBetween(0.0, maxHeight) + CGFloat(frame.size.height) * 0.08).rounded())
                
                smallRects.append(NSRect(origin: origin, size: size))
            }
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
        humanLabel.frame = NSRect(x: (frame.size.width / 2.0) - 300, y: 0, width: 200, height: 50)
        self.addSubview(humanLabel)
        
        panickedLabel = NSTextField(labelWithString: "")
        panickedLabel.isBezeled = false
        panickedLabel.drawsBackground = false
        panickedLabel.isEditable = false
        panickedLabel.isSelectable = false
        panickedLabel.textColor = NSColor(red: 240.0/255.0, green: 240.0/255.0, blue: 11.0/255.0, alpha: 1.0)
        panickedLabel.alphaValue = 0.0
        panickedLabel.alignment = .center
        panickedLabel.frame = NSRect(x: (frame.size.width / 2.0) - 100, y: 0, width: 200, height: 50)
        self.addSubview(panickedLabel)
        
        zombieLabel = NSTextField(labelWithString: "")
        zombieLabel.isBezeled = false
        zombieLabel.drawsBackground = false
        zombieLabel.isEditable = false
        zombieLabel.isSelectable = false
        zombieLabel.textColor = NSColor(red: 240.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        zombieLabel.alphaValue = 0.0
        zombieLabel.alignment = .center
        zombieLabel.frame = NSRect(x: (frame.size.width / 2.0) + 100, y: 0, width: 200, height: 50)
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
        case 45:
            makeBuildings = !makeBuildings
            createSimulation()
            
        case 37:        // l - show/hide labels
            showLabels = !showLabels
            updateLabels()
            
        case 18:
            initialNumberOfZombies = 1
            resetSimulation()
            
        case 19:
            initialNumberOfZombies = 2
            resetSimulation()
            
        case 20:
            initialNumberOfZombies = 3
            resetSimulation()
            
        case 21:
            initialNumberOfZombies = 4
            resetSimulation()
            
        case 23:
            initialNumberOfZombies = 5
            resetSimulation()
        
        
        case 49:        // space - reset simulation
            resetSimulation()
            
        case 1:         // s - adjust speed
                ZombieSaverView.speed = ZombieSaverView.speed + 1
                if ZombieSaverView.speed > 4 { ZombieSaverView.speed = 1 }
            
        case 35:        // p
            ZombieSaverView.panic = 5 - ZombieSaverView.panic
            
        case 3:         // f - toggle freeze
            if freeze == 1 {
                freeze = 0
            }
            else {
                freeze = 1
            }
            break
            
        case 24:        // + - increase zombie count
            fallthrough
        case 69:        // +
            if ZombieSaverView.numBeings < 6000 {
                ZombieSaverView.numBeings = ZombieSaverView.numBeings + 100
                createBeings()
                updateLabels()
            }
            
        case 27 :    // - decrease zombie count
            fallthrough
        case 78:    // -
            if ZombieSaverView.numBeings > 100 {
                ZombieSaverView.numBeings = ZombieSaverView.numBeings - 100
                createBeings()
                updateLabels()
            }
            
        case 8:     // c - draw circle around zombies
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
    
    private func resetSimulation() {
        for i in 0..<ZombieSaverView.numBeings {
            ZombieSaverView.beings[i].uninfect()
            ZombieSaverView.beings[i].active = 0
        }
        
        for _ in 0..<initialNumberOfZombies {
            var index = Int(SSRandomIntBetween(0, Int32(ZombieSaverView.numBeings - 1)))
            if ZombieSaverView.beings[index].type == 1 {
                // try again
                index = Int(SSRandomIntBetween(0, Int32(ZombieSaverView.numBeings - 1)))
            }
            ZombieSaverView.beings[index].infect()
        }
    }
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        
        // Draw a single frame in this function
        NSGraphicsContext.current?.shouldAntialias = false

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
        
        updateLabels()
        
        setNeedsDisplay(self.bounds)
    }
    
    func drawBackground() {
        
        // Do nothing but draw. Do not calculate anything requiring getPixel
        NSColor.black.setFill()
        self.visibleRect.fill()
        
        for i in 0..<bigRects.count {
            ZombieSaverView.wall.setFill()
            bigRects[i].fill()
            NSColor.black.setStroke()
            let bp = NSBezierPath.init(rect: bigRects[i])
            bp.lineWidth = 3.0
            bp.stroke()
        }

        if smallRects.count > 0 {
            NSColor.black.setFill()
            smallRects.fill()
        }
    }
    
    func updateLabels() {
        
        var humanCount = 0
        var zombieCount = 0
        var panicCount = 0
        
        for i in 0..<ZombieSaverView.numBeings {
            if ZombieSaverView.beings[i].type == 1 {
                zombieCount = zombieCount + 1
            }
            else {
                humanCount = humanCount + 1
                if ZombieSaverView.beings[i].active > 0 {
                    panicCount = panicCount + 1
                }
            }
        }
        
        humanLabel.stringValue = "Humans: \(humanCount)"
        panickedLabel.stringValue = "Panicked Humans: \(panicCount)"
        zombieLabel.stringValue = "Zombies: \(zombieCount)"
        
        if showLabels {
            NSAnimationContext.runAnimationGroup { (_) in
                NSAnimationContext.current.duration = 1.0
                humanLabel.animator().alphaValue = 1.0
                panickedLabel.animator().alphaValue = 1.0
                zombieLabel.animator().alphaValue = 1.0
            }
        }
        else {
            NSAnimationContext.runAnimationGroup { (_) in
                NSAnimationContext.current.duration = 1.0
                humanLabel.animator().alphaValue = 0.0
                panickedLabel.animator().alphaValue = 0.0
                zombieLabel.animator().alphaValue = 0.0
            }
        }
    }
    
    // Note - this function is correct. We pass in X and Y coordinates already multiplied by two to account for the
    // retina scale of the bitmap
    func pixelOfPoint( p: UnsafeMutablePointer<Int>, xpos: Int, ypos: Int) {
        
        let scale = NSScreen.main!.backingScaleFactor
        bitmapImageRep?.getPixel(p, atX: xpos * Int(scale), y: Int(self.visibleRect.size.height * scale) - (ypos * Int(scale)))
    }
}
