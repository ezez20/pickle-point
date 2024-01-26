//
//  CircularProgressView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 1/22/24.
//

import Foundation
import UIKit
import QuartzCore

class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "animationKey")
    var newValue: Double = 0.0 {
        didSet {
            print("new value: \(newValue)")
            oldvalue = oldValue
        }
    }
    var oldvalue: Double = 0.0 {
        didSet {
            print("oldvalue: \(oldvalue)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawProgressView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressView), name: NSNotification.Name("updateCircularProgressView"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.drawProgressView()
    }
    
    
    private var viewCGPath: CGPath? {
        frame.size.width = 40
        frame.size.height = 40
        return UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                            radius: (frame.size.width - 1.5)/2,
                            startAngle: CGFloat(-0.5 * Double.pi),
                            endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
    }
    
    private func drawProgressView() {
        self.drawsView(shapeLayer: progressLayer, startingPoint: 10.0, endingPoint: 0.0)
    }
    
    private func drawsView(shapeLayer: CAShapeLayer, startingPoint: CGFloat, endingPoint: CGFloat) {
        //        self.backgroundColor = UIColor.systemYellow
        
        shapeLayer.path = self.viewCGPath
        shapeLayer.fillColor = UIColor.systemYellow.cgColor
        shapeLayer.strokeColor = UIColor.systemCyan.cgColor
        shapeLayer.lineWidth = startingPoint
        shapeLayer.strokeEnd = endingPoint
        //        shape.backgroundColor = UIColor.systemYellow.cgColor
        self.layer.addSublayer(shapeLayer)
        shapeLayer.position = CGPoint(x: frame.midX - (frame.midX/2) , y: frame.midY - (frame.midY/2))
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        print("setProgressWithAnimation: \(value)")
        
        //        animation.duration = duration
        animation.fromValue = 0 // Start animation at point
        animation.toValue = value // End animation at point
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgressViewKey")
    }
    
    @objc func updateProgressView(_ notification: NSNotification) {
        if let data = notification.userInfo?["progressData"] as? Float {
            print("Float Data: \(data)")
            newValue = Double(data)
            
            animation.fromValue = oldvalue
            animation.toValue = newValue
            progressLayer.strokeEnd = CGFloat(newValue)
            progressLayer.add(animation, forKey: "animateProgressViewKey")
        }
    }
}
