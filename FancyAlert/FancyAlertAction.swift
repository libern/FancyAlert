//
//  FancyAlertAction.swift
//  FancyAlertDemo
//
//  Created by ancheng on 2018/3/20.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

public enum FancyAlertActionStyle {
    case normal
    case cancel
    case marked 
    case disabled // 点击后不会dismiss，只适用于actionsheet
}

open class FancyAlertAction {

    open var title: String
    open var style: FancyAlertActionStyle
    open var handler: (() -> Void)?
    open var isEnabled: Bool = true {
        didSet {
            if isEnabled != oldValue {
                enabledDidChange?(isEnabled)
            }
        }
    }
    open var color: UIColor? // default is FancyAlertViewController.markedColor

    var enabledDidChange: ((Bool) -> Void)?
    
    public init(title: String, style: FancyAlertActionStyle, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
}
