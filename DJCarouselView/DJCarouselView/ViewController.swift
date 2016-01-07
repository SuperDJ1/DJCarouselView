//
//  ViewController.swift
//  DJCarouselView
//
//  Created by SuperDJ on 15/12/31.
//  Copyright © 2015年 SuperDJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DJCarouselViewDelegate, DJCarouselViewDataSource {
    
    let picArr = ["pic1", "pic2", "pic3"]
    
    var carouselView: DJCarouselView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        carouselView = DJCarouselView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width * 0.7))
        carouselView.dataSource = self
        carouselView.delegate = self
        carouselView.alignMode = .Right
        carouselView.titleBackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        carouselView.pageTintColor = UIColor.whiteColor()
        self.view.addSubview(carouselView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfPicInCarouselView(carouselView: DJCarouselView) -> Int {
        return picArr.count
    }
    func carouselView(carouselView: DJCarouselView, imageAtIndex index: Int) -> UIImage {
        return UIImage(named: picArr[index])!
    }
    func carouselView(carouselView: DJCarouselView, didSelectAtIndex index: Int) {
        print(index)
    }
    func durationPerImage(carouselView: DJCarouselView) -> NSTimeInterval {
        return 5
    }
    func carouselView(carouselView: DJCarouselView, titleAtIndex index: Int) -> String {
        return "This is \(picArr[index])! Do u like this photo?"
    }
}

