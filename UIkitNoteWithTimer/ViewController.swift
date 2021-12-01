//
//  ViewController.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/11/28.
//

import UIKit
import PencilKit

class ViewController: UIViewController{


    @IBOutlet weak var canvasView: PKCanvasView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let canvas = PKCanvasView(frame: view.frame)
        view.addSubview(canvas)
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 30)
    }
}

extension ViewController: PKCanvasViewDelegate {

}

extension ViewController: PKToolPickerObserver {

}
