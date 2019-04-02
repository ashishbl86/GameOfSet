//
//  Card.swift
//  Concentration
//
//  Created by Ashish Bansal on 14/05/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import Foundation

struct Card: Hashable
{
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier;
    }

    var hashValue : Int {
        return identifier
    }
    
    var isFaceUp = false
    var isMatched = false
    private var identifier: Int
    var seenOnce = false
    
    private static var identifierFactory = 0
    
    private static func getNewIdentifier() -> Int
    {
        identifierFactory += 1
        return identifierFactory
    }
    
    init()
    {
        identifier = Card.getNewIdentifier()
    }
    
    mutating func reset()
    {
        isFaceUp = false
        isMatched = false
        seenOnce = false
    }
}
