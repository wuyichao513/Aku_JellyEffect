//
//  ViewController.swift
//  贝塞尔曲线果冻效果
//
//  Created by 阿酷 on 16/7/25.
//  Copyright © 2016年 AkuApp. All rights reserved.
//

import UIKit

// 红色 蓝色 view  的宽高
let rbViewWH: CGFloat = 25

// 黄色view宽高
let viewWH: CGFloat = 50

class ViewController: UIViewController {

    /// 红色的view
    private lazy var redView: UIView = UIView(frame: CGRect(x: 30, y: 330, width: rbViewWH, height: rbViewWH))
    
    /// 蓝色的view
    private lazy var blueView: UIView = UIView(frame: CGRect(x: 230, y: 330, width: rbViewWH, height: rbViewWH))
    
    /// 通过 黄色的view 弹性弹性移动  绘制动画效果
    private lazy var yellowJellyView: UIView = UIView(frame: CGRect(x: 200, y: 400, width: viewWH, height: viewWH))
    
    /// 画出来的 视图
    private lazy var shapeLayer = CAShapeLayer()
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //MARK: - UI布局
        setupUI()
        
        //MARK: - 初始化 定时器
        //MARK: - 在执行动画效果期间 不断的 调用 monitoryellowJellyViewLayer 方法  将 yellowJellyView.layer 的位置赋值给 moveToPoint
        disPlayLink = CADisplayLink(target: self, selector: "monitoryellowJellyViewLayer")
        
        // 添加到 当前运行循环
        disPlayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        // 初始化值先 暂停 定时器
        disPlayLink!.paused = true
    }
    
    /// 黄色的view 弹性弹性移动时  通过此 计时器 来监听其 layer的 x,y
    var disPlayLink: CADisplayLink?
    
    //MARK: - 通过该属性的 didSet 方法 来绘制 果冻图形  设定初始位置
    var moveToPoint: CGPoint = CGPoint(x: 200, y: 400) {
        
        //MARK: - didSet: OC中的 set 方法
        didSet {
            
            // 绘图操作
            redrawGraph()
        }
    }
    
    //MARK: - 通过不断的将 yellowJellyView 的 '真实' 位置 赋值给 moveToPoint 属性  完成 动画时 的果冻效果
    func monitoryellowJellyViewLayer() {
        
        // 连续 dismiss 两个控制器 要 dismiss 几个 就写几个 presentingViewController
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let contPointX = (yellowJellyView.layer.presentationLayer()?.frame.origin.x)! + viewWH / 2
        let contPointY = (yellowJellyView.layer.presentationLayer()?.frame.origin.y)! + viewWH / 2
        
        //MARK: - 给属性赋值,通过其 set 方法,绘制图形
        moveToPoint =  CGPoint(x: contPointX, y: contPointY)
    }
    
    
    
    
    
    
    
    
    //MARK: - 绘制出 果冻效果
    private func redrawGraph() {
        
        let bezierPath = UIBezierPath()
        
        // 取出 redView 的位置
        let redPointX  = redView.frame.origin.x + rbViewWH / 2
        let redPointY  = redView.frame.origin.y + rbViewWH / 2
        
        // 取出 blueView 的位置
        let cyanPointX = blueView.frame.origin.x + rbViewWH / 2
        let cyanPointY = blueView.frame.origin.y + rbViewWH / 2
        
        // 起始点为 redView
        bezierPath.moveToPoint(CGPoint(x: redPointX, y: redPointY))
        
        // 绘制弧线路径
        bezierPath.addQuadCurveToPoint(CGPoint(x: cyanPointX, y: cyanPointY), controlPoint: CGPoint(x: moveToPoint.x, y: moveToPoint.y))
        
        // 图形绘制
        bezierPath.closePath()
        
        // 将绘制好的路径 给 shapeLayer
        shapeLayer.path = bezierPath.CGPath
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //手指拖拽 view 调用的方法
    @objc private func moveRightView(sender: UIPanGestureRecognizer) {
        
        // 取出拖拽的位置
        let rightPoint: CGPoint = sender.translationInView(sender.view)
        
        // 让被拖拽的 view 随着 拖拽 移动
        sender.view!.transform = CGAffineTransformTranslate(sender.view!.transform,rightPoint.x, rightPoint.y);
        
        // 每一次拖拽之后, 拖拽的位置都从0开始计算
        sender.setTranslation(CGPointZero, inView: sender.view)
        
        if sender.view == yellowJellyView {
            
            let contPointX = (yellowJellyView.layer.presentationLayer()!.frame.origin.x)! + viewWH / 2
            let contPointY = (yellowJellyView.layer.presentationLayer()?.frame.origin.y)! + viewWH / 2
            moveToPoint =  CGPoint(x: contPointX, y: contPointY)
            
        } else {
            
            // 调用绘制
            redrawGraph()
        }
        
        //MARK: - 拖拽停止时调用
        if sender.state == .Ended {

            // 取出 redView 当前 的 'center' 因为是通过 transform 改变的位置,所以 改变的 只是 frame    redView.center 还是最初的位置
            let redPointX  = redView.frame.origin.x + rbViewWH / 2
            let redPointY  = redView.frame.origin.y + rbViewWH / 2
            
            // 同上 取到 blueView 的 'center'
            let bluePointX = blueView.frame.origin.x + rbViewWH / 2
            let bluePointY = blueView.frame.origin.y + rbViewWH / 2
            
            //MARK: - 计算 黄色view 将要移动的位置   另其始终 处于 redView 和 blueView 之间
            let moveX = (bluePointX - redPointX)/2 + redPointX - viewWH/2
            let moveY = (bluePointY - redPointY)/2 + redPointY - viewWH/2
            
            // 动画开始 开启 监听
            disPlayLink!.paused = false
            
            // 弹性动画
            UIView.animateWithDuration(6,                                // 动画执行时间
                                       delay: 0,                         // 延迟执行
                                       usingSpringWithDamping: 0.1,      // 动画速度
                                       initialSpringVelocity: 0,         // 阻尼
                                       options: [],                      // 动画效果
                                       animations: {
                            
                    // 这里不能用center
                    self.yellowJellyView.frame.origin = CGPoint(x: moveX, y: moveY)
                
                // 动画完成之后 暂停监听
                }, completion: { (_) in
                    
                    // 动画结束 暂停 监听
                    self.disPlayLink!.paused = true
            })
        }
    }
    
    /// 布局 UI
    private func setupUI() {
        
        // 设定layer的填充颜色
        shapeLayer.fillColor = UIColor.magentaColor().CGColor
        
        // 添加layer到父layer上
        view.layer.addSublayer(shapeLayer)
        
        // 设置颜色
        redView.backgroundColor = UIColor.redColor()
        blueView.backgroundColor = UIColor.cyanColor()
        yellowJellyView.backgroundColor = UIColor.yellowColor()
        
        // 添加到父view 上
        view.addSubview(redView)
        view.addSubview(blueView)
        view.addSubview(yellowJellyView)

        // 给三个view添加 拖拽 手势
        let lastPan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveRightView:")
        
        blueView.addGestureRecognizer(lastPan)
        
        let leftPan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveRightView:")
        
        redView.addGestureRecognizer(leftPan)
        
        let ddPan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveRightView:")
        
        yellowJellyView.addGestureRecognizer(ddPan)
    }
}





























