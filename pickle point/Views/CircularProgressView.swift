//
//  CircularProgressView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 1/22/24.
//

import Foundation
import UIKit
import QuartzCore

class CircularProgressView: UIView, ObservableObject {
    
    private var progressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "animationKey")
    @Published var customPickleBallViewCount = "L-1 (1)"
    
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
            
            DispatchQueue.main.async { [self] in
                switch newValue {
                case 0...0.09: customPickleBallViewCount = "L-1 (1)"
                case 0.09...0.18: customPickleBallViewCount = "L-1 (2)"
                case 0.18...0.27: customPickleBallViewCount = "L-1 (3)"
                case 0.27...0.36: customPickleBallViewCount = "L-1 (4)"
                case 0.36...0.45: customPickleBallViewCount = "L-1 (5)"
                case 0.45...0.54: customPickleBallViewCount = "L-1 (6)"
                case 0.54...0.63: customPickleBallViewCount = "L-1 (7)"
                case 0.63...0.72: customPickleBallViewCount = "L-1 (8)"
                case 0.72...0.81: customPickleBallViewCount = "L-1 (9)"
                case 0.81...0.90: customPickleBallViewCount = "L-1 (10)"
                case 0.90...0.99: customPickleBallViewCount = "L-1 (11)"
                default:
                    break
                }
            }
        }
    }
}
