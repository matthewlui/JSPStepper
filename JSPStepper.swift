//
//  JSPStepper.swift
//  JSPProject
//
//  Created by Matthew Lui on 12/12/2015.
//  Copyright © 2015 goldunderknees. All rights reserved.
//

import UIKit

extension Double {
    var hasDecimal : Bool {
        get {
            if self % 1 == 0 {
                return false
            }
            return true
        }
    }
}

@IBDesignable
public class CornerRadiusAdjust:UIView{
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
            if cornerRadius > 0 {
                clipsToBounds = true
            }
        }
    }
}

@objc protocol JSPStepperDelegate{
    func valueChanged(value:Double)
}

@IBDesignable
public class JSPStepper : CornerRadiusAdjust {

    private var forwardButton  : UIButton?
    private var backwardButton : UIButton?
    private var counterLabel   : UILabel?

    @IBOutlet var delegate     : JSPStepperDelegate?

    @IBInspectable public  var borderWidth:CGFloat = 0.1

    @IBInspectable public  var font : UIFont = UIFont.systemFontOfSize(24) {
        didSet{
            counterLabel?.font = font
            forwardButton?.setAttributedTitle(NSAttributedString(string: forwardTitle, attributes: [NSFontAttributeName:font]), forState: .Normal)
            backwardButton?.setAttributedTitle(NSAttributedString(string: backwardTitle, attributes: [NSFontAttributeName:font]), forState: .Normal)
        }
    }

    @IBInspectable public  var buttonBackgroundColor  : UIColor?{
        didSet{
            forwardButton?.backgroundColor = buttonBackgroundColor
            backwardButton?.backgroundColor = buttonBackgroundColor
        }
    }

    @IBInspectable public  var buttonTitleColor       : UIColor?{
        didSet{
            forwardButton?.setTitleColor(buttonTitleColor, forState: .Normal)
            backwardButton?.setTitleColor(buttonTitleColor, forState: .Normal)
        }
    }

    @IBInspectable
    public  var counterBackgroundColor : UIColor?{
        didSet{
            counterLabel?.backgroundColor = counterBackgroundColor
        }
    }

    @IBInspectable public  var counterTitleColor      : UIColor?{
        didSet{
            counterLabel?.textColor = counterTitleColor
        }
    }

    @IBInspectable public  var prefix : String = ""
    @IBInspectable public  var suffix : String = ""
    @IBInspectable public  var forwardTitle : String = "+"
    @IBInspectable public  var backwardTitle : String = "-"
    @IBInspectable public  var maxValue : Double = Double.infinity
    @IBInspectable public  var minValue : Double = -Double.infinity
    @IBInspectable public  var current  : Double = 0
    @IBInspectable public  var step     : Double = 1

    public override init(frame: CGRect) {
        super.init(frame: frame)
        generalSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generalSetup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configApperance()
    }

    private func generalSetup(){
        // initialize and config components
        let widthOfComponent  = bounds.width / 3.5
        let heightOfComponent = bounds.height
        let maxFontSize       = min(widthOfComponent, heightOfComponent)

        let counterLabel   = UILabel(frame: CGRect(x: widthOfComponent, y: 0, width: bounds.width - (widthOfComponent*2), height: heightOfComponent))
        counterLabel.adjustsFontSizeToFitWidth = true
        counterLabel.textAlignment = .Center
        counterLabel.font  = font.fontWithSize(maxFontSize)
        addSubview(counterLabel)
        self.counterLabel  = counterLabel

        let forwardButton = UIButton(frame: CGRect(x: bounds.width - widthOfComponent, y: 0, width: widthOfComponent, height: heightOfComponent))
        forwardButton.addTarget(self, action: "forward", forControlEvents: .TouchUpInside)
        addSubview(forwardButton)
        self.forwardButton = forwardButton

        let backwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: widthOfComponent, height: heightOfComponent))
        backwardButton.addTarget(self, action: "backward", forControlEvents: .TouchUpInside)

        backwardButton.setTitle(backwardTitle, forState: .Normal)
        addSubview(backwardButton)
        self.backwardButton = backwardButton

        configApperance()

    }


    private func configApperance(){

        let widthOfComponent  = bounds.width / 3.5
        let heightOfComponent = bounds.height
        let maxFontSize       = min(widthOfComponent, heightOfComponent)
        font = UIFont.systemFontOfSize(maxFontSize/2)
        counterLabel?.frame   = CGRect(x: widthOfComponent, y: 0, width: bounds.width - (widthOfComponent*2), height: heightOfComponent)
        forwardButton?.frame  = CGRect(x: bounds.width - widthOfComponent, y: 0, width: widthOfComponent, height: heightOfComponent)
        backwardButton?.frame = CGRect(x: 0, y: 0, width: widthOfComponent, height: heightOfComponent)

        forwardButton?.backgroundColor = buttonBackgroundColor
        backwardButton?.backgroundColor = buttonBackgroundColor
        counterLabel?.backgroundColor = counterBackgroundColor

        forwardButton?.setAttributedTitle(NSAttributedString(string: forwardTitle, attributes: [NSFontAttributeName:font]), forState: .Normal)
        backwardButton?.setAttributedTitle(NSAttributedString(string: backwardTitle, attributes: [NSFontAttributeName:font]), forState: .Normal)

        if let titleColor = counterTitleColor{
            counterLabel?.textColor = titleColor
        }else{
            counterLabel?.textColor = tintColor
        }
        if let titleColor = buttonTitleColor{
            forwardButton?.setTitleColor(titleColor, forState: .Normal)
        }else{
            forwardButton?.setTitleColor(tintColor, forState: .Normal)
        }

        if let titleColor = buttonTitleColor{
            backwardButton?.setTitleColor(titleColor, forState: .Normal)
        }else{
            backwardButton?.setTitleColor(tintColor, forState: .Normal)
        }

        layer.borderWidth = borderWidth
        configCounter()

    }

    @objc private func forward(){
        if current + step > maxValue {
            return
        }
        current += step
        configCounter()
    }

    @objc private func backward(){
        if current - step < minValue {
            return
        }
        current -= step
        configCounter()
    }

    private func configCounter(){
        let generalSize = font.pointSize
        let attrPrefix = NSAttributedString(string: prefix, attributes: [NSFontAttributeName:font.fontWithSize(generalSize/2)])
        let attrSuffix = NSAttributedString(string: suffix, attributes: [NSFontAttributeName:font.fontWithSize(generalSize/2)])
        let attrString = NSMutableAttributedString(attributedString: attrPrefix)
        if current.hasDecimal {
            let currentValue = NSAttributedString(string: "\(current)", attributes: [NSFontAttributeName:font])
            attrString.appendAttributedString(currentValue)
            attrString.appendAttributedString(attrSuffix)
            counterLabel?.attributedText = attrString
        }else{
            let currentValue = NSAttributedString(string: "\(Int(current))", attributes: [NSFontAttributeName:font])
            attrString.appendAttributedString(currentValue)
            attrString.appendAttributedString(attrSuffix)
            counterLabel?.attributedText = attrString
        }
        delegate?.valueChanged(current)
        counterLabel?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
    }
}
