//
//  GraphView.swift
//  GraphCalculator
//
//  Created by Xuezhu on 12/27/16.
//  Copyright © 2016 Xuezhu. All rights reserved.
//

import UIKit
//@IBDesignable
class GraphView: UIView {

    @IBInspectable
    var scale: CGFloat = 0.90 {
        didSet {
            setNeedsDisplay() // Redraw when scale changed
        }
    }
    
    var origin : CGPoint{
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    var axesDrawer = AxesDrawer()
    var pointsPerUnit = CGFloat(50)
    var graphController = GraphViewController()
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0 // Reset to 1 to keep the scale changed at the constant rate
        default: break
        }
    }
    
    func linearPath(firstPoint: CGPoint, secondPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        let xFirst = (firstPoint.x * pointsPerUnit + origin.x)
        let yFirst = (-firstPoint.y * pointsPerUnit + origin.y)
        let xSecond = (secondPoint.x * pointsPerUnit + origin.x)
        let ySecond = (-secondPoint.y * pointsPerUnit + origin.y)
        let first = CGPoint(x: xFirst, y: yFirst)
        let second = CGPoint(x: xSecond, y: ySecond)
        path.move(to: first)
        path.addLine(to: second)
        return path
    }
    
    func trigonoalPath(startPoint: CGPoint, period: CGFloat, amplitude: CGFloat) -> UIBezierPath {
        let width = bounds.width
        let height = bounds.height
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        
        for angle in stride(from: 5.0, through: 360.0, by: 5.0) {
            let x = origin.x + CGFloat(angle/360.0) * width * (1 / period)
            let y = origin.y - CGFloat(sin(angle/180.0 * Double.pi)) * height * (1 / amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        UIColor.black.setStroke()
        return path
    }
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxesInRect(bounds: bounds, origin: origin, pointsPerUnit: pointsPerUnit)
        var path = UIBezierPath()
        switch graphController.funType {
        case "linear":
            path = linearPath(firstPoint: graphController.firstPoint, secondPoint: graphController.secondPoint)
        case "quadratic":
            path.addQuadCurve(to: graphController.firstPoint, controlPoint: graphController.secondPoint)
        case "trigonometric":
            path = trigonoalPath(startPoint: origin, period: graphController.firstPoint.x, amplitude: graphController.firstPoint.y)
        default:
            break
        }
        path.stroke()
        
    }
}

