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
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case constant(Double)
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
        "√": Operations.unaryOperation(sqrt),
        "+/-": Operations.unaryOperation(-),
        "sin": Operations.unaryOperation(sin),
        "cos": Operations.unaryOperation(cos),
        "tan": Operations.unaryOperation(tan),
        "x²": Operations.unaryOperation( { $0 * $0 } ),
        "x³": Operations.unaryOperation( { $0 * $0 * $0 } ),
        "+": Operations.binaryOperation(+),
        "-": Operations.binaryOperation(-),
        "×": Operations.binaryOperation(*),
        "÷": Operations.binaryOperation(/),
        "π": Operations.constant(Double.pi),
        "=": Operations.equals,
        "C": Operations.resetEverything
    ]
    
    private struct PendingBindingOperation {
        let firstOperand: Double
        let function: (Double, Double) -> Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    func evaluate () -> Double? {
        var accumulator: Double?
        var pendingBinaryOperation: PendingBindingOperation?
        
        func performOperation(of operation: String) {
            if let operation = operations[operation] {
                switch operation {
                case .unaryOperation(let function):
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                    }
                case .binaryOperation(let function):
                    if accumulator != nil {
                        if pendingBinaryOperation != nil {
                            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                        }
                        pendingBinaryOperation = PendingBindingOperation(firstOperand: accumulator!, function: function)
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
        
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = value
            case .operation(let operation):
                performOperation(of: operation)
            }
        }
        
        return accumulator
    }
    
}
