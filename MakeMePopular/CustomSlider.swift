//
//  CustomSlider.swift
//  MakeMePopular
//
//  Created by Mac on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//
import UIKit
import Foundation

public class CustomSlider: UISlider {
    
    var label: UILabel
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: ()->String = { "" }
   
    public var incrementValue: Int = 1
    
    required public init(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)!
        self.addTarget(self, action: #selector(self.onValueChanged(sender:)), for: .valueChanged)
        
    }
    func setup(){
        labelXMin = frame.origin.x + 16
        labelXMax = frame.origin.x + self.frame.width - 14
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos, y: self.frame.origin.y - 25, width: 100, height: 20)
        
        label.text = self.value.description
        self.superview!.addSubview(label)
        
       
       
        
    }
    func updateLabel(){
        label.text = labelText()
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width/2, y: self.frame.origin.y - 25, width: 100, height: 20)
       
        label.textAlignment = NSTextAlignment.center
        self.superview!.addSubview(label)
    }
    public override func layoutSubviews() {
        labelText = { self.value.description.components(separatedBy: ".")[0]}
        setup()
        updateLabel()
        super.layoutSubviews()
        super.layoutSubviews()
    }
    func onValueChanged(sender: CustomSlider){
        updateLabel()
    }
    
   
    
    //while we are here, why not change the image here as well? (bonus material)
  /*  override public func awakeFromNib() {
        let utils = Utils()
        
        let image = UIImage.fontAwesomeIcon(name: .mapMarker, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 20, height: 45))
        
        self.setThumbImage(image, for: .normal)
        self.setThumbImage(image, for: .highlighted)
        super.awakeFromNib()
    }*/
    
    
}
