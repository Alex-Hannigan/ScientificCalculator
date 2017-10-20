//
//  CalculatorBrain.swift
//  ScientificCalculator
//
//  Created by Alex Hannigan on 2017/10/20.
//  Copyright © 2017年 Alex Hannigan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var stack = [Element]()
    
    private enum Element {
        case operand(Double)
        case operation(String)
    }
    
    private enum Operations {
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case constant(Double, String)
        case equals
        case resetEverything
    }
    
    mutating func setOperand (to operand: Double) {
        stack.append(Element.operand(operand))
    }
    
    mutating func setOperation (to operation: String) {
        stack.append(Element.operation(operation))
    }
    
    private let operations = [
        "√": Operations.unaryOperation(sqrt, { "√(" + $0 + ")" } ),
        "+/-": Operations.unaryOperation(-, { "+/-" + $0 } ),
        "sin": Operations.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "cos": Operations.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "tan": Operations.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "x²": Operations.unaryOperation( { $0 * $0 } , { $0 + "²" }),
        "x³": Operations.unaryOperation( { $0 * $0 * $0 } , { $0 + "³" }),
        "+": Operations.binaryOperation(+, { $0 + " + " + $1 } ),
        "-": Operations.binaryOperation(-, { $0 + " - " + $1 } ),
        "×": Operations.binaryOperation(*, { $0 + " × " + $1 } ),
        "÷": Operations.binaryOperation(/, { $0 + " ÷ " + $1 } ),
        "π": Operations.constant(Double.pi, "π"),
        "=": Operations.equals,
        "C": Operations.resetEverything
    ]
    
    private struct PendingBinaryOperation {
        let firstOperand: (Double, String)
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    func evaluate () -> (result: Double?, description: String, isPending: Bool)? {
        var accumulator: (Double, String)?
        var pendingBinaryOperation: PendingBinaryOperation?
        
        func performOperation(of operation: String) {
            if let operation = operations[operation] {
                switch operation {
                case .unaryOperation(let function, let description):
                    if accumulator != nil {
                        accumulator = (function(accumulator!.0), description(accumulator!.1))
                    }
                case .binaryOperation(let function, let description):
                    if accumulator != nil {
                        if pendingBinaryOperation != nil {
                            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                        }
                        pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, function: function, description: description)
                    }
                case .constant(let value):
                    accumulator = value
                case .equals:
                    if accumulator != nil {
                        accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                        pendingBinaryOperation = nil
                    }
                case .resetEverything:
                    accumulator = nil
                    pendingBinaryOperation = nil
                }
            }
        }
        
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, "")
            }
            else {
                return accumulator?.1
            }
        }
        
        for element in stack {
            switch element {
            case .operand(let value):
                var valueString = String(value)
                if valueString.hasSuffix(".0") {
                    valueString = String(valueString.dropLast(2))
                }
                accumulator = (value, valueString)
            case .operation(let operation):
                performOperation(of: operation)
            }
        }
        
        return (result, description ?? "0", pendingBinaryOperation != nil)
    }
    
}
