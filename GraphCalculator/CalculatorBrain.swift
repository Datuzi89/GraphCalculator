//
//  CalculatorBrain.swift
//  GraphCalculator
//
//  Created by Xuezhu on 12/26/16.
//  Copyright © 2016 Xuezhu. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    var description: String = ""
    var variableValues: Dictionary<String, Double> = ["M": 0.0]
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        description += String(format:"%g",operand)
    }
    
    func setOperand(variableName: String) {
        if let operand = variableValues[variableName] {
            accumulator = operand
            internalProgram.append(variableName as AnyObject)
            description += variableName
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryIperation((Double, Double) -> Double)
        case Equals
        case Clear
        case AllClear
    }
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "±" : Operation.UnaryOperation({-$0}),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "%" : Operation.UnaryOperation({$0 / 100}),
        "×" : Operation.BinaryIperation({$0 * $1}),
        "÷" : Operation.BinaryIperation({$0 / $1}),
        "+" : Operation.BinaryIperation({$0 + $1}),
        "-" : Operation.BinaryIperation({$0 - $1}),
        "c" : Operation.Clear,
        "AC" : Operation.AllClear,
        "=" : Operation.Equals
    ]
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            var preInput: String = ""
            if internalProgram.count > 0 {
                preInput = convertObjTOStr(obj: internalProgram[internalProgram.count - 1])
            }
            switch operation {
            case .Constant(let value):
                accumulator = value
                description += symbol
            case .UnaryOperation(let function):
                if isPartialResult {
                    let rangeOfPreinput = description.range(of: preInput)
                    description.removeSubrange(rangeOfPreinput!)
                    description = description + symbol + "(" + String(format: "%g", accumulator) + ")"
                } else {
                    if symbol != "±" {
                        description = symbol + "(" + description + ")"
                    }
                    else {
                        if description[description.startIndex] != "-" {
                            description = "-(" + description + ")"
                        }
                        else {
                            description.remove(at: description.startIndex)
                        }
                    }
                }
                accumulator = function(accumulator)
            case .BinaryIperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                description += symbol
            case .Equals:
                if  preInput == "+" || preInput == "-" || preInput == "×" || preInput == "÷" {
                    description += String(format: "%g", accumulator)
                }
                executePendingBinaryOperation()
            case .Clear:
                clear()
            case .AllClear:
                allClear()
            }
        }
        internalProgram.append(symbol as AnyObject)
    }
    
    private var pending: PendingBinaryOperationInfo?
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    var program : PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operationOrOperand = op as? String {
                        if operations[operationOrOperand] != nil {
                            performOperation(symbol: operationOrOperand)
                        }
                        else {
                            setOperand(variableName: operationOrOperand)
                        }
                    }
                }
            }
        }
    }
    
    private func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        description = ""
    }
    
    private func allClear() {
        clear()
        variableValues["M"] = 0.0
    }
    
    func undoOp() {
        internalProgram.removeLast()
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    var isPartialResult: Bool {
        return pending != nil
    }
    
    var result: Double {
        return accumulator
    }
    
    // Util func convert AnyObj to String
    private func convertObjTOStr(obj: AnyObject) -> String {
        if let operand = obj as? Double {
            return String(format:"%g", operand)
        } else if let operation = obj as? String {
            return operation
        }
        return ""
    }
}
