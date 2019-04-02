//
//  UICardView.swift
//  GameSet
//
//  Created by Ashish Bansal on 26/09/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class UICardView: UIView {
    private struct SquigglySizeRatios
    {
        static let figureBoxHeightToWidth: CGFloat = 0.75
        static let figureWidthToBoxWidth: CGFloat = 0.65
        static let marginFactor: CGFloat = 0.87
        static let scaledfigureBoxHeightToWidth: CGFloat = figureBoxHeightToWidth * figureWidthToBoxWidth * marginFactor
        
        static let curveJoinPointXtoFigureWidth: CGFloat = 7.04/8
        static let curveJoinPointYtoFigureWidth: CGFloat = 2.81/8
        static let curve1ControlPt1XtoFigureWidth: CGFloat = 0.45/8
        static let curve1ControlPt1YtoFigureWidth: CGFloat = 3.53/8
        static let curve1ControlPt2XtoFigureWidth: CGFloat = 0.5
        static let curve1ControlPt2YtoFigureWidth: CGFloat = 0
        static let curve2ControlPt1XtoFigureWidth: CGFloat = 1
        static let curve2ControlPt1YtoFigureWidth: CGFloat = 3.76/8
        static let curve2ControlPt2XtoFigureWidth: CGFloat = 8.15/8
        static let curve2ControlPt2YtoFigureWidth: CGFloat = 1/8
    }
    
    private struct DiamondSizeRatios
    {
        static let figureBoxHeightToWidth: CGFloat = 0.55
        static let figureWidthToBoxWidth: CGFloat = 0.7
        static let marginFactor: CGFloat = 1.1
        static let scaledfigureBoxHeightToWidth: CGFloat = figureBoxHeightToWidth * figureWidthToBoxWidth * marginFactor
    }
    
    private struct OvalSizeRatios
    {
        static let figureBoxHeightToWidth: CGFloat = 0.5
        static let figureWidthToBoxWidth: CGFloat = 0.7
        static let marginFactor: CGFloat = 1.2
        static let scaledfigureBoxHeightToWidth: CGFloat = figureBoxHeightToWidth * figureWidthToBoxWidth * marginFactor
    }
    
    private let stripeCount = 12/SquigglySizeRatios.figureWidthToBoxWidth
    private lazy var shapeOutlineLineWidth = bounds.width/50
    private lazy var shapeFillLineWidth = shapeOutlineLineWidth/2
    
    private func splitRectVertically(rect rectToSplit: CGRect, heightToWidthRatioOfSplit: CGFloat, splitCount: Int) -> [CGRect]
    {
        precondition(splitCount >= 1)
        
        let sizeRatioOfSplitsCombined = heightToWidthRatioOfSplit * CGFloat(splitCount)
        let heightToWidthOfRectToSplit = rectToSplit.height/rectToSplit.width
        let widthOfSplit = rectToSplit.height / max(sizeRatioOfSplitsCombined, heightToWidthOfRectToSplit) //Same as splits combined as we are splitting vertically
        let heightOfEachSplit = heightToWidthRatioOfSplit * widthOfSplit
        
        let surplusHeightInRectToSplits = rectToSplit.height - heightOfEachSplit*CGFloat(splitCount)
        let surplusWidthInRectToSplits = rectToSplit.width - widthOfSplit //No need to factor in split count as we are splitting vertically
        let originOfSplits = CGPoint(x: rectToSplit.origin.x + surplusWidthInRectToSplits/2, y: rectToSplit.origin.y + surplusHeightInRectToSplits/2)
        let sizeOfEachSplit = CGSize(width: widthOfSplit, height: heightOfEachSplit)
        var splits = [CGRect]()
        
        for splitNumber in 0..<splitCount
        {
            let originOfSplit = CGPoint(x: originOfSplits.x, y: originOfSplits.y + sizeOfEachSplit.height*CGFloat(splitNumber))
            splits.append(CGRect(origin: originOfSplit, size: sizeOfEachSplit))
        }
        
        return splits
    }
    
    private func createSquigglyPath(inRect rect: CGRect) -> UIBezierPath
    {
        let squigglyWidth = SquigglySizeRatios.figureWidthToBoxWidth * rect.width
        let curveStartPoint = CGPoint(x: rect.midX - squigglyWidth/2, y: rect.midY)
        let curveJoinPoint = CGPoint(x: curveStartPoint.x + SquigglySizeRatios.curveJoinPointXtoFigureWidth * squigglyWidth, y: curveStartPoint.y - SquigglySizeRatios.curveJoinPointYtoFigureWidth * squigglyWidth)
        let curve1ControlPoint1 = CGPoint(x: curveStartPoint.x + SquigglySizeRatios.curve1ControlPt1XtoFigureWidth * squigglyWidth, y: curveStartPoint.y - SquigglySizeRatios.curve1ControlPt1YtoFigureWidth * squigglyWidth)
        let curve1ControlPoint2 = CGPoint(x: curveStartPoint.x + SquigglySizeRatios.curve1ControlPt2XtoFigureWidth * squigglyWidth, y: curveStartPoint.y - SquigglySizeRatios.curve1ControlPt2YtoFigureWidth * squigglyWidth)
        
        let squigglyPath = UIBezierPath()
        squigglyPath.move(to: curveStartPoint)
        squigglyPath.addCurve(to: curveJoinPoint, controlPoint1: curve1ControlPoint1, controlPoint2: curve1ControlPoint2)
        
        let curve2ControlPoint1 = CGPoint(x: curveStartPoint.x + SquigglySizeRatios.curve2ControlPt1XtoFigureWidth * squigglyWidth, y: curveStartPoint.y - SquigglySizeRatios.curve2ControlPt1YtoFigureWidth * squigglyWidth)
        let curve2ControlPoint2 = CGPoint(x: curveStartPoint.x + SquigglySizeRatios.curve2ControlPt2XtoFigureWidth * squigglyWidth, y: curveStartPoint.y - SquigglySizeRatios.curve2ControlPt2YtoFigureWidth * squigglyWidth)
        
        squigglyPath.addCurve(to: curveStartPoint.diametricallyOppositePoint(center: rect.center), controlPoint1: curve2ControlPoint1, controlPoint2: curve2ControlPoint2)
        
        squigglyPath.addCurve(to: curveJoinPoint.diametricallyOppositePoint(center: rect.center), controlPoint1: curve1ControlPoint1.diametricallyOppositePoint(center: rect.center), controlPoint2: curve1ControlPoint2.diametricallyOppositePoint(center: rect.center))
        
        squigglyPath.addCurve(to: curveStartPoint, controlPoint1: curve2ControlPoint1.diametricallyOppositePoint(center: rect.center), controlPoint2: curve2ControlPoint2.diametricallyOppositePoint(center: rect.center))
        
        return squigglyPath
    }
    
    private func createDiamondPath(inRect rect: CGRect) -> UIBezierPath
    {
        let diamondWidth = DiamondSizeRatios.figureWidthToBoxWidth * rect.width
        let diamondHeight = DiamondSizeRatios.figureBoxHeightToWidth * diamondWidth
        let westPoint = CGPoint(x: rect.midX - diamondWidth/2, y: rect.midY)
        let northPoint = CGPoint(x: westPoint.x + diamondWidth/2, y: westPoint.y - diamondHeight/2)
        
        let diamondPath = UIBezierPath()
        diamondPath.move(to: westPoint)
        diamondPath.addLine(to: northPoint)
        diamondPath.addLine(to: westPoint.diametricallyOppositePoint(center: rect.center))
        diamondPath.addLine(to: northPoint.diametricallyOppositePoint(center: rect.center))
        diamondPath.close()
        
        return diamondPath
    }
    
    private func createOvalPath(inRect rect: CGRect) -> UIBezierPath
    {
        let ovalWidth = OvalSizeRatios.figureWidthToBoxWidth * rect.width
        let ovalHeight = OvalSizeRatios.figureBoxHeightToWidth * ovalWidth
        let gapBetweenHalfCircles = ovalWidth - ovalHeight
        let leftHalfCircleCenterPoint = CGPoint(x: rect.midX - gapBetweenHalfCircles/2, y: rect.midY)
        let rightHalfCircleCenterPoint = CGPoint(x: rect.midX + gapBetweenHalfCircles/2, y: rect.midY)
        
        let ovalPath = UIBezierPath(arcCenter: leftHalfCircleCenterPoint, radius: ovalHeight/2, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2, clockwise: true)
        ovalPath.addLine(to: ovalPath.currentPoint.oppositePointOnXaxis(midX: rect.midX))
        ovalPath.addArc(withCenter: rightHalfCircleCenterPoint, radius: ovalHeight/2, startAngle: CGFloat.pi*3/2, endAngle: CGFloat.pi/2, clockwise: true)
        ovalPath.close()
        return ovalPath
    }
    
    private func createStripes(shapeBox box: CGRect, shapePath: UIBezierPath, stripeColor: UIColor)
    {
        let currentContext = UIGraphicsGetCurrentContext()!
        currentContext.saveGState()
        shapePath.addClip()
        
        let gapBetweenStripes = box.width/(stripeCount + 1)
        let stripePath = UIBezierPath()
        for stripeNumber in 1...Int(stripeCount)
        {
            let stripeStartPoint = CGPoint(x: box.origin.x + CGFloat(stripeNumber) * gapBetweenStripes, y: box.origin.y - box.height) //Using box height to draw much outside the box as squiggly curves extend outside it's box
            stripePath.move(to: stripeStartPoint)
            stripePath.addLine(to: stripeStartPoint.oppositePointOnYaxis(midY: box.midY))
        }
        
        stripePath.lineWidth = shapeFillLineWidth
        stripeColor.setStroke()
        stripePath.stroke()
        currentContext.restoreGState()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //let cardRect = bounds
        let paddedRect = bounds.insetBy(dx: bounds.width*0.02, dy: bounds.height*0.02)
        let cardBackground = UIBezierPath(roundedRect: paddedRect, cornerRadius: paddedRect.height*0.1)
        let cardBackgroundColor = isFaceDown ? UIColor.orange : UIColor.white
        cardBackgroundColor.setFill()
        cardBackground.fill()
        
        if isFaceDown {
            return
        }
        
        if (highlightCard) {
            highlightColor.setStroke()
            cardBackground.lineWidth = paddedRect.width/10
            cardBackground.addClip()
            cardBackground.stroke()
        }
        
        var heightToWidthRatioOfSymbol: CGFloat
        var shapePathFunction: (CGRect) -> UIBezierPath
        
        switch setCard.symbol
        {
        case .diamond:
            heightToWidthRatioOfSymbol = DiamondSizeRatios.scaledfigureBoxHeightToWidth
            shapePathFunction = createDiamondPath
        case .oval:
            heightToWidthRatioOfSymbol = OvalSizeRatios.scaledfigureBoxHeightToWidth
            shapePathFunction = createOvalPath
        case .squiggly:
            heightToWidthRatioOfSymbol = SquigglySizeRatios.scaledfigureBoxHeightToWidth
            shapePathFunction = createSquigglyPath
        }
        
        for subRect in splitRectVertically(rect: bounds, heightToWidthRatioOfSplit: heightToWidthRatioOfSymbol, splitCount: setCard.number.rawValue)
        {
            let shapePath = shapePathFunction(subRect)
            
            var symbolColor: UIColor
            switch setCard.color
            {
            case .green:
                symbolColor = UIColor.green
            case .purple:
                symbolColor = UIColor.purple
            case .red:
                symbolColor = UIColor.red
            }
            
            switch setCard.shading
            {
            case .solid:
                symbolColor.setFill()
                shapePath.fill()
            case .stripped:
                createStripes(shapeBox: subRect, shapePath: shapePath, stripeColor: symbolColor)
                fallthrough
            case .open:
                symbolColor.setStroke()
                shapePath.lineWidth = shapeOutlineLineWidth
                shapePath.stroke()
            }
        }
    }
    
    let setCard: SetCard
    var highlightCard = false
    var highlightColor = UIColor()
    private let tapGestureReciverDelegate: TapGestureRecognizer?
    var isFaceDown = true
    
    private func setUpTapGestureRecognizer()
    {
        let uiTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccurred(sender:)))
        uiTapRecognizer.numberOfTapsRequired = 1
        uiTapRecognizer.numberOfTouchesRequired = 1
        
        addGestureRecognizer(uiTapRecognizer)
    }
    
    @objc private func tapOccurred(sender: UIGestureRecognizer)
    {
        tapGestureReciverDelegate?.tapOccurred(card: setCard)
    }
    
    init(frame: CGRect, card: SetCard, gestureRecognizer: TapGestureRecognizer?) {
        setCard = card
        tapGestureReciverDelegate = gestureRecognizer
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setUpTapGestureRecognizer()
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        setCard = SetCard(number: .one, symbol: .squiggly, shading: .stripped, color: .purple)
        tapGestureReciverDelegate = nil
        super.init(coder: aDecoder)
    }
    
    static func == (lhs: UICardView, rhs: UICardView) -> Bool {
        return lhs.setCard == rhs.setCard
    }
}

extension CGPoint
{
    func diametricallyOppositePoint(center: CGPoint) -> CGPoint
    {
        return CGPoint(x: 2*center.x - self.x, y: 2*center.y - self.y)
    }
    
    func oppositePointOnXaxis(midX: CGFloat) -> CGPoint
    {
        return CGPoint(x: 2*midX - self.x, y: self.y)
    }
    
    func oppositePointOnYaxis(midY: CGFloat) -> CGPoint
    {
        return CGPoint(x: self.x, y: 2*midY - self.y)
    }
}

extension CGRect
{
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

protocol TapGestureRecognizer
{
    func tapOccurred(card: SetCard)
}
