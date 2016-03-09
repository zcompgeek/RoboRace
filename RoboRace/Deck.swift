//
//  Deck.swift
//  RoboRace
//
//  Created by Zach Costa on 8/1/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//
import Foundation

let options = [ Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here"),Card("title here", "description here") ]


class Deck: CustomStringConvertible {
    let isOptionsDeck: Bool
    let cards: Queue<Card>
    
    var description: String {
        var toReturn = ""
        let temp = Queue<Card>()
        while !cards.isEmpty() {
            if let card = cards.dequeue() {
                if isOptionsDeck {
                    toReturn += "TYPE: Option Title: \(card.title) Description \(card.desc) \n"
                } else {
                    toReturn += "TYPE: \(card.cardType) PRIORITY: \(card.priority) \n"
                }
                temp.enqueue(card)
            }
        }
            while !temp.isEmpty() {
                cards.enqueue(temp.dequeue()!)
            }
        return toReturn
    }
    
    func shuffle() {
        var tempDeck = [Card]()
        while !cards.isEmpty() {
            tempDeck.append(cards.dequeue()!)
        }
        for (var i: Int = tempDeck.count - 1; i > 0; i--) {
            // Pick a random index from 0 to i
            let j = Int(arc4random_uniform(84)) % (i + 1)
            
            // Swap arr[i] with the element at random index
            let temp = tempDeck[i]
            tempDeck[i] = tempDeck[j]
            tempDeck[j] = temp
        }
        
        for card in tempDeck {
            cards.enqueue(card)
        }
    }
    
    func isEmpty() -> Bool {
        return cards.isEmpty()
    }
    
    func draw() -> Card? {
        return cards.dequeue()
    }
    
    func insert(card: Card) {
        cards.enqueue(card)
    }
    
    //Card Priority
    // 0 - 100 = UTurn
    // 100 - 400 = TurnLeft and TurnRight
    // 400 - 500 = Backup
    // 500 - 600 = Move 1
    // 600 - 700 = Move 2
    // 700 - 800 = Move 3
    
    //84 program cards- There are forty-two movement cards and forty-two rotate cards 
    //18 x Move 1, 12 x Move 2, 6 x Move 3, 6 x Back-up, 18 x Rotate Right, 18 x Rotate Left and 6 x U-Turn
    
    init(isOptionsDeck: Bool) {
        self.isOptionsDeck = isOptionsDeck
        cards = Queue<Card>()
        if isOptionsDeck {
            for option in options {
                cards.enqueue(option)
            }
        }
        else {
            var priorityNum = 30;
            for (var i = 0; i < 6; i++, priorityNum += 10)  {
                cards.enqueue(Card(cardType: CardType.UTurn, priority: priorityNum))
            }
            priorityNum = 100
            for (var i = 0; i < 36; i++, priorityNum += 5) {
                if i % 2 == 0 {
                    cards.enqueue(Card(cardType: CardType.TurnLeft, priority: priorityNum))
                } else {
                    cards.enqueue(Card(cardType: CardType.TurnRight, priority: priorityNum))
                }
            }
            priorityNum = 400
            for (var i = 0; i < 6; i++, priorityNum += 10) {
                cards.enqueue(Card(cardType: CardType.BackUp, priority: priorityNum))
            }
            priorityNum = 500
            for (var i = 0; i < 18; i++, priorityNum += 10) {
                cards.enqueue(Card(cardType: CardType.Move1, priority: priorityNum))
            }
            priorityNum = 680
            for (var i = 0; i < 12; i++, priorityNum += 10) {
                cards.enqueue(Card(cardType: CardType.Move2, priority: priorityNum))
            }
            priorityNum = 800
            for (var i = 0; i < 6; i++, priorityNum += 10) {
                cards.enqueue(Card(cardType: CardType.Move3, priority: priorityNum))
            }
        }
    }

}
