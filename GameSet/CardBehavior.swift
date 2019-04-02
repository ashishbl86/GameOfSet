//
//  CardBehavior.swift
//  GameSet
//
//  Created by Ashish Bansal on 02/11/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    private let collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    private let itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 0.8
        behavior.resistance = 0.2
        behavior.friction = 0.0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
            pushBehavior.angle = getPushAngle(ofItemWithCenter: item.center, containedIn: referenceBounds)
            pushBehavior.magnitude = 3.0
            pushBehavior.action = {[unowned pushBehavior] in
                self.removeChildBehavior(pushBehavior)
            }
            addChildBehavior(pushBehavior)
        }
        itemBehavior.addAngularVelocity(10.0, for: item)
    }
    
    func getPushAngle(ofItemWithCenter itemCenter: CGPoint, containedIn container: CGRect) -> CGFloat {
        switch (itemCenter.x, itemCenter.y) {
        case let (x, y) where x < container.center.x && y < container.center.y:
            return (CGFloat.pi/2).arc4random
        case let (x, y) where x > container.center.x && y < container.center.y:
            return CGFloat.pi-(CGFloat.pi/2).arc4random
        case let (x, y) where x < container.center.x && y > container.center.y:
            return (-CGFloat.pi/2).arc4random
        case let (x, y) where x > container.center.x && y > container.center.y:
            return CGFloat.pi+(CGFloat.pi/2).arc4random
        default:
            return (CGFloat.pi*2).arc4random
        }
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(dynamicAnimator: UIDynamicAnimator) {
        self.init()
        dynamicAnimator.addBehavior(self)
    }
}
