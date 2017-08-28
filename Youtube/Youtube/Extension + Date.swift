//
//  Extension + Date.swift
//  Youtube
//
//  Created by MAC on 8/28/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
let dateUnitMapping: [Character: Calendar.Component] = ["Y": .year, "M": .month, "W": .weekOfYear, "D": .day]
let timeUnitMapping: [Character: Calendar.Component] = ["H": .hour, "M": .minute, "S": .second]

extension String {
    var durationUnitValues: [(Calendar.Component, Int)]? {
        guard self.hasPrefix("P") else {
            return nil
        }
        
        let duration = String(self.characters.dropFirst())
        
        guard let separatorRange = duration.range(of: "T") else {
            return duration.unitValuesWithMapping(dateUnitMapping)
        }
        
        let date = duration.substring(to: separatorRange.lowerBound)
        let time = duration.substring(from: separatorRange.upperBound)
        guard let dateUnits = date.unitValuesWithMapping(dateUnitMapping),
            let timeUnits = time.unitValuesWithMapping(timeUnitMapping) else {
                return nil
        }
        
        return dateUnits + timeUnits
    }
    
    func unitValuesWithMapping(_ mapping: [Character: Calendar.Component]) -> [(Calendar.Component, Int)]? {
        if self.isEmpty {
            return []
        }
        
        var components: [(Calendar.Component, Int)] = []
        
        let identifiersSet = CharacterSet(charactersIn: String(mapping.keys))
        
        let scanner = Scanner(string: self)
        while !scanner.isAtEnd {
            var value: Int = 0
            if !scanner.scanInt(&value) {
                return nil
            }
            var identifier: NSString?
            if !scanner.scanCharacters(from: identifiersSet, into: &identifier) || identifier?.length != 1 {
                return nil
            }
            let unit = mapping[Character(identifier! as String)]!
            components.append((unit, value))
        }
        return components
    }
    
    func dateComponents() -> DateComponents {
        guard let unitValues = self.durationUnitValues else {
            return DateComponents()
        }
        
        var components = DateComponents()
        for (unit, value) in unitValues {
            components.setValue(value, for: unit)
        }
        return components
    }
}

extension DateComponents {
    func convertToSecond() -> Int {
        var aSecond = 0
        var aminute = 0
        var aHour = 0
        var aDay = 0
        if let _second = self.second {
            aSecond = _second
        }
        if let _minute = self.minute {
            aminute = _minute
        }
        if let _hour = self.hour {
            aHour = _hour
        }
        if let _day = self.day {
            aDay = _day
        }
        return (aSecond + 60 * aminute + 3600 * aHour + 86400 * aDay)
    }
}

