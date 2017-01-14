//
//  WordCounterClass.swift
//  WordCounter
//
//  Created by Arefly on 7/8/2015.
//  Copyright (c) 2015 Arefly. All rights reserved.
//

import Foundation

class WordCounter {
    // MARK: - Var
    var punctuations = [".", "!", "?", ";", "。", "！", "？", "；"]

    
    // MARK: - Get string func
    func getCountString(_ s: String, type: String) -> String {
        let count = getCount(s, type: type)
        
        let words = (count == 1) ?
            NSLocalizedString("Global.Units.\(type).Singular", comment: "Singular Unit") :
            NSLocalizedString("Global.Units.\(type).Plural", comment: "Plural Unit")
        
        let returnString = String.localizedStringWithFormat(NSLocalizedString("Global.Count.Text.\(type)", comment: "%1$@ %2$@"), String(count), words)
        
        return returnString
    }
    
    // MARK: - Get count func
    func getCount(_ s: String, type: String) -> Int {
        var returnInt = 0
        
        switch type {
        case "Word":
            returnInt = wordCount(s)
            break
        case "Character":
            returnInt = characterCount(s)
            break
        case "Paragraph":
            returnInt = paragraphCount(s)
            break
        case "Sentence":
            returnInt = sentenceCount(s)
            break
        default:
            returnInt = 0
        }
        
        return returnInt
    }
    
    func wordCount(_ inputString: String) -> Int {
        
        var s = inputString
        for punctuation in punctuations {
            // Remove punctuations
            s = s.replacingOccurrences(of: punctuation, with: "")
        }
        
        var counts = 0
        let lines = s.components(separatedBy: CharacterSet.newlines)
        let joinedString = lines.joined(separator: " ")
        let words = joinedString.components(separatedBy: CharacterSet.whitespaces)
        
        let modifiedWords = words.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            
            if(s!.containsChineseCharacters){
                var results = self.matchesForRegexInText("\\p{Han}", text: s!)
                var sArray: Array = Array((s!).characters)
                if(String(sArray[0]) != results[0]){
                    counts += 1
                }
                //print(sArray[count(sArray)-1])
                //print(results[count(results)-1])
                if(String(sArray[sArray.count-1]) != results[results.count-1]){
                    counts += 1
                }
                counts += results.count
                return false
            }
            
            return true
        })
        
        counts += modifiedWords.count
        
        return counts
    }
    
    func characterCount(_ s: String) -> Int {
        var characterCounts = 0
        let modifiedCharacter = Array(s.characters).filter({
            let s = String($0) as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            if (s == "\n") { return false }
            if s! == " " { return false }
            return true
        })
        characterCounts = modifiedCharacter.count
        
        return characterCounts
    }
    
    func paragraphCount(_ s: String) -> Int {
        var paragraphCounts = 0
        let lines = s.components(separatedBy: CharacterSet.newlines)
        let modifiedLines = lines.filter({
            let s = $0 as String?
            if !(s != nil) { return false }
            if (s!).characters.count < 1 { return false }
            if (s!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) { return false }
            return true
        })
        paragraphCounts = modifiedLines.count
        return paragraphCounts
    }
    
    func sentenceCount(_ s: String) -> Int {
        var sentenceCounts = 0
        var sentencesArr = [String]()
        s.enumerateSubstrings(in: s.characters.indices, options: .bySentences) {
            substring, substringRange, enclosingRange, stop in
            sentencesArr.append(substring!)
        }
        let modifiedLines = sentencesArr.filter({
            let oS = ($0 as String?)!
            let s = oS.trimmingCharacters(in: CharacterSet(charactersIn: "\n "))
            
            if (s).characters.count < 1 { return false }
            
            return true
        })
        
        sentenceCounts = modifiedLines.count
        return sentenceCounts
    }
    
    // MARK: - Related func
    /**
    Search `regex` in `text`
    
    - Parameter regex:  The regex.
    - Parameter text:   The text.
    
    - Returns: A new `[string]` with result.
    */
    fileprivate func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex,
            options: [])
        let nsString = text as NSString
        let results = regex.matches(in: text, options: [], range: NSMakeRange(0, nsString.length)) 
        return results.map { nsString.substring(with: $0.range)}
    }
}

extension String {
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
}
