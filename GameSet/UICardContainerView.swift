//
//  UICardContainerView.swift
//  GameSet
//
//  Created by Ashish Bansal on 26/09/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class UICardContainerView: UIView {

    var grid = Grid(layout: .aspectRatio(2.25/3.5))
    var cardTapReceiver: TapGestureRecognizer?
    var getNewCardPickupRect: () -> CGRect = {return CGRect.zero}
    var getDiscardCardThrowRect: () -> CGRect = {return CGRect.zero}
    weak var firstMatchedCard: UIView?
    lazy var dynamicAnimator = UIDynamicAnimator(referenceView: superview!)
    lazy var cardBehaviour = CardBehavior(dynamicAnimator: dynamicAnimator)
    weak var cardRemovalTimer: Timer?
    weak var cardAdditionTimer: Timer?
    
    private func getViewsForCards(_ cards: [SetCard]) -> ([UICardView], [Int]) {
        let cardViews = subviews.filter {
            if let setCardView = $0 as? UICardView, cards.contains(setCardView.setCard)  {
                return true
            }
            return false
        }
        
        
        let uiCardViews = cardViews.map{$0 as! UICardView}
        var cardViewIndexesInSuperView = [Int]()
        uiCardViews.forEach{cardViewIndexesInSuperView.append(subviews.firstIndex(of: $0)!)}
        return (uiCardViews, cardViewIndexesInSuperView)
    }
    
    func getDeckRect() -> CGRect{
        let deckOnScreenRect = getNewCardPickupRect()
        return CGRect(center: deckOnScreenRect.center, size: CGSize(width: deckOnScreenRect.height, height: deckOnScreenRect.width))
    }
    
    func highlightCards(_ cards: [SetCard], withColor highlightColor: UIColor)
    {
        let cardsToHighlight = getViewsForCards(cards)
        
        assert(cardsToHighlight.0.count == cards.count, "Not all cards to be highlighted are in the game")
        subviews.forEach{
            if let cardView = $0 as? UICardView {
                if cardsToHighlight.0.contains(cardView) {
                    cardView.highlightCard = true
                    cardView.highlightColor = highlightColor
                    cardView.setNeedsDisplay()
                }
                else if cardView.highlightCard {
                    cardView.highlightCard = false
                    cardView.setNeedsDisplay()
                }
            }
        }
    }
    
    func unhighlightCards(_ cards: [SetCard])
    {
        let cardsToUnhighlight = getViewsForCards(cards)
        
        assert(cardsToUnhighlight.0.count == cards.count, "Not all cards to be highlighted are in the game")
        cardsToUnhighlight.0.forEach{
            $0.highlightCard = false
            $0.setNeedsDisplay()
        }
    }
    
    func shakeCards(_ cards: [SetCard], onCompletion onCompletionTask: @escaping () -> Void)
    {
        let cardsToShake = getViewsForCards(cards)
        cardsToShake.0.forEach{
            $0.transform = CGAffineTransform.identity.translatedBy(x: $0.bounds.width/3, y: 0)
        }
        
        let shakeAnimator = UIViewPropertyAnimator(duration: 0.55, dampingRatio: 0.17, animations: {
            cardsToShake.0.forEach{
                $0.transform = CGAffineTransform.identity
            }
        })
        shakeAnimator.addCompletion{position in
            onCompletionTask()
        }
        shakeAnimator.startAnimation()
    }

    //MARK: Addition of new cards
    func addCards(cards: [SetCard], additionalTaskJustBeforeAddition: @escaping () -> Void)
    {
        var newViews = [UICardView]()
        cards.forEach{card in
            let cardView = UICardView(frame: getDeckRect(), card: card, gestureRecognizer: cardTapReceiver)
            cardView.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi/2)
            cardView.isHidden = true
            addSubview(cardView)
            newViews.append(cardView)
        }
        let additionOfNewCards = { [unowned self] in
            additionalTaskJustBeforeAddition()
            self.animateAdditionOfViews(newViews)
        }
        resizeExistingCards(onCompletion: additionOfNewCards)
    }

    private func resizeExistingCards(onCompletion onCompletionTask: @escaping () -> Void = {}) {
        self.grid.cellCount = self.subviews.count

        if subviews.isEmpty {
            onCompletionTask()
        }
        else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [],
            animations:{ [unowned self] in
                for (index, cardView) in self.subviews.enumerated() {
                    if !cardView.isHidden {
                        cardView.frame = self.grid[index]!
                    }
                }
            }, completion: {position in
                onCompletionTask()
            })
        }
    }
    
    override func layoutSubviews() {
        if grid.frame != bounds
        {
            grid.frame = bounds
            resizeExistingCards()
            
            let hiddenCards = subviews.filter { $0 is UICardView && $0.isHidden }
            hiddenCards.forEach {
                $0.center = getDeckRect().center
            }
        }
    }

    func replaceCards(_ cardsToRemove:[SetCard], with newCards: [SetCard], additionalTaskBetweenRemovalAndAddition: @escaping () -> Void) {
        assert(!cardsToRemove.isEmpty, "No cards to remove")
        //assert(!newCards.isEmpty, "No cards to add")

        let cardViewsToRemove = getViewsForCards(cardsToRemove)
        moveToSuperview(views: cardViewsToRemove.0) //So that we can safely add new subviews before waiting for these views to be removed by animation
        
        var postCompletionOfCardRemoval: () -> Void = {}
        if newCards.isEmpty {
            postCompletionOfCardRemoval = {[unowned self] in
                additionalTaskBetweenRemovalAndAddition()
                self.resizeExistingCards()
            }
        }
        else {
            let newCardViews = addCards(newCards, atSuperViewIndexes: cardViewsToRemove.1)
            postCompletionOfCardRemoval = {[unowned self] in
                additionalTaskBetweenRemovalAndAddition()
                self.animateAdditionOfViews(newCardViews)
            }
        }
        
        removeCards(cardsViews: cardViewsToRemove.0, onCompletion: postCompletionOfCardRemoval)
    }
    
    private func moveToSuperview(views: [UIView]) {
        let newParent = superview!
        views.reversed().forEach{viewToMove in
            let frameInNewParent = newParent.convert(viewToMove.frame, from: self)
            viewToMove.frame = frameInNewParent
            newParent.addSubview(viewToMove)
            newParent.sendSubview(toBack: viewToMove)
        }
        if firstMatchedCard != nil {
            newParent.sendSubview(toBack: firstMatchedCard!)
        }
        newParent.sendSubview(toBack: self)
    }
    
    private func removeCards(cardsViews: [UICardView], onCompletion onCompletionTask:@escaping () -> Void) {
        var timeDurationForDynamicAnimation = 5.0
        let successiveDelay = 0.5
        let lastCardToBeRemoved = cardsViews.last!
        let cardSuperview = lastCardToBeRemoved.superview!
        let discardRect = cardSuperview.convert(getDiscardCardThrowRect(), from: self)
        cardsViews.forEach{view in
            cardBehaviour.addItem(view)
            cardRemovalTimer = Timer.scheduledTimer(withTimeInterval: timeDurationForDynamicAnimation, repeats: false, block: {timer in
                self.cardBehaviour.removeItem(view)
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0, options: [.curveEaseOut], animations: {
                    view.center = discardRect.center
                    view.transform = CGAffineTransform.identity.rotated(by: -CGFloat.pi/2).scaledBy(x: discardRect.height/view.bounds.width*1.05, y: discardRect.width/view.bounds.height*1.05)
                }, completion: {position in
                    if view == lastCardToBeRemoved
                    {
                        let viewsOtherThanLast = cardsViews.filter{$0 != view}
                        viewsOtherThanLast.forEach{$0.removeFromSuperview()}
                        UIView.transition(with: view, duration: 1, options: .transitionFlipFromTop, animations: {
                            view.isFaceDown = true
                            view.setNeedsDisplay()
                        }, completion: {status in
                            if self.firstMatchedCard == nil {
                                self.firstMatchedCard = view
                            }
                            else {
                                view.removeFromSuperview()
                            }
                        })
                    }
                })
            })
            timeDurationForDynamicAnimation += successiveDelay
        }
        onCompletionTask()
    }
    
    private func addCards(_ cards: [SetCard], atSuperViewIndexes superViewIndexes: [Int]) -> [UICardView] {
        var newViews = [UICardView]()
        for (index, newCard) in cards.enumerated() {
            let cardView = UICardView(frame: getDeckRect(), card: newCard, gestureRecognizer: cardTapReceiver)
            cardView.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi/2)
            insertSubview(cardView, at: superViewIndexes[index])
            newViews.append(cardView)
        }
        
        return newViews
    }
    
    private func animateAdditionOfViews(_ views: [UICardView]) {
        var successiveDelay = 0.0
        views.forEach{view in
            if let indexInSuperView = self.subviews.firstIndex(of: view) {
                cardAdditionTimer = Timer.scheduledTimer(withTimeInterval: successiveDelay, repeats: false, block: {timer in
                    view.isHidden = false
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0, options: [.curveEaseIn], animations: {
                        if let targetFrame = self.grid[indexInSuperView] {
                            view.transform = CGAffineTransform.identity.scaledBy(x: targetFrame.width/view.bounds.width, y: targetFrame.height/view.bounds.height)
                            view.center = targetFrame.center
                        }
                    }
                        , completion: {position in
                            if let targetFrame = self.grid[indexInSuperView] {
                                view.transform = CGAffineTransform.identity
                                view.frame = targetFrame
                                UIView.transition(with: view, duration: 1, options: .transitionFlipFromLeft, animations: {
                                    view.isFaceDown = false
                                })
                            }
                    })
                })
            }
            successiveDelay += 0.3
        }
    }
    
    func stopAnyOngoingActivity(){
        cardRemovalTimer?.invalidate()
        cardAdditionTimer?.invalidate()
        superview?.subviews.forEach{ subview in
            if subview is UICardView {
                subview.removeFromSuperview()
            }
        }
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width/2, y: center.y - size.height/2)
        self.init(origin: origin, size: size)
    }
}

extension CGFloat
{
    var arc4random : CGFloat
    {
        if self > 0
        {
            return CGFloat(arc4random_uniform(UInt32(self)))
        }
        else if self < 0
        {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        }
        else
        {
            return 0
        }
    }
}
