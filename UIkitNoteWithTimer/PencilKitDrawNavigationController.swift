//
//  PencilKitDrawNavigationController.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/12/03.
//

import UIKit

class PencilKitDrawNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBarBackground()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateNavigationBarBackground()
    }

    func updateNavigationBarBackground() {
        // ナビゲーションバーの背景をオフ
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIColor.secondarySystemBackground.withAlphaComponent(0.95).set()
        UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        navigationBar.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: .default)
        UIGraphicsEndImageContext()
    }
}
