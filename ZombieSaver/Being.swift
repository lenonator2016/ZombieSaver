//
//  Being.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

//import Foundation
import ScreenSaver
//import AppKit

class Being {
    
    var xpos:Int32 = 0
    var ypos:Int32 = 0
    var dir:Int32 = 0
    var type = 2
    var active = 0
    var myID = 0
    
    let zombie = NSColor.red
    let human = NSColor.green
    let panicHuman = NSColor.yellow
    
    init(elementID: Int) {
        dir = SSRandomIntBetween(0, 1) + 1
        myID = elementID
    }
    
    func position() {
        
        guard let rect = ZombieSaverView.view?.visibleRect else { return }
        
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        
        for _ in 0..<1000 {
            
            xpos = Int32(CGFloat(arc4random() % UInt32(rect.size.width - 1)) + 1)
            ypos = Int32(CGFloat(arc4random() % UInt32(rect.size.height - 1)) + 1)// possibly do height - 1 and then add 1 to result, see java code
            
            ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(xpos*2), ypos: Int(ypos*2))
            
            if (pointer[0] == 0 && pointer[1] == 0 && pointer[2] == 0) {
                break
            }
        }
        
        pointer.deallocate()
    }
    
    func infect(x: Int32, y: Int32) {
        // if x and y are plus or minus 1 pixel, infect
        if (xpos == x || xpos - 1 == x || xpos + 1 == x) &&
            (ypos == y || ypos - 1 == y || ypos + 1 == y) {
            
            if type != 1 {
                type = 1
                ZombieSaverView.view?.updateLabels()
//                let sound = NSSound(contentsOfFile: Bundle.main.path(forSoundResource: "infected") ?? "", byReference: false)
//                sound?.play()
            }
        }
    }
    
    func infect() {
        type = 1
        ZombieSaverView.view?.updateLabels()
    }
    
    func uninfect() {
        type = 2
        ZombieSaverView.view?.updateLabels()
    }
    
    func draw() {
        if (type == 1) {
            setPixel(x: xpos, y: ypos, type: zombie)
        }
        else if (active > 0) {
            setPixel(x: xpos, y: ypos, type: panicHuman)
        }
        else {
            setPixel(x: xpos, y: ypos, type: human)
        }
    }
    
    func move() {
        let r = Int32(arc4random() % 10)
        
        if( (type == 2 && (active > 0 || r > ZombieSaverView.panic) ) || r == 1) {
            
            // if black space is ahead of us, keep walking
            if (look(x: xpos, y: ypos, d: dir, dist: 2) == 0) {
                if (dir == 1) { ypos = ypos - 1 }  // down
                if (dir == 2) { xpos = xpos + 1 }
                if (dir == 3) { ypos = ypos + 1 } // up
                if (dir == 4) { xpos = xpos - 1 }
            }
            else {
                // we've hit a wall or human or zombie, change direction
                dir = Int32((arc4random() % 4) + 1)
            }
            
            if (active > 0) {
                active = active - 1
            }
        }
        
        let target = look(x: xpos, y: ypos, d: dir, dist: 20)
        
        if (type == 1) {
            if (target == 2 || target == 4) { active = 10 }
            
            if (active == 0 && target != 1) { dir = Int32((arc4random() % 4) + 1) }
            
            let victim = look(x: xpos, y: ypos, d: dir, dist: 2)
            
            if (victim == 2 || victim == 4) {
                var ix = xpos
                var iy = ypos
                if (dir == 1) { iy = iy - 1 }
                if (dir == 2) { ix = ix + 1 }
                if (dir == 3) { iy = iy + 1 }
                if (dir == 4) { ix = ix - 1 }
                
                for i in 0..<ZombieSaverView.numBeings {
                    ZombieSaverView.beings[i].infect(x: ix, y: iy)
                }
            }
        }
        if (type == 2)
        {
            // if we see a zombie or panicked human, we get more active
            if (target == 1 || target == 4){ active = 10 }
            
            // run away from zombie?
            if (target == 1) {
                dir = dir + 2
                if (dir > 4) { dir = dir - 4 }
            }
            
            // random chance to keep walking toward zombie
            if SSRandomIntBetween(0, 8) == 1 {
                dir = SSRandomIntBetween(1, 4)
            }
        }
    }
    
    func look(x: Int32, y: Int32, d: Int32, dist: Int32) -> Int32 {
        
        var tempX = x
        var tempY = y
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        defer { pointer.deallocate() }
        
        for _ in 0..<dist {
            if (d == 1) { tempY = tempY - 1 }
            if (d == 2) { tempX = tempX + 1 }
            if (d == 3) { tempY = tempY + 1 }
            if (d == 4) { tempX = tempX - 1 }
            
            ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(tempX*2), ypos: Int(tempY*2))
            
            if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) { return 3 }
            else if (pointer[0] == 67) { return 3 } // ZombieSaverView.wall
            else if (pointer[0] == 107) { return 4 } // panic human
            else if (pointer[0] == 34 || pointer[0] == 35) {    // human
                // if I'm moving up, the next pixel will be my color, so check the next pixel after THAT
                if dir == 3 && tempY - 1 == y {
                    tempY = tempY + 1
                    ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(tempX*2), ypos: Int(tempY*2))
                    if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) { return 3 }
                    else if (pointer[0] == 67) { return 3 } // ZombieSaverView.wall
                    else if (pointer[0] == 107) { return 4 } // panic human
                    else if (pointer[0] == 34 || pointer[0] == 35) { return 2 }
                }
                else {
                    return 2
                }
            }
            else if (pointer[0] == 253) { return 1 }     // zombie
        }
        
        return 0
    }
    
    func setPixel(x: Int32, y: Int32, type: NSColor) {
        let rect = NSRect(x: CGFloat(x), y: CGFloat(y), width: 1.0, height: 1.0)
        type.setFill()
        rect.fill()
    }
}
