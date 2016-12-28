//
//  ViewController.swift
//  GraphCalculator
//
//  Created by Xuezhu on 12/25/16.
//  Copyright © 2016 Xuezhu. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    
    private var userInTheMiddleOfTyping = false
    private var isFloatingPoint = false
    private var key = "M"
    private var containsVariable = false
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping {
            if digit != "." || !isFloatingPoint {
                let textCurrentlyInDisplay = display.text
                display.text = textCurrentlyInDisplay! + digit
                if digit == "." { isFloatingPoint = true}
            }
        } else {
            if !brain.isPartialResult {
                brain.description = ""
                containsVariable = false
            }
            if digit != "0" {
                userInTheMiddleOfTyping = true
            }
            if digit == "." {
                display.text = "0" + digit
                isFloatingPoint = true
            } else {
                display.text = digit
            }
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(format: "%g", newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func setVariable(_ sender: UIButton) {
        let value = Double(display.text!)
        brain.variableValues[key] = value
        let variableProgram = brain.program
        brain.program = variableProgram
        displayValue = brain.result
    }
    
    @IBAction func setOperandVariable(_ sender: UIButton) {
        if let value = brain.variableValues[key] {
            displayValue = value
        }
        brain.setOperand(variableName: sender.currentTitle!)
        containsVariable = true
        userInTheMiddleOfTyping = true
    }
    
    private var intercept : Double {
        let value = brain.variableValues[key]
        brain.variableValues[key] = 0.0
        var variableProgram = brain.program
        brain.program = variableProgram
        let intercept = brain.result
        brain.variableValues[key] = value
        variableProgram = brain.program
        brain.program = variableProgram
        return intercept
    }
    @IBAction func undo(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            var displayText = display.text!
            displayText.remove(at: displayText.index(before: displayText.endIndex))
            display.text = displayText
        } else {
            brain.undoOp()
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            if !containsVariable {
                brain.setOperand(operand: displayValue)
            }
            userInTheMiddleOfTyping = false
            isFloatingPoint = false
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathmaticalSymbol)
        }
        displayValue = brain.result
        updateDescription()
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save(_ sender: UIButton) {
        savedProgram = brain.program
    }
    
    @IBAction func ans(_ sender: UIButton) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private func updateDescription() {
        if brain.isPartialResult || brain.description == ""  {
            descriptionDisplay.text = brain.description + "..."
        } else {
            descriptionDisplay.text = brain.description + "="
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            // look inside when destinationvc is UINavigationController
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let graphvc = destinationvc as? GraphViewController {
            graphvc.savedProgram = savedProgram
            graphvc.navigationItem.title = brain.description
            graphvc.firstPoint = CGPoint(x: brain.variableValues[key]!, y: brain.result)
            graphvc.secondPoint = CGPoint(x: 0, y: intercept)
        }
        
    }
    
}

