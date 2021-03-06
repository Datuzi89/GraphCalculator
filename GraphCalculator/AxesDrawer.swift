//
//  AxesDrawer.swift
//  GraphCalculator
//
//  Created by Xuezhu on 12/27/16.
//  Copyright © 2016 Xuezhu. All rights reserved.
//

import UIKit

class AxesDrawer: UIView {

    var color = UIColor.blue
    var minimumPointsPerHashmark: CGFloat = 40
    private struct Constants {
        static let HashmarkSize: CGFloat = 6
    }
    
    
    func drawAxesInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat){
        UIGraphicsGetCurrentContext()!.saveGState()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: origin.y))
        path.addLine(to: CGPoint(x: bounds.maxX, y: origin.y))
        path.move(to: CGPoint(x: origin.x, y: bounds.minY))
        path.addLine(to: CGPoint(x: origin.x, y: bounds.maxY))
        path.stroke()
        drawHashmarksInRect(bounds: bounds, origin: origin, pointsPerUnit: abs(pointsPerUnit))
        UIGraphicsGetCurrentContext()!.restoreGState()
    }
    private func drawHashmarksInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat){
        if ((origin.x >= bounds.minX) && (origin.x <= bounds.maxX)) || ((origin.y >= bounds.minY) && (origin.y <= bounds.maxY)){
            var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark
            var startingHashmarkRadius: CGFloat = 1
            if !bounds.contains(origin) {
                let leftx = max(origin.x - bounds.maxX, 0)
                let rightx = max(bounds.minX - origin.x, 0)
                let downy = max(origin.y - bounds.minY, 0)
                let upy = max(bounds.maxY - origin.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize))
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = Int(-log10(Double(unitsPerHashmark)))
            formatter.minimumIntegerDigits = 1
            
            while !bbox.contains(bounds)
            {
                let label = formatter.string(from: NSNumber(value: Float((origin.x-bbox.minX)/pointsPerUnit)))!
                if let leftHashmarkPoint = alignedPoint(x: bbox.minX, y: origin.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(location: leftHashmarkPoint, .Top("-\(label)"))
                }
                if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origin.y, insideBounds:bounds) {
                    drawHashmarkAtLocation(location: rightHashmarkPoint, .Top(label))
                }
                if let topHashmarkPoint = alignedPoint(x: origin.x, y: bbox.minY, insideBounds:bounds) {
                    drawHashmarkAtLocation(location: topHashmarkPoint, .Left(label))
                }
                if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: bbox.maxY, insideBounds:bounds) {
                    drawHashmarkAtLocation(location: bottomHashmarkPoint, .Left("-\(label)"))
                }
                bbox = bbox.insetBy(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    private func drawHashmarkAtLocation(location: CGPoint, _ text: AnchoredText){
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch text {
        case .Left: dx = Constants.HashmarkSize / 2
        case .Right: dx = Constants.HashmarkSize / 2
        case .Top: dy = Constants.HashmarkSize / 2
        case .Bottom: dy = Constants.HashmarkSize / 2
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLine(to: CGPoint(x: location.x+dx, y: location.y+dy))
        path.stroke()
        
        text.drawAnchoredToPoint(location: location, color: color)
    }
    
    private enum AnchoredText
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let VerticalOffset: CGFloat = 3
        static let HorizontalOffset: CGFloat = 6
        
        func drawAnchoredToPoint(location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.size(attributes: attributes))
            switch self {
            case .Top: textRect.origin.y += textRect.size.height / 2 + AnchoredText.VerticalOffset
            case .Left: textRect.origin.x += textRect.size.width / 2 + AnchoredText.HorizontalOffset
            case .Bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case .Right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            }
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        
        var text: String {
            switch self {
            case .Left(let text): return text
            case .Right(let text): return text
            case .Top(let text): return text
            case .Bottom(let text): return text
            }
        }
    }
    
    
    
    private func alignedPoint(x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: x, y: y)
        if let permissibleBounds = insideBounds, !permissibleBounds.contains(point) {
            return nil
        }
        return point
    }


}

extension CGRect{
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}
