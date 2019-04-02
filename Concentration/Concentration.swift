//
//  Concentration.swift
//  Concentration
//
//  Created by Ashish Bansal on 14/05/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import Foundation

class Concentration
{
    private(set) var cards = [Card]()
    
    private(set) var flipCount = 0
    
    private(set) var score = 0
    
    private var indexOfOnlyOneCardFaceUp: Int?
    {
        get {
            return cards.indices.filter{cards[$0].isFaceUp}.oneAndOnly
        }
        set {
            for index in cards.indices
            {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    func chooseCard(at indexChosenCard: Int)
    {
        assert(cards.indices.contains(indexChosenCard), "Failed assertion on chooseCard")
        if cards[indexChosenCard].isFaceUp || cards[indexChosenCard].isMatched
        {
            return
        }
        
        flipCount += 1
        
        if let alreadyFaceUpCardIndex = indexOfOnlyOneCardFaceUp
        {
            cards[indexChosenCard].isFaceUp = true
            if cards[indexChosenCard] == cards[alreadyFaceUpCardIndex]
            {
                cards[indexChosenCard].isMatched = true
                cards[alreadyFaceUpCardIndex].isMatched = true
                score += 2;
            }
            else
            {
                if cards[alreadyFaceUpCardIndex].seenOnce
                {
                    score -= 1
                }
                else
                {
                    cards[alreadyFaceUpCardIndex].seenOnce = true
                }
                
                if cards[indexChosenCard].seenOnce
                {
                    score -= 1
                }
                else
                {
                    cards[indexChosenCard].seenOnce = true
                }
            }
        }
        else
        {
           indexOfOnlyOneCardFaceUp = indexChosenCard
        }
    }
    
    init (numberOfPairOfCards: Int)
    {
        assert(numberOfPairOfCards > 0, "Failed assertion at concentration.init")
        for _ in 1...numberOfPairOfCards
        {
            let card = Card()
            cards += [card, card]
        }
        
        shuffleCards()
    }
    
    private func shuffleCards()
    {
        var shuffledCards = [Card]()
        for _ in cards.indices
        {
            let indexOfARandomCard = Int(arc4random_uniform(UInt32(cards.count)))
            let randomCard = cards.remove(at: indexOfARandomCard)
            shuffledCards.append(randomCard)
        }
        
        cards = shuffledCards
    }
    
    func reset()
    {
        for index in cards.indices
        {
            cards[index].reset()
        }
        indexOfOnlyOneCardFaceUp = nil
        shuffleCards()
        flipCount = 0
        score = 0
    }
}

extension Collection
{
    var oneAndOnly : Element? {
        return count == 1 ? first : nil
    }
}
