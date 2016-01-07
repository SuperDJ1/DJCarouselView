# DJCarouselView

## 介绍
swift2实现定时轮播循环滚动，可响应点击事件以及显示标题

### 用法
#### 初始化
let carouselView        = DJCarouselView(frame: CGRect)

#### 设定dataSource和delegate
carouselView.dataSource = self

carouselView.delegate   = self

func numberOfPicInCarouselView(carouselView: DJCarouselView) -> Int
//设定轮播图片数量

func carouselView(carouselView: DJCarouselView, imageAtIndex index: Int) -> UIImage
//设定相应的图片

optional func carouselView(carouselView: DJCarouselView, titleAtIndex index: Int) -> String
//设定图片标题

func carouselView(carouselView: DJCarouselView, didSelectAtIndex index: Int)
//设定点击事件

func durationPerImage(carouselView: DJCarouselView) -> NSTimeInterval
//设定轮播等待时间

#### 设定细节
carouselView.alignMode，设置pageControl位置，左中右

carouselView.pageTintColor，设置currentPageIndicatorTintColor

carouselView.titleBackColor，设置图片标题背景色