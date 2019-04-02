//
//  GameOfSet.swift
//  GameSet
//
//  Created by Ashish Bansal on 24/08/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import Foundation

struct GameOfSet
{
    private var cardDeck = SetCard.createCardDeck()
    var cardDeckEmpty: Bool {
        return cardDeck.isEmpty
    }
    private(set) var cardsInPlay = [SetCard]()
    private var selectedCardsFormASet = false {
        didSet {
            if selectedCardsFormASet == true {
                replaceSelectedCards()
            }
        }
    }
    private(set) var score = 0
    private(set) var selectedCards: Set<SetCard> = [] {
        didSet{
            assert(selectedCards.count <= 3, "Selected cards can never be more than 3")
            selectedCardsFormASet = false
            if selectedCards.count == 3
            {
                if SetCard.checkForSet(selectedCards)
                {
                    selectedCardsFormASet = true
                    score += 3
                }
                else{
                    score -= 5
                }
            }
        }
    }
    
    private(set) var replacedCardsInCaseOfMatch = [SetCard]()
    
    private var selectedCardStatus: SelectedCardsStatus{
        switch selectedCards.count
        {
        case 0..<3: return .partial
        case 3 where selectedCardsFormASet: return .match
        case 3 where !selectedCardsFormASet: return .nonMatch
        default:
            fatalError("Invalid condition found when getting selectedCardStatus")
        }
    }
    
    enum SelectedCardsStatus
    {
        case partial, match, nonMatch
    }
    
    init(numberOfCardsToStart: Int)
    {
        precondition(numberOfCardsToStart <= cardDeck.count, "Requested number of cards cannot exceed the game deck size")
        shuffleDeck()
        for _ in 0..<numberOfCardsToStart
        {
            cardsInPlay.append(cardDeck.removeFirst())
        }
    }
    
    mutating func chooseCard(_ chosenCard: SetCard) -> (SelectedCardsStatus, [SetCard])
    {
        assert(cardsInPlay.contains(chosenCard), "Choosen card is not in the game")
        
        if selectedCards.count == 3 {
            selectedCards.removeAll()
            selectedCards.insert(chosenCard)
        }
        else {
            if selectedCards.contains(chosenCard) {
                selectedCards.remove(chosenCard)
            }
            else {
                selectedCards.insert(chosenCard)
            }
        }
        
        return (selectedCardStatus, replacedCardsInCaseOfMatch)
    }
    
    mutating func cheat() -> (Bool, [SetCard])
    {
        selectedCards.removeAll()
        var matchingCards = [SetCard]()

        for (indexFirstCard,firstCard) in cardsInPlay[0..<cardsInPlay.count-2].enumerated()
        {
            for (indexSecondCard, secondCard) in cardsInPlay[(indexFirstCard+1)..<cardsInPlay.count-1].enumerated()
            {
                let cardForSet = SetCard.deduceThirdCardForSet(firstCard: firstCard, secondCard: secondCard)
                let cardsToSearch = cardsInPlay[(indexSecondCard+1)...]
                if cardsToSearch.contains(cardForSet)
                {
                    matchingCards.append(firstCard)
                    matchingCards.append(secondCard)
                    matchingCards.append(cardForSet)
                    return (true, matchingCards)
                }
            }
        }
        
        return (false, [SetCard]())
    }
    
    private mutating func replaceSelectedCards()
    {
        replacedCardsInCaseOfMatch = [SetCard]()
        for card in selectedCards
        {
            let index = cardsInPlay.index(of: card)!
            if let newCardFromDeck = cardDeck.removeFirstIfAvailable()
            {
                cardsInPlay[index] = newCardFromDeck
                replacedCardsInCaseOfMatch.append(newCardFromDeck)
            }
            else
            {
                cardsInPlay.remove(at: index)
            }
        }
    }
    
    mutating func dealMoreCards() -> [SetCard]
    {
        var newCards = [SetCard]()
        for _ in 1...3
        {
            if let newCardFromDeck = cardDeck.removeFirstIfAvailable()
            {
                cardsInPlay.append(newCardFromDeck)
                newCards.append(newCardFromDeck)
            }
        }
        
        return newCards
    }
    
    private mutating func shuffleDeck()
    {
        var shuffledCardDeck = [SetCard]()
        let initialCardDeckSize = cardDeck.count
        for _ in 0..<initialCardDeckSize
        {
            let indexOfARandomCard = Int(arc4random_uniform(UInt32(cardDeck.count)))
            let randomCard = cardDeck.remove(at: indexOfARandomCard)
            shuffledCardDeck.append(randomCard)
        }
        
        cardDeck = shuffledCardDeck
    }
    
    mutating func shuffleCardsInPlay()
    {
        var shuffledCardsInPlay = [SetCard]()
        let countCardsInPlay = cardsInPlay.count
        for _ in 0..<countCardsInPlay
        {
            let indexOfARandomCard = Int(arc4random_uniform(UInt32(cardsInPlay.count)))
            let randomCard = cardsInPlay.remove(at: indexOfARandomCard)
            shuffledCardsInPlay.append(randomCard)
        }
        
        cardsInPlay = shuffledCardsInPlay
    }
}

extension Array
{
    mutating func removeFirstIfAvailable() -> Element?
    {
        if self.count > 0
        {
            return self.removeFirst()
        }
        else
        {
            return nil
        }
    }
}
