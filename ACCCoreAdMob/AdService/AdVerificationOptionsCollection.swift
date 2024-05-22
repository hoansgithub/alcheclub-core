//
//  AdVerificationOptionsCollection.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import Foundation
public struct AdVerificationOptionsCollection : Collection {
    public typealias DictionaryType = Dictionary<String, String>
    private var dictionary: DictionaryType
    
    //Collection: these are the access methods
    public typealias Index = DictionaryType.Index
    public typealias Indices = DictionaryType.Indices
    public typealias Iterator = DictionaryType.Iterator
    public typealias SubSequence = DictionaryType.SubSequence
    
    public var startIndex: Index { return dictionary.startIndex }
    public var endIndex: DictionaryType.Index { return dictionary.endIndex }
    public subscript(position: Index) -> Iterator.Element { return dictionary[position] }
    public subscript(bounds: Range<Index>) -> SubSequence { return dictionary[bounds] }
    public var indices: Indices { return dictionary.indices }
    public subscript(key: String) -> String {
        get { return dictionary[key] ?? "" }
        set { dictionary[key] = newValue }
    }
    public func index(after i: Index) -> Index {
        return dictionary.index(after: i)
    }
    
    //Sequence: iteration is implemented here
    public func makeIterator() -> DictionaryIterator<String, String> {
        return dictionary.makeIterator()
    }
}
