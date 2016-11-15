//
//  GraphView.swift
//  Calculator
//
//  Created by Milos Menicanin on 11/11/16.
//  Copyright © 2016 Milos Menicanin. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func calcYCoordinate(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 16 { didSet { setNeedsDisplay() } } //50 points between 0 and 1
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet {setNeedsDisplay() } }
    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    var dataSource: GraphViewDataSource?
    
    func changeScale(_ recogniser: UIPinchGestureRecognizer) {
        switch recogniser.state {
        case .changed,.ended:
            scale *= recogniser.scale
            recogniser.scale = 1.0 //reset for increment scale
        default:
            break
        }
    }
    
    private var drawer: AxesDrawer {
        return AxesDrawer(color: color, contentScaleFactor: contentScaleFactor)
    }
    
    private func drawGraphInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        let path = UIBezierPath()
        color.set()
        var pathIsEmpty = true
        var point = CGPoint()
        
        for pixel in 0...Int(bounds.size.width * scale) {
            point.x = CGFloat(pixel)
            
            if let y = dataSource?.calcYCoordinate(x: (point.x - origin.x) / scale) {
                if !y.isNormal {
                    pathIsEmpty = true
                    continue
                }
                point.y = origin.y - y * scale
                
                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        color.set()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        origin = CGPoint(x: bounds.midX, y: bounds.midY)
        drawer.drawAxesInRect(bounds: self.bounds, origin: origin, pointsPerUnit: scale)
        drawGraphInRect(bounds: bounds, origin: origin, pointsPerUnit: scale)
        
        
    }

}
