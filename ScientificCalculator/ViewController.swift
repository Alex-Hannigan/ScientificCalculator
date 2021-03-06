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
    
    private var brain = CalculatorBrain()
    
    private var userIsInTheMiddleOfTyping = false
    
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
                // Prevent the input of extraneous zeros
            case "0":
                if displayValue == 0 {
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
    
    @IBAction func performOperation(_ sender: UIButton) {
        brain.setOperand(to: displayValue)
        brain.setOperation(to: sender.currentTitle!)
       
        if let result = brain.evaluate() {
            displayValue = result
        }
        else {
            displayValue = 0
        }
        
        userIsInTheMiddleOfTyping = false
    }
}

