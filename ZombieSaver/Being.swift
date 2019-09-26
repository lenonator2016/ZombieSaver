//
//  Being.swift
//  ZombieSaver
//
//  Created by James W. Leno on 9/19/19.
//  Copyright © 2019 Lenco Software, LLC. All rights reserved.
//

import ScreenSaver

class Being {
    
    var xpos:Int32 = 0
    var ypos:Int32 = 0
    var dir:Int32 = 0
    var type = 2
    var active = 0
    var myID = 0
    
//    let zombie =  NSColor(deviceRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)                   //NSColor.red
//    let human = NSColor(deviceRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)                    //NSColor.green
//    let panicHuman = NSColor(deviceRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)             // NSColor.yellow
    
    let zombie:NSColor!
    let human:NSColor!
    let panicHuman:NSColor!
    
    init(elementID: Int) {
        dir = SSRandomIntBetween(0, 1) + 1
        myID = elementID
        
        var pointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
        pointer[0] = 1.0
        pointer[1] = 0.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        zombie = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        pointer.deallocate()
        
        pointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
        pointer[0] = 0.0
        pointer[1] = 1.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        human = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        pointer.deallocate()
        
        pointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
        pointer[0] = 1.0
        pointer[1] = 1.0
        pointer[2] = 0.0
        pointer[3] = 1.0
        
        panicHuman = NSColor(colorSpace: .genericRGB, components: pointer, count: 4)
        pointer.deallocate()
    }
    
    func position() {
        
        guard let rect = ZombieSaverView.view?.visibleRect else { return }
        
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        
        for _ in 0..<2000 {
            
            xpos = SSRandomIntBetween(1, Int32(rect.size.width) - 1) + 1
            ypos = SSRandomIntBetween(1, Int32(rect.size.height) - 1) + 1
            
            ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(xpos*2), ypos: Int(ypos*2))
            
            if (pointer[0] == 0 && pointer[1] == 0 && pointer[2] == 0) {
                ypos = ypos - 1
                ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(xpos*2), ypos: Int(ypos*2))
                if (pointer[0] == 0 && pointer[1] == 0 && pointer[2] == 0) {
                    break
                }
            }
//            else if pointer[0] != 67 && pointer[0] != 0 {
//                print("did not find black")
//            }
//            
//            if i == 1999 {
//                print("could not find spot!")
//            }
        }
        
        pointer.deallocate()
    }
    
    func infect(x: Int32, y: Int32) {
        // if x and y are plus or minus 1 pixel, infect
        if (xpos == x || xpos - 1 == x || xpos + 1 == x) &&
            (ypos == y || ypos - 1 == y || ypos + 1 == y) {
            
            if type != 1 {
                type = 1
//                let sound = NSSound(contentsOfFile: Bundle.main.path(forSoundResource: "infected") ?? "", byReference: false)
//                sound?.play()
            }
        }
    }
    
    func infect() {
        type = 1
    }
    
    func uninfect() {
        type = 2
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
            
            if (active == 0 && target != 1) {
                dir = Int32((arc4random() % 4) + 1)
            }
            
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
            if (target == 1 || target == 4){
                active = 10
            }
            
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
            
//            if pointer[0] != 0 && pointer[0] != 67 && pointer[0] != 255 {
//                print( "\(pointer[0]) \(pointer[1]) \(pointer[2])")
//            }

            if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) {
                return 3            // ZombieSaverView.wall
            }
            else if (pointer[0] == 67) {
                return 3            // ZombieSaverView.wall
            }
            else if ((pointer[0] == 254 || pointer[0] == 255) &&
                (pointer[1] == 254 || pointer[1] == 255)) {     // panic human
                return 4
            }
            // Tired note to self! I think we need to do this up check for EVERY being, not just humans
            // both zombies and humans can be moving up!!
            // Hmmm, for some reason, after the zombies start getting going, we don't get any more panicked humans, why??
            else if ((pointer[0] == 254 || pointer[0] == 255) || (pointer[1] == 254 || pointer[1] == 255)) {    // human
                // if I'm moving up, the next pixel will be my color, so check the next pixel after THAT
                if dir == 3 && tempY - 1 == y {
                    tempY = tempY + 1
                    ZombieSaverView.view?.pixelOfPoint(p: pointer, xpos: Int(tempX*2), ypos: Int(tempY*2))
                    if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) { return 3 }
                    else if (pointer[0] == 67) {
                        return 3        // ZombieSaverView.wall
                    }
                    else if ((pointer[0] == 254 || pointer[0] == 255) &&
                        (pointer[1] == 254 || pointer[1] == 255)) {
                        return 4        // panic human
                    }
                    else if (pointer[1] == 254 || pointer[1] == 255) {
                        return 2        // human
                    }
                }
                else {
                    // we are not moving up, we encountered a human so return that
                    return 2
                }
            }
            else if (pointer[0] == 253 || pointer[0] == 254 || pointer[0] == 255) {
            // else if (pointer[0] == 253) {
               // print( "\(pointer[0]) \(pointer[1]) \(pointer[2])")
                return 1    // zombie
            }
        }

        return 0
    }
    
    // alternate version using colorAtPoint
//    func look(x: Int32, y: Int32, d: Int32, dist: Int32) -> Int32 {
//
//        var tempX = x
//        var tempY = y
//
//        for _ in 0..<dist {
//            if (d == 1) { tempY = tempY - 1 }
//            if (d == 2) { tempX = tempX + 1 }
//            if (d == 3) { tempY = tempY + 1 }
//            if (d == 4) { tempX = tempX - 1 }
//
//            guard let color = ZombieSaverView.view?.colorOfPoint(xpos: Int(tempX*2), ypos: Int(tempY*2)) else { return 0 }
//
//            print("\(color.redComponent), \(color.greenComponent), \(color.blueComponent)")
//
//            if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) {
//                return 3
//            }
//            else if (color.redComponent == 67) {
//                return 3
//            } // ZombieSaverView.wall
//            else if (color.redComponent == 255 && color.blueComponent == 255) {
//                return 4
//            } // panic human
//            else if (color.redComponent == 34 || color.redComponent == 35) {    // human
//                // if I'm moving up, the next pixel will be my color, so check the next pixel after THAT
//                if dir == 3 && tempY - 1 == y {
//                    tempY = tempY + 1
//                    guard let color2 = ZombieSaverView.view?.colorOfPoint(xpos: Int(tempX*2), ypos: Int(tempY*2)) else { return 0 }
//                    if (tempX > Int32(ZombieSaverView.view!.frame.size.width - 1) || tempX < 1 || tempY > Int32(ZombieSaverView.view!.frame.size.height - 1) || tempY < 1) { return 3 }
//                    else if (color2.redComponent == 67) { // ZombieSaverView.wall
//                        return 3
//                    }
//                    else if (color2.redComponent == 255 && color2.blueComponent == 255) { // panic human
//                        return 4
//                    }
//                    else if (color2.redComponent == 34 || color2.redComponent == 35) {
//                        return 2
//                    }
//                    else if (color2.redComponent == 251 || color2.redComponent == 253) { // zombie
//                        return 1
//                    }
//                }
//                else {
//                    // we are not moving up, we encountered a human so return that
//                    return 2
//                }
//            }
//            else if (color.redComponent == 251 || color.redComponent == 253) { return 1 }     // zombie
//        }
//
//        return 0
//    }
    
    func setPixel(x: Int32, y: Int32, type: NSColor) {
        let rect = NSRect(x: CGFloat(x), y: CGFloat(y), width: 1.0, height: 1.0)
        type.setFill()
        rect.fill()
    }
}
