/*
 *  SetupSampleView.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */


import UIKit

protocol SetupSampleViewDelegate: AnyObject {
    func userDidTapViewAt(location: CGPoint)
}

class SetupSampleView: UIView {

    weak var delegate: SetupSampleViewDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            print("tap position: \(position)")
            delegate?.userDidTapViewAt(location: position)
        }
    }
}
