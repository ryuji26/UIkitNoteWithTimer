//
//  ViewController.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/11/28.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate{

    private var canvasView: PKCanvasView!
    private var toolPicker: PKToolPicker = {
        if #available(iOS 14.0, *) {
            return PKToolPicker()
        } else {
            return PKToolPicker.shared(for: UIApplication.shared.windows.first!)!
        }
    }()

    private let defaultTool = PKInkingTool(.pen, color: .black, width: 1)
    // for double tap action on Apple Pencil
    private var currentTool: PKTool?
    private var previousTool: PKTool?

    // if a note is exist、a CollectionView set below properties
    var drawing: PKDrawing?
    var indexAtCollectionView: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        settingCanvas()
    }
    private func settingCanvas() {
        canvasView = PKCanvasView(frame: view.frame)
        canvasView.delegate = self
        if let drawing = drawing {
            canvasView.drawing = drawing
        }
        view.addSubview(canvasView)
    }
}

// MARK: PKToolPickerObserver
extension ViewController: PKToolPickerObserver {
    private func addPalette() {
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
        toolPicker.selectedTool = defaultTool
        currentTool = defaultTool
    }

    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        previousTool = currentTool
        currentTool = toolPicker.selectedTool
    }
}
