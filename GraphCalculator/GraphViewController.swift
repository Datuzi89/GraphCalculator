//
//  GraphViewController.swift
//  GraphCalculator
//
//  Created by Xuezhu on 12/27/16.
//  Copyright © 2016 Xuezhu. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!{
        didSet{
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(recognizer:))))

        }
    }
    var firstPoint = CGPoint()
    var secondPoint = CGPoint()
    var savedProgram: CalculatorBrain.PropertyList?
    var funType: String {
        if let arrayOfOps = savedProgram as? [AnyObject]{
            var count = 0
            for op in arrayOfOps {
                if let operation = op as? String {
                    if operation == "sin" || operation == "cos" {
                        return "trigonometric"
                    } else if operation == "M" { count = count + 1 }
                }
            }
            if count == 1 { return "linear" }
            if count == 2 { return "quadratic"}
            
        }
        return ""
    }
    
    
    
 
}
