//
//  GraphViewController.swift
//  Calculator
//
//  Created by Milos Menicanin on 11/11/16.
//  Copyright © 2016 Milos Menicanin. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphViewDataSource {
        
    var graphTitle: String? {
        didSet {
            self.title = graphTitle
        }
    }
        
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.changeScale(_:))))
        }
    }
    
    func calcYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)?

}
