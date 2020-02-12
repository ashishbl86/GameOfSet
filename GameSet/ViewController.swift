//
//  ViewController.swift
//  GameSet
//
//  Created by Ashish Bansal on 23/08/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TapGestureRecognizer {
    
    private var gameScore = 0 {
        didSet {
            scoreLabel.text = "Score: \(gameScore)"
        }
    }
    
    func tapOccurred(card: SetCard) {
        let chooseResult = game.chooseCard(card)
        
        switch chooseResult {
        case (.partial, _):
            cardViewContainer.highlightCards(Array(game.selectedCards), withColor: UIColor.yellow)
        case (.nonMatch, _):
            cardViewContainer.highlightCards(Array(game.selectedCards), withColor: UIColor.red)
            cardViewContainer.shakeCards(Array(game.selectedCards), onCompletion: {[unowned self] in
                self.cardViewContainer.unhighlightCards(Array(self.game.selectedCards))})
            gameScore += -1
        case (.match, let newCards):
            cardViewContainer.unhighlightCards(Array(game.selectedCards))
            cardViewContainer.replaceCards(Array(game.selectedCards), with: newCards, additionalTaskBetweenRemovalAndAddition: {
                self.hideDealButtonIfCardDeckIsEmpty()
            })
            gameScore += 3
        }
    }
    
    private var dealButtonTitle: String?
    private var dealButtonColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dealButtonTitle = dealButton.currentTitle
        dealButtonColor = dealButton.backgroundColor
        
        dealButton.layer.cornerRadius = dealButton.bounds.width * 0.1
        //let scoreLabelColor = scoreLabel.backgroundColor
        //scoreLabel.backgroundColor = UIColor.clear
        //scoreLabel.layer.backgroundColor = scoreLabelColor?.cgColor
        scoreLabel.layer.cornerRadius = scoreLabel.bounds.width * 0.1
        
        cardViewContainer.grid.frame = cardViewContainer.bounds
        cardViewContainer.getNewCardPickupRect = {[weak self] in
            return self?.dealButton?.superview?.convert((self?.dealButton?.frame)!, to: self?.cardViewContainer) ?? CGRect.zero
        }
        
        cardViewContainer.getDiscardCardThrowRect = {[weak self] in
            return self?.scoreLabel?.superview?.convert((self?.scoreLabel?.frame)!, to: self?.cardViewContainer) ?? CGRect.zero
        }
        
        cardViewContainer.superview?.sendSubview(toBack: cardViewContainer)
        //self.dealButton.superview?.bringSubview(toFront: self.dealButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.cardViewContainer.addCards(cards: self.game.cardsInPlay, additionalTaskJustBeforeAddition: {
                self.hideDealButtonIfCardDeckIsEmpty()
            })
        }
    }
    
    @IBOutlet weak var cardViewContainer: UICardContainerView!
    {
        didSet{
            cardViewContainer.cardTapReceiver = self
//            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipePerformed(sender:)))
//            swipeRecognizer.direction = [.right, .left]
//            cardViewContainer.addGestureRecognizer(swipeRecognizer)
//
//            let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationPerformed(sender:)))
//            cardViewContainer.addGestureRecognizer(rotationRecognizer)
        }
    }
    
//    @objc func swipePerformed(sender: UIGestureRecognizer)
//    {
//        switch sender.state
//        {
//        case .changed, .ended:
//            game.dealMoreCards()
//            updateViewAsPerModel()
//        default:
//            break
//        }
//    }
//
//    @objc func rotationPerformed(sender: UIRotationGestureRecognizer)
//    {
//        switch sender.state
//        {
//        case .ended:
//            game.shuffleCardsInPlay()
//            updateViewAsPerModel()
//        default:
//            break
//        }
//    }
    
    var game = GameOfSet(numberOfCardsToStart: 12)
    
    @IBAction func deal3CardsButton(_ sender: UIButton) {
        dealMoreCardsButtonPressed()
    }
    
    @discardableResult
    private func dealMoreCardsButtonPressed() -> Bool {
        let newCards = game.dealMoreCards()
        cardViewContainer.addCards(cards: newCards, additionalTaskJustBeforeAddition: {
            self.hideDealButtonIfCardDeckIsEmpty()
        })
        return !newCards.isEmpty
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    
    @IBAction func restartButton(_ sender: UIButton) {
        game = GameOfSet(numberOfCardsToStart: 12)
        cardViewContainer.stopAnyOngoingActivity()
        cardViewContainer.subviews.forEach{$0.removeFromSuperview()}
        cardViewContainer.addCards(cards: game.cardsInPlay, additionalTaskJustBeforeAddition: {
            self.hideDealButtonIfCardDeckIsEmpty()
        })
        
        restoreButtonsToOriginalState()
        gameScore = 0
    }
    
    @IBAction func cheatButton(_ sender: UIButton) {
        gameScore += -2
        let cheatResult = game.cheat()
        if cheatResult.0 {
            cardViewContainer.highlightCards(cheatResult.1, withColor: UIColor.magenta)
            //cheatResult.1.forEach{tapOccurred(card: $0)}
        }
        else {
            if dealMoreCardsButtonPressed() {
                cheatButton(sender)
            }
        }
    }
    
    func hideDealButtonIfCardDeckIsEmpty() {
        if game.cardDeckEmpty {
            self.dealButton.backgroundColor = UIColor.clear
            self.dealButton.setTitle(nil, for: .normal)
        }
    }
    
    func restoreButtonsToOriginalState() {
        dealButton.backgroundColor = dealButtonColor
        dealButton.setTitle(dealButtonTitle, for: .normal)
        cardViewContainer.firstMatchedCard?.removeFromSuperview()
    }
}
