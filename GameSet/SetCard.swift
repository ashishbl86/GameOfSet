//
//  Card.swift
//  GameSet
//
//  Created by Ashish Bansal on 24/08/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import Foundation

struct SetCardAttribute
{
    enum Number: Int
    {
        case one = 1, two, three
    }
    
    enum Symbol
    {
        case diamond, oval, squiggly
    }
    
    enum Shading
    {
        case solid, stripped, open
    }
    
    enum Color
    {
        case red, green, purple
    }
    
    static func allNumbers() -> Set<Number>
    {
        return [.one, .two, .three]
    }
    
    static func allSymbols() -> Set<Symbol>
    {
        return [.diamond, .oval, .squiggly]
    }
    
    static func allShadings() -> Set<Shading>
    {
        return [.solid, .stripped, .open]
    }
    
    static func allColors() -> Set<Color>
    {
        return [.red, .green, .purple]
    }
}

struct SetCard : Hashable
{
    let number: SetCardAttribute.Number
    let symbol: SetCardAttribute.Symbol
    let shading: SetCardAttribute.Shading
    let color: SetCardAttribute.Color
    
    static func createCardDeck() -> [SetCard] {
        var cardDeck = [SetCard]()
        for number in SetCardAttribute.allNumbers()
        {
            for symbol in SetCardAttribute.allSymbols()
            {
                for shading in SetCardAttribute.allShadings()
                {
                    for color in SetCardAttribute.allColors()
                    {
                        let card = SetCard.init(number: number, symbol: symbol, shading: shading, color: color)
                        cardDeck.append(card)
                    }
                }
            }
        }
        assert(cardDeck.count == 81, "Card deck not constructed correctly")
        return cardDeck
    }
    
    static func checkForSet(_ cards: Set<SetCard>) -> Bool
    {
        assert(cards.count == 3, "Check for Set is requested for cards not counting to 3")
        //return true
        var cardNumbers: Set<SetCardAttribute.Number> = []
        var cardSymbols: Set<SetCardAttribute.Symbol> = []
        var cardShadings: Set<SetCardAttribute.Shading> = []
        var cardColors: Set<SetCardAttribute.Color> = []

        for card in cards
        {
            cardNumbers.insert(card.number)
            cardSymbols.insert(card.symbol)
            cardShadings.insert(card.shading)
            cardColors.insert(card.color)
        }

        if (cardNumbers.count == 1 || cardNumbers.count == cards.count) &&
        (cardSymbols.count == 1 || cardSymbols.count == cards.count) &&
        (cardShadings.count == 1 || cardShadings.count == cards.count) &&
        (cardColors.count == 1 || cardColors.count == cards.count)
        {
            return true
        }

        return false
    }
    
    static func deduceThirdCardForSet(firstCard: SetCard, secondCard: SetCard) -> SetCard{
        var cardNumbers: Set<SetCardAttribute.Number> = []
        var cardSymbols: Set<SetCardAttribute.Symbol> = []
        var cardShadings: Set<SetCardAttribute.Shading> = []
        var cardColors: Set<SetCardAttribute.Color> = []
        
        for card in [firstCard, secondCard]
        {
            cardNumbers.insert(card.number)
            cardSymbols.insert(card.symbol)
            cardShadings.insert(card.shading)
            cardColors.insert(card.color)
        }
        
        let setCardNumber = cardNumbers.count == 1 ? cardNumbers.removeFirst() : SetCardAttribute.allNumbers().subtracting(cardNumbers).first!
        let setCardSymbol = cardSymbols.count == 1 ? cardSymbols.removeFirst() : SetCardAttribute.allSymbols().subtracting(cardSymbols).first!
        let setCardShading = cardShadings.count == 1 ? cardShadings.removeFirst() : SetCardAttribute.allShadings().subtracting(cardShadings).first!
        let setcardColor = cardColors.count == 1 ? cardColors.removeFirst() : SetCardAttribute.allColors().subtracting(cardColors).first!
        
        return SetCard(number: setCardNumber, symbol: setCardSymbol, shading: setCardShading, color: setcardColor)
    }
    
}
