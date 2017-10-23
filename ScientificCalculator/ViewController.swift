//
//  ViewController.swift
//  ScientificCalculator
//
//  Created by Alex Hannigan on 2017/10/20.
//  Copyright © 2017年 Alex Hannigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var calculatorDisplay: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    @IBOutlet weak var mDisplay: UILabel!
    
    private var brain = CalculatorBrain()
    
    private var userIsInTheMiddleOfTyping = false
    
    // To store the value of 'M'
    private var variables: [String: Double] = [:]
    
    var displayValue: Double {
        get {
            return Double(calculatorDisplay!.text!)!
        }
        set {
            // Remove extraneous decimal numbers
            var tempResult = String(newValue)
            if tempResult.hasSuffix(".0") {
                tempResult.removeLast(2)
            }
            calculatorDisplay.text = tempResult
        }
    }
    
    @IBAction func digitPress(_ sender: UIButton) {
        if let digit = sender.currentTitle {
            switch digit {
                // Handle decimal input
            case ".":
                if userIsInTheMiddleOfTyping && !calculatorDisplay.text!.contains(digit) {
                    calculatorDisplay.text = calculatorDisplay.text! + digit
                }
                else if !userIsInTheMiddleOfTyping {
                    calculatorDisplay.text = "0" + digit
                    userIsInTheMiddleOfTyping = true
                }
            case "M":
                calculatorDisplay.text = "M"
                userIsInTheMiddleOfTyping = false
                // Prevent the input of extraneous zeros
            case "0":
                if calculatorDisplay.text == "0" {
                    break
                }
                fallthrough
                // Handle numerical input
            default:
                if userIsInTheMiddleOfTyping {
                    if calculatorDisplay.text!.count <= 11 {
                        calculatorDisplay.text = calculatorDisplay.text! + digit
                    }
                }
                else {
                    calculatorDisplay.text = digit
                    userIsInTheMiddleOfTyping = true
                }
            }
        }
    }
    
    @IBAction func randomDouble(_ sender: UIButton) {
        displayValue = Double(arc4random()) / Double(UINT32_MAX)
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if calculatorDisplay.text!.count > 1 {
                calculatorDisplay.text?.removeLast()
            }
            else if displayValue != 0 {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction func assignToM(_ sender: UIButton) {
        variables["M"] = displayValue
        mDisplay.text = calculatorDisplay!.text!
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func clearM(_ sender: UIButton) {
        variables = [:]
        mDisplay.text = "0"
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func useM(_ sender: UIButton) {
        if let variableName = sender.currentTitle {
            brain.setOperand(variable: variableName)
            displayResult()
            userIsInTheMiddleOfTyping = false
        }
    }
    
    private func displayResult() {
        if let result = brain.evaluate(using: variables) {
            if result.result != nil {
                displayValue = result.result!
            }
            else {
                displayValue = 0
            }
            var description = result.description
            if result.isPending {
                description.removeLast()
                description = description + "..."
            }
            else if description != "0" {
                description = description + " ="
            }
            descriptionDisplay.text = description
        }
        else {
            displayValue = 0
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if let calcText = calculatorDisplay.text {
            if calcText == "M" {
            brain.setOperand(variable: calcText)
        }
        else {
            brain.setOperand(to: displayValue)
        }
        brain.setOperation(to: sender.currentTitle!)
        
        displayResult()
        userIsInTheMiddleOfTyping = false
        }
    }
}

