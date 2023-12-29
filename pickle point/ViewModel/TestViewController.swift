////
////  TestViewController.swift
////  pickle point
////
////  Created by Ezra Yeoh on 12/7/23.
////
//
//import UIKit
//
//class TestViewController: UIViewController {
//    
//    let pickleBallImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "soccerball")
//        imageView.frame.size = CGSize(width: 10, height: 10)
//        imageView.transform = CGAffineTransform(rotationAngle: .pi/2)
//        imageView.tintColor = UIColor(named: "neonGreen")
//        return imageView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(testSelector), name: NSNotification.Name("testSelector"), object: nil)
//        // Do any additional setup after loading the view.
//        
//        view.addSubview(pickleBallImageView)
//        pickleBallImageView.translatesAutoresizingMaskIntoConstraints = false
//        pickleBallImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        pickleBallImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//    
//    @objc func testSelector() {
//        pickleBallImageView.tintColor = UIColor.blue
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
