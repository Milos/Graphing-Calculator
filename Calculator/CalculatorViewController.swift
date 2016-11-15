//
//  ViewController.swift
//  Calculator
//
//  Created by Milos Menicanin on 8/6/16.
//  Copyright © 2016 Milos Menicanin. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            //permiting multiple dots
            if !(digit == "." && display.text!.range(of: ".") != nil){
                let textCurrentInDisplay = display.text!
                display.text = textCurrentInDisplay + digit
            }
            
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var displayValue: Double? {
        get {
            if let value = display.text {
                return Double(value)
            }else {
                return nil
            }
        }
        set {
            if let number = newValue {
                display.text = brain.formatDisplay(number)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            }else {
                display.text = "0"
                history.text = " "
            }
        }
    }
    
    @IBAction func clearAll() {
        brain.clear()
        brain.variableValues.removeValue(forKey: "M")
        displayValue = nil
        userIsInTheMiddleOfTyping = false
    }
    
    // backspace if user is typing or undo operation if he's not in the middle of typing
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.remove(at: text.characters.index(before: text.endIndex))
                if text.isEmpty {
                    text = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = text
            }
            //Undo
        } else {
            if var arrayOfOps = brain.program as? [AnyObject] {
                if !arrayOfOps.isEmpty {
                    arrayOfOps.removeLast()
                    brain.program = arrayOfOps as CalculatorBrain.PropertyList
                    displayValue = brain.result
                }
            }
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction fileprivate func save() {
        savedProgram = brain.program
        print("savedProgram: \(savedProgram)")
    }
    
    @IBAction fileprivate func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
        print("restoredProgram: \(savedProgram)")
    }
    
    @IBAction func setM() {
        brain.variableValues["M"] = displayValue
        print("Variable Value Before Save: \(brain.variableValues["M"])")
        save()
        restore()
        print("Variable Value After Save: \(brain.variableValues["M"])")
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func touchM() {
        brain.setOperand("M")
        displayValue = brain.result
        
        userIsInTheMiddleOfTyping = false
        
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            //brain.setOperand(displayValue)
            if let value = displayValue {
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        displayValue = brain.result
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !brain.isPartialResult
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier  = segue.identifier {
            switch identifier {
            case "graph":
                
                var destinationvc = segue.destination
                if let nvc = destinationvc as? UINavigationController {
                    destinationvc = nvc.visibleViewController ?? destinationvc
                }
                
                if let vc = destinationvc as? GraphViewController {
                    vc.navigationItem.title = brain.description
                    vc.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues["M"] = Double(x)
                        // Trick with a computed property
                        self.brain.program = self.brain.program

                        return self.brain.result
                    }
                }
            default: break
                
            }            
        }
    }
    
}
