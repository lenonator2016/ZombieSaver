//
//  Being.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

import Foundation
import AppKit

class Being {
    
    var xpos:Int32 = 0
    var ypos:Int32 = 0
    var dir:Int32 = 0
    var type = 2
    var active = 0
    var myID = 0
    
    let zombie = NSColor.red
    let human = NSColor.green
    let panicHuman = NSColor.purple
    
    init(elementID: Int) {
        dir = Int32(CGFloat((arc4random() % 4) + 1))
        myID = elementID
    }
    
    func position() {
        
        guard let rect = ZombieSaverView.view?.visibleRect else { return }
        
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        
        for i in 0..<1000 {
            
            xpos = Int32(CGFloat(arc4random() % UInt32(rect.size.width - 1)) + 1)
            ypos = Int32(CGFloat(arc4random() % UInt32(rect.size.height - 1)) + 1)// possibly do height - 1 and then add 1 to result, see java code
            
            ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(xpos*2), ypos: Int(ypos*2))
            
            if (pointer[0] == 0 && pointer[1] == 0 && pointer[2] == 0) {
               // print("found BLACK for element \(myID) at x:\(xpos) y:\(ypos) pointer:\(pointer[0]) \(pointer[1]) \(pointer[2])")
                break
            }
            else  {
               // print("found NON-BLACK pixel at x:\(xpos) y:\(ypos) pointer:\(pointer[0]) \(pointer[1]) \(pointer[2])")
            }
        }
        
        pointer.deallocate()
    }
    
    func infect(x: Int32, y: Int32) {
        if(xpos == x && ypos == y) {
            type = 1
        }
    }
    
    func infect() {
        type = 1
    }
    
    func uninfect() {
        type = 2
    }
    
    func draw() {
        //let r = Int32(arc4random() % 10)
        
        // if( (type == 2 && (active > 0 || r > ZombieSaverView.panic) ) || r == 1) {
        
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
            
            // setPixel(x: xpos, y: ypos, type: NSColor(red: 0, green: 0, blue: 0, alpha: 1))
            
            if (look(x: xpos, y: ypos, d: dir, dist: 1) == 0) {
                if (dir == 1) { ypos = ypos - 1 }
                if (dir == 2) { xpos = xpos + 1 }
                if (dir == 3) { ypos = ypos + 1 }
                if (dir == 4) { xpos = xpos - 1 }
            }
            else {
                dir = Int32((arc4random() % 4) + 1)
            }
            
            if (active > 0) {
                active = active - 1
            }
        }
        
        let target = look(x: xpos, y: ypos, d: dir, dist: 10)
        
        if (type == 1) {
            if (target == 2 || target == 4) { active = 10 }
            
            if (active == 0 && target != 1) { dir = Int32((arc4random() % 4) + 1) }
            
            let victim = look(x: xpos, y: ypos, d: dir, dist: 1)
            
            if (victim == 2 || victim == 4) {
                var ix = xpos
                var iy = ypos
                if (dir == 1) { iy = iy - 1 }
                if (dir == 2) { ix = ix + 1 }
                if (dir == 3) { iy = iy + 1 }
                if (dir == 4) { ix = ix - 1 }
                
                for i in 0..<ZombieSaverView.num {
                    ZombieSaverView.beings[i].infect(x: ix, y: iy)
                }
            }
        }
        if (type == 2)
        {
            if (target == 1 || target == 4){ active = 10 }
            
            if (target == 1) {
                dir = dir + 2
                if (dir > 4) { dir = dir - 4 }
            }
            
            if arc4random() % 8 == 1 {
                dir = Int32((arc4random() % 4) + 1)
            }
        }
    }
    
    func look(x: Int32, y: Int32, d: Int32, dist: Int32) -> Int32 {
        
        var tempX = x
        var tempY = y
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        
        for _ in 0..<dist {
            if (d == 1) { tempY = tempY - 1 }
            if (d == 2) { tempX = tempX + 1 }
            if (d == 3) { tempY = tempY + 1 }
            if (d == 4) { tempX = tempX - 1 }
            
            ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(tempX*2), ypos: Int(tempY*2))
            if pointer[0] != 0 {
                print("Candidate at x:\(xpos) y:\(ypos) pointer:\(pointer[0]) \(pointer[1]) \(pointer[2])")
            }
            
            if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) { return 3 }
            else if (pointer[0] == 67) { return 3 } // ZombieSaverView.wall
            else if (pointer[0] == 19) { return 4 } // panic human
            else if (pointer[0] == 19) { return 2 }      // human
            else if (pointer[0] == 19) { return 1 }     // zombie
        }
        
        pointer.deallocate()
        
        return 0
    }
    
    func setPixel(x: Int32, y: Int32, type: NSColor) {
        let rect = NSRect(x: CGFloat(x), y: CGFloat(y), width: 1.0, height: 1.0)
        type.setFill()
        rect.fill()
    }
}
