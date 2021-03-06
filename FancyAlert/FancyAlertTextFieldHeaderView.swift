//
//  FancyAlertTextFieldHeaderView.swift
//  FancyAlertDemo
//
//  Created by ancheng on 2018/5/14.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

class FancyAlertTextFieldHeaderView: FancyAlertBaseHeaderView {

    override var headerHeight: CGFloat {
        if textFields.count > 0 {
            return super.headerHeight + textFieldTopMargin + textFieldHeight * CGFloat(textFields.count) + textFieldsSpace * CGFloat(textFields.count - 1)
        } else {
            return super.headerHeight
        }
    }
    var markedColor: UIColor = FancyAlertConfig.actionSheetMarkedActionDefaultColor {
        didSet {
            textFields.forEach({
                $0.tintColor = $0.cursorColor ?? markedColor
            })
        }
    }

    private let labelSpace:CGFloat = 13
    private let bottomMargin: CGFloat = 28
    private let textFieldTopMargin: CGFloat = 21
    private let textFieldHeight: CGFloat = 30
    private let textFieldsSpace: CGFloat = 12

    private var textFields: [FancyTextField]

    init(title: String?, message: String?, width: CGFloat, inset: FancyAlertContentEdgeInsets, textFields: [FancyTextField]) {
        self.textFields = textFields
        super.init(title: title, message: message, width: width, inset: inset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI(title: String?, message: String?, width: CGFloat, outsideInset: FancyAlertContentEdgeInsets) {
        super.makeUI(title: title, message: message, width: width, outsideInset: outsideInset)

        var firstY = margin + titleLableHeight + (title != nil && message != nil ? labelSpace : 0) + messageLabelHeight + textFieldTopMargin
        if !textFields.isEmpty {
            for textField in textFields {
                addSubview(textField)
                textField.delegate = self
                switch textField.style {
                case .gray, .transparent:
                    textField.translatesAutoresizingMaskIntoConstraints = true
                    textField.frame = CGRect(x: margin, y: firstY, width: labelWidth, height: textFieldHeight)
                case .transparentAndSizeFit:
                    textField.translatesAutoresizingMaskIntoConstraints = false
                    textField.topAnchor.constraint(equalTo: topAnchor, constant: firstY).isActive = true
                    textField.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: margin).isActive = true
                    textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                    textField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
                }

                textField.tintColor = textField.cursorColor ?? markedColor
                firstY += (textFieldHeight + textFieldsSpace)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: UITextField.textDidChangeNotification, object: nil)
        }
    }

    @objc private func textFieldDidChange(notification: NSNotification) {

        guard let textField = notification.object as? FancyTextField, let tempText = textField.text as NSString?, let textMaxLength = textField.maxInputLength else { return }

        let textCount = tempText.length
        let lang = textInputMode?.primaryLanguage
        if lang == "zh-Hans" {
            guard let selectedRange = textField.markedTextRange else {
                if textCount > textMaxLength {
                    let rangeIndex = tempText.rangeOfComposedCharacterSequence(at: textMaxLength)
                    if rangeIndex.length > 1 { //判断第三方输入法的emoji表情
                        textField.text = tempText.substring(to: rangeIndex.location)
                    } else {
                        let range = tempText.rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: textMaxLength))
                        textField.text = tempText.substring(with: range)
                    }
                }
                return
            }
            if let _ = textField.position(from: selectedRange.start, offset: 0) {
                if textCount > textMaxLength {
                    let rangeIndex = tempText.rangeOfComposedCharacterSequence(at: textMaxLength)
                    if rangeIndex.length > 1 {
                        textField.text = tempText.substring(to: rangeIndex.location)
                    }
                }
            }
        } else {
            if textCount > textMaxLength {
                let rangeIndex = tempText.rangeOfComposedCharacterSequence(at: textMaxLength)
                if rangeIndex.length > 1 {
                    textField.text = tempText.substring(to: rangeIndex.location)
                } else {
                    let range = tempText.rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: textMaxLength))
                    textField.text = tempText.substring(with: range)
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension FancyAlertTextFieldHeaderView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFields.first?.resignFirstResponder()
        return true
    }

}
