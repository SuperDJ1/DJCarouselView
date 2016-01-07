//
//  DJCarouselView.swift
//  DJCarouselView
//
//  Created by SuperDJ on 16/1/1.
//  Copyright © 2016年 SuperDJ. All rights reserved.
//

import UIKit

@objc protocol DJCarouselViewDataSource: NSObjectProtocol {
    func numberOfPicInCarouselView(carouselView: DJCarouselView) -> Int
    func carouselView(carouselView: DJCarouselView, imageAtIndex index: Int) -> UIImage
    optional func carouselView(carouselView: DJCarouselView, titleAtIndex index: Int) -> String
}

@objc protocol DJCarouselViewDelegate: NSObjectProtocol {
    func carouselView(carouselView: DJCarouselView, didSelectAtIndex index: Int)
    func durationPerImage(carouselView: DJCarouselView) -> NSTimeInterval
}

enum DJCarouselAlignMode {
    case Left
    case Center
    case Right
}

@objc class DJCarouselView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    private let scrollView        = UIScrollView()
    private let pageControl       = UIPageControl()
    private var imgCount          = 0
    private var titleLabel        = UILabel()
    private var carouselTimer     : NSTimer?
    private let controlView       = UIView()
    
    internal var titleBackColor   : UIColor? {
        didSet {
            self.controlView.backgroundColor = titleBackColor
        }
    }
    internal var pageTintColor    : UIColor? {
        didSet {
            self.pageControl.currentPageIndicatorTintColor = pageTintColor!
        }
    }
    internal var alignMode = DJCarouselAlignMode.Right {
        didSet {
            self.alignControlView()
        }
    }
    
    internal var delegate         : DJCarouselViewDelegate?   {
        didSet {
            if self.dataSource != nil {
                self.reload()
            }
        }
    }
    internal var dataSource       : DJCarouselViewDataSource? {
        didSet {
            if self.delegate != nil {
                self.reload()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scrollView.frame                          = CGRectMake(0, 0, frame.width, frame.height)
        self.scrollView.delegate                       = self
        self.scrollView.bounces                        = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator   = false
        self.scrollView.pagingEnabled                  = true
        self.addSubview(self.scrollView)
        
        self.controlView.frame = CGRectMake(0, 0, frame.width, 30)
        
        self.pageControl.frame                         = CGRectMake(0, 0, frame.width, 30)
        self.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        
        self.titleLabel.textColor = UIColor.whiteColor()
        
        self.controlView.addSubview(self.titleLabel)
        self.controlView.addSubview(self.pageControl)
        
        self.addSubview(self.controlView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "imgClicked")
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reload() {
        let width  = self.frame.width
        let height = self.frame.height
        
        self.imgCount                  = self.dataSource!.numberOfPicInCarouselView(self)
        self.pageControl.numberOfPages = self.imgCount
        self.pageControl.currentPage   = 0
        
        self.alignControlView()
        
        for imageView in self.scrollView.subviews {
            imageView.removeFromSuperview()
        }
        
        self.scrollView.contentSize = CGSizeMake(width * CGFloat(self.imgCount + 2), height)
        for var index = 0; index < self.imgCount; index++ {
            let img = self.dataSource!.carouselView(self, imageAtIndex: index)
            let imgView = UIImageView(frame: CGRectMake(width * CGFloat(index + 1), 0, width, height))
            imgView.image = img
            self.scrollView.addSubview(imgView)
        }
        
        if self.imgCount != 0 {
            let firstImg       = self.dataSource!.carouselView(self, imageAtIndex: (self.imgCount - 1))
            let firstImgView   = UIImageView(frame: CGRectMake(0, 0, width, height))
            firstImgView.image = firstImg
            
            let lastImg        = self.dataSource!.carouselView(self, imageAtIndex: 0)
            let lastImgView    = UIImageView(frame: CGRectMake(width * CGFloat(self.imgCount + 1), 0, width, height))
            lastImgView.image  = lastImg
            
            self.scrollView.addSubview(firstImgView)
            self.scrollView.addSubview(lastImgView)
            
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: 0) {
                self.titleLabel.text = title
            }
        }
        self.scrollView.setContentOffset(CGPointMake(width, 0), animated: false)
        
        if self.imgCount == 1 {
            self.scrollView.scrollEnabled = false
        } else {
            self.scrollView.scrollEnabled = true
        }
        
        self.carouselTimer?.invalidate()
        if self.imgCount > 1 && self.delegate != nil {
            self.carouselTimer = NSTimer.scheduledTimerWithTimeInterval(self.delegate!.durationPerImage(self),
                                 target: self,
                                 selector: "autoScroll",
                                 userInfo: nil,
                                 repeats: true)
        }
    }
    
    func alignControlView() {
        let width = self.frame.width
        let height = self.frame.height
        
        let pointSize = self.pageControl.sizeForNumberOfPages(self.imgCount + 1)
        
        switch self.alignMode {
        case .Left:
            self.pageControl.frame = CGRectMake(0, 0, pointSize.width, 30)
            self.controlView.frame = CGRectMake(0, height - 30, width, 30)
            self.titleLabel.frame = CGRectMake(pointSize.width + 10, 0, width - pointSize.width - 10, 30)
            break
        case .Right:
            self.pageControl.frame = CGRectMake(width - pointSize.width, 0, pointSize.width, 30)
            self.controlView.frame = CGRectMake(0, height - 30, width, 30)
            self.titleLabel.frame = CGRectMake(10, 0, width - pointSize.width - 10, 30)
            break
        case .Center:
//            self.pageControl.frame = CGRectMake(width / 2 - pointSize.width / 2, height - pointSize.height, pointSize.width, pointSize.height)
            self.pageControl.frame = CGRectMake(0, 28, width, 15)
            self.controlView.frame = CGRectMake(0, height - 30 - 15, width, 15 + 30)
            self.titleLabel.frame = CGRectMake(10, 0, width - 10, 30)
            break
        }
    }
    
    func autoScroll() {
        let width = self.frame.width
        
        let distance = self.scrollView.contentOffset.x
        let index = Int(distance / width)
        
        if index == 0 {
            self.pageControl.currentPage = self.imgCount - 1
            self.scrollView.setContentOffset(CGPointMake(width, 0), animated: true)
            self.pageControl.currentPage = 0
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: 0) {
                self.titleLabel.text = title
            }
        }
        if index > 0 && index <= self.imgCount - 1 {
            self.pageControl.currentPage = index - 1
            self.scrollView.setContentOffset(CGPointMake(width * CGFloat(index + 1), 0), animated: true)
            self.pageControl.currentPage = index
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: index) {
                self.titleLabel.text = title
            }
            if index == self.imgCount - 1 {
                NSTimer.scheduledTimerWithTimeInterval(0.2,
                    target: self,
                    selector: "backToFirstImg",
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    
    func backToFirstImg() {
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func imgClicked() {
        let width = self.frame.width
        
        let distance = self.scrollView.contentOffset.x
        var index = Int(distance / width)
        
        if index == 0 {
            index = self.imgCount - 1
        } else if index > 0 && index <= self.imgCount {
            index--
        } else {
            index = 0
        }
        if self.delegate != nil {
            self.delegate!.carouselView(self, didSelectAtIndex: index)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = self.frame.width
        
        let distance = self.scrollView.contentOffset.x
        let index = Int(distance / width)
        if index == 0 {
            self.pageControl.currentPage = self.imgCount - 1
            self.scrollView.setContentOffset(CGPointMake(width * CGFloat(imgCount), 0), animated: false)
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: self.imgCount - 1) {
                self.titleLabel.text = title
            }
        } else if index > 0 && index <= self.imgCount {
            self.pageControl.currentPage = index - 1
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: index - 1) {
                self.titleLabel.text = title
            }
        } else {
            self.pageControl.currentPage = 0
            self.scrollView.setContentOffset(CGPointMake(width, 0), animated: false)
            if let title = self.dataSource!.carouselView?(self, titleAtIndex: 0) {
                self.titleLabel.text = title
            }
        }
    }

}
