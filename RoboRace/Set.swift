////
////  Set.swift
////  CookieCrunch
////
////  Created by Zach Costa on 7/24/14.
////  Copyright (c) 2014 Zach Costa. All rights reserved.
////
//class Set<T: Hashable>: SequenceType, CustomStringConvertible {
//    var dictionary = Dictionary<T, Bool>()  // private
//    
//    func addElement(newElement: T) {
//        dictionary[newElement] = true
//    }
//    
//    func removeElement(element: T) {
//        dictionary[element] = nil
//    }
//    
//    func containsElement(element: T) -> Bool {
//        return dictionary[element] != nil
//    }
//    
//    func allElements() -> [T] {
//        return Array(dictionary.keys)
//    }
//    
//    var count: Int {
//    return dictionary.count
//    }
//    
//    func unionSet(otherSet: Set<T>) -> Set<T> {
//        let combined = Set<T>()
//        
//        for obj in dictionary.keys {
//            combined.dictionary[obj] = true
//        }
//        
//        for obj in otherSet.dictionary.keys {
//            combined.dictionary[obj] = true
//        }
//        
//        return combined
//    }
//    
//    func generate() -> IndexingGenerator<Array<T>> {
//        return allElements().generate()
//    }
//    
//    var description: String {
//    return dictionary.description
//    }
//}