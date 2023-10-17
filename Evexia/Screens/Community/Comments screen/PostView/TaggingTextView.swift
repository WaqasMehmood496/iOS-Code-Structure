//
//  TaggingTextView.swift
//  Evexia
//
//  Created by admin on 24.05.2022.
//

import Foundation
import UIKit
import Combine
import Atributika

class TaggingTextView: UITextView {
    var selectionStart: Int = 0
    var searchText = PassthroughSubject<Search, Never>()
    var cancellables = Set<AnyCancellable>()
    var tempString: NSAttributedString?
    var savedTags = [String]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        searchText.sink { value in
            print(value)
        }.store(in: &cancellables)
    }
        
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
        
    }
    
    private var userAttributes: Style {
        return Style()
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
    }
    
    internal func applyTag(_ model: CommunityUser) {
        guard !text.isEmpty else { return }
        savedTags.append(model.username)
        if let selectedRange = self.selectedTextRange {
        let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        selectionStart = cursorPosition
        let leftTagSignPosition = cursorPosition - 1
            
        let isCurrentTagValueNotEmpty = leftTagSignPosition != cursorPosition
        let string = NSMutableAttributedString()
        string.append(self.attributedText)
        if isCurrentTagValueNotEmpty {
            string.deleteCharacters(in: NSRange(location: leftTagSignPosition, length: cursorPosition - leftTagSignPosition))
        }
            
        let attrib = NSAttributedString(string: "@" + model.username, attributes: userAttributes.attributes)
        
        string.insert(attrib, at: leftTagSignPosition)
        self.attributedText = string
        
        }
    }
    
    func getCursorPosition(text: String) {
        if let selectedRange = self.selectedTextRange {
            let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
            selectionStart = self.text.count
        }
        
        removeSpanFromClosestToCursorTagIfCorrupted(text: text)

        if let selectedRange = self.selectedTextRange {
            let text = text ?? ""
            //guard text != "@" else { return searchText.send(.search("")) }
            guard text.last != "@" else { return searchText.send(.search("")) }

            guard !text.isEmpty else { return searchText.send(.stop) }

            let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
            selectionStart = cursorPosition
            let leftTagSignPosition = getClosestTagSignPositionFromLeftOfCursor()
            let isTagSignFromLeftExists = isTagSignFromLeftOfCursorExists()
            let isTagSignHasSomethingFromLeft = isTagSignFromLeftExists && text.substring(from: leftTagSignPosition) != ""
            
            guard !text.isEmpty else {
                searchText.send(.stop)
                return
            }
            guard isTagSignHasSomethingFromLeft else {
                searchText.send(.stop)
                return
            }
            guard isTagSignFromLeftExists else {
                searchText.send(.stop)
                return
            }
            
            let currentTagValue = text[(leftTagSignPosition + 1)..<text.count]
//            let currentTagValue = text[NSRange(location: leftTagSignPosition + 1, length: cursorPosition - 1)]
           
            guard savedTags.first(where: { currentTagValue.contains($0) }) == nil else {
                searchText.send(.stop)
                return
            }
            
            if let fullTagValue = savedTags.first(where: { $0.contains(currentTagValue) }), !fullTagValue.isEmpty {
                searchText.send(.stop)

            } else {
                searchText.send(.search(String(currentTagValue)))
            }
            
        }
    }
    
    private func isTagSignFromLeftOfCursorExists() -> Bool {
        return getClosestTagSignPositionFromLeftOfCursor() != -1
    }

    private func getClosestTagSignPositionFromLeftOfCursor() -> Int {
        guard let text = text  else { return -1 }
        var cursorPosition = selectionStart
        
        let range = NSRange(text.startIndex..., in: text)
        let substring = text.substring(with: range)!
        //let substring = text.substring(to: cursorPosition)
        guard let index = substring.lastIndex(of: "@") else { return -1 }
        let int: Int = substring.distance(from: substring.startIndex, to: index)
        return int
    }
    
    private func removeSpanFromClosestToCursorTagIfCorrupted(text: String) {
        guard !savedTags.isEmpty else { return }
//        guard let text = text else { return }
        let leftTagSignPosition = getClosestTagSignPositionFromLeftOfCursor()
        let startIndex = leftTagSignPosition == -1 ? 0 : leftTagSignPosition
        
        guard startIndex + 1 < selectionStart else { return }
        
        let tagValue = text.substring(with: startIndex + 1..<selectionStart)
        print(tagValue)
        
        guard let fullTagValue = savedTags.first(where: { $0.contains(tagValue) }), !fullTagValue.isEmpty  else { return }
        
        guard fullTagValue != tagValue else { return }
        print(fullTagValue)
        
        let count = text.substring(to: leftTagSignPosition).filter { $0 == "@" }.count
        
        if let index = savedTags.lastIndex(where: { $0 == fullTagValue }) {
            if index == count {
                savedTags.remove(at: index)
            }
        }
        
        let string = NSMutableAttributedString()
        string.append(self.attributedText)
        let range = NSRange(location: startIndex, length: tagValue.count + 1)
        string.setAttributes(plainAttributes.attributes, range: range)
        self.attributedText = string
    }
    
    func getTaggedText() -> String {
        guard var string = self.text else { return "" }
        
        savedTags.forEach { tag in
            string = string.replacingOccurrences(of: "@" + tag, with: "<tag>" + tag + "</tag>")
        }
        return string
    }
    
    private func isSavedTagWasCorrupted(tag: String) -> Bool {
        return savedTags.contains(tag)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension String {
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }

    subscript (range: NSRange) -> Substring {
        //let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        //let stopIndex = self.index(self.startIndex, offsetBy: range.lowerBound + (range.upperBound - range.lowerBound))
        return self.substring(with: range)! // self[startIndex..<stopIndex]
    }

}

extension NSAttributedString {
    func rangeOf(string: String) -> Range<String.Index>? {
        return self.string.range(of: string)
    }
}

extension StringProtocol {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}

enum Search {
    case search(String)
    case stop
}

extension String {
    var range: NSRange {
        let fromIndex = unicodeScalars.index(unicodeScalars.startIndex, offsetBy: 0)
        let toIndex = unicodeScalars.index(fromIndex, offsetBy: count)
        return NSRange(fromIndex..<toIndex, in: self)
    }
}

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
