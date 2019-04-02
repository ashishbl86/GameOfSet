//
//  ViewController.swift
//  Concentration
//
//  Created by Ashish Bansal on 13/05/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController
{
    private lazy var game = Concentration(numberOfPairOfCards: numberOfPairOfCards)
    
    var numberOfPairOfCards : Int
    {
        return (cardButtons.count + 1) / 2
    }
    
    let attributes : [NSAttributedStringKey:Any] = [.strokeWidth : 5.0,
                                                    .strokeColor : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)]
    
    private func updateFlipCountLabel()
    {
        flipCountLabel.attributedText = NSAttributedString(string: "Flips: \(game.flipCount)", attributes: attributes)
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    {
        didSet{
            updateFlipCountLabel()
        }        
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    {
        didSet{
            updateScoreLabel()
        }
    }
    
    func updateScoreLabel()
    {
        scoreLabel.attributedText = NSAttributedString(string: "Score: \(game.score)", attributes: attributes)
    }
    
    @IBAction private func restartGameButton(_ sender: UIButton)
    {
        game.reset()
        emojiChoices = getEmojiChoicesFromATheme()
        cardEmojis.removeAll()
        updateViewAsPerModel()
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let indexTouchedCard = cardButtons.index(of: sender)
        {
            game.chooseCard(at: indexTouchedCard)
            updateViewAsPerModel()
        }
    }
    
    private func updateViewAsPerModel()
    {
        if cardButtons != nil {
            for index in cardButtons.indices
            {
                let button = cardButtons[index]
                let card = game.cards[index]
                
                if card.isFaceUp
                {
                    button.setTitle(getTitleForCard(card), for: UIControlState.normal)
                    button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else
                {
                    button.setTitle("", for: UIControlState.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                }
            }
            
            updateFlipCountLabel()
            updateScoreLabel()
        }
    }
    
    var theme: String? {
        didSet {
            emojiChoices = theme ?? ""
            cardEmojis = [:]
            updateViewAsPerModel()
        }
    }
    
    private var emojiChoicesCollection = ["Food":"🧀🌮🍕🍔🍗🍪🍩🍰",
                                          "Faces":"😀☺️😇😍🤪🤓🤩😡",
                                          "Animals":"🐶🐽🐸🐒🐤🦉🐝🦆",
                                          "Sports":"⚽️🏀🏈🎾⚾️🏐🏉🎱",
                                          "Transports":"🚗🚚🚲🚜🛵🚠🚂✈️",
                                          "Flags":"🏁🇧🇷🇨🇦🇨🇳🇮🇳🇯🇵🇱🇷🚩"]
    
    private lazy var emojiChoices : String = emojiChoicesCollection["Flags"]! //getEmojiChoicesFromATheme()
    
    func getEmojiChoicesFromATheme() -> String{
        let listOfThemes = Array(emojiChoicesCollection.keys)
        let randomTheme = listOfThemes[listOfThemes.count.arc4random]
        return emojiChoicesCollection[randomTheme]!
    }
    
    private var cardEmojis = [Card:String]()
    
    private func getTitleForCard(_ card: Card) -> String
    {
        if cardEmojis[card] == nil && emojiChoices.count > 0
        {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            cardEmojis[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        
        return cardEmojis[card] ?? "?"
    }
}

extension Int
{
    var arc4random : Int
    {
        if self > 0
        {
            return Int(arc4random_uniform(UInt32(self)))
        }
        else if self < 0
        {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        }
        else
        {
            return 0
        }
    }
}
