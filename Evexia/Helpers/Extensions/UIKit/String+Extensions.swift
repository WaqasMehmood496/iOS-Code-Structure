//
//  String+Extensions.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import Foundation

extension String {
    
    func localized() -> String {
        let appLanguage = "en"
        
        if let path = Bundle.main.path(forResource: appLanguage, ofType: "lproj"), let bundle = Bundle(path: path) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        
        return ""
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    var isValidPassword: Bool {
        let emailRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    var isValidHeight: Bool {
        guard !self.isEmpty else { return true }
        guard let value = Int(self) else { return false }
        return (40...300).contains(value)
    }
    
    var isValidWeight: Bool {
        guard !self.isEmpty else { return true }
        guard let value = Int(self) else { return false }
        return (20...500).contains(value)
    }
    
    var isValidName: Bool {
        return (1...20).contains(self.count)
    }
    
    var isValidAge: Bool {
        guard !self.isEmpty else { return false }
        guard let value = Int(self) else { return false }
        return (12...120).contains(value)
    }
    
    var wrappedPhoneNumber: String {
        return self.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "")
    }
}

extension String {
    func changeMeasurementSystem(unitType: UnitsType, manualMeasurement: (with: Dimension, to: Dimension)? = nil) -> MeasurObject {
        guard let doubleValue = Double(self),
              let unitTyple = getMeasurementUnit(unitType: unitType, manualMeasurement: manualMeasurement) else {
            return .emptyState
        }
        
        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitOptions = .providedUnit
      
        let measurement = Measurement(value: doubleValue, unit: unitTyple.with) // pound
        let newMeasurement = measurement.converted(to: unitTyple.to) // kilo
        var symbolNumber = 0

        if unitTyple.to == UnitLength.feet {
            symbolNumber = 1
        } else if unitTyple.to == UnitMass.stones {
            symbolNumber = 2
        }

        let value = String(format: "%.\(isMetricSystem ? 0 : symbolNumber)f", newMeasurement.value)
        
        return .init(fullTitle: newMeasurement.description, roundedFullTitle: "\(value) \(newMeasurement.unit.symbol)", value: value, symbol: newMeasurement.unit.symbol, doubleValue: measurement.value)
    }

    private func getMeasurementUnit(unitType: UnitsType, manualMeasurement: (with: Dimension, to: Dimension)?) -> (with: Dimension, to: Dimension)? {
        if let type = MeasurementSystemType(rawValue: UserDefaults.measurement) {
            
            if let manualMeasurement = manualMeasurement {
                return manualMeasurement
            } else if unitType == .mass {
                return type == .us ? (UnitMass.kilograms, UnitMass.stones) : (UnitMass.stones, UnitMass.kilograms)
            } else {
                return type == .us ? (UnitLength.centimeters, UnitLength.feet) : (UnitLength.feet, UnitLength.centimeters)
            }
        } else {
            return nil
        }
    }
    
    func getUnitWithSybmols(unitType: UnitsType, isNeedBracket: Bool = false) -> Self {
        var unit = ""
        if let type = MeasurementSystemType(rawValue: UserDefaults.measurement) {
            if type == .us {
                unit = unitType == .lengh ? "ft" : "st"
            } else {
                unit = unitType == .lengh ? "cm": "kg"
            }
        }
        
        return "\(self) \(!isNeedBracket ? unit : "(\(unit))")"
    }
}
