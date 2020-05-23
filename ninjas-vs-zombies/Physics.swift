//
//  Physics.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/20/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import Foundation

class Physics {
    enum physicalBodies : UInt32 {
        case floor = 1
        case player = 2
        case sword = 4
        case zombie = 8
        case hands = 16
        case heart = 32
    }
}
