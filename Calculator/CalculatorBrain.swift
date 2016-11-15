//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Milos Menicanin on 8/24/16.
//  Copyright © 2016 Milos Menicanin. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    
    fileprivate var accumulator = 0.0
    fileprivate var descriptionAccumulator = " "
    fileprivate var internalProgram = [AnyObject]()
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            }else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    fileprivate func random() -> Double {
        return drand48()
    }
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatDisplay(operand)
        internalProgram.append(operand as AnyObject)
        
    }
    
    var variableValues = [String:Double]()
    
    func setOperand(_ variableName: String) {
        if let doubleValue = variableValues[variableName] {
            accumulator = doubleValue
        } else {
            variableValues[variableName] = 0.0
            accumulator = 0.0
        }
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    fileprivate var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "±" : Operation.unaryOperation({ -$0 }, {"-(" + $0 + ")"}),
        "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")" } ),
        "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "log₂" : Operation.unaryOperation(log, { "log₂(" + $0 + ")" }),
        "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²"}),
        "×" : Operation.binaryOperation({ $0 * $1}, { $0 + " × " + $1 } ),
        "÷" : Operation.binaryOperation({ $0 / $1}, { $0 + " ÷ " + $1 } ),
        "+" : Operation.binaryOperation({ $0 + $1}, { $0 + " + " + $1 } ),
        "−" : Operation.binaryOperation({ $0 - $1}, { $0 + " − " + $1 } ),
        "=" : Operation.equals,
        "Rand": Operation.random
    ]
    
    fileprivate enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String)-> String)
        case equals
        case random
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .equals:
                executePendingBinaryOperation()
            case .random:
                setOperand(random())
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
        
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    typealias PropertyList = AnyObject
    
    //update to handle variables for assigment #2
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let value = op as? String {
                        //check for variable value
                        if variableValues[value] != nil {
                            setOperand(value)
                        } else {
                            performOperation(value)
                        }
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        internalProgram.removeAll()        
    }
    
    //read-only computed property
    var result: Double {
        return accumulator
    }
    
    func formatDisplay(_ number: Double) -> String{
        let formatter = NumberFormatter()
        formatter.roundingMode = NumberFormatter.RoundingMode.down
        formatter.maximumFractionDigits = 6
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
