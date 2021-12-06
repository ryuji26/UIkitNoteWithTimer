//
//  Document.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/12/05.
//

import UIKit
import PencilKit

final class Document: UIDocument {
    var dataModel = DataModel()

    override func contents(forType typeName: String) throws -> Any {
        return dataModel.data() ?? Data()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }
        dataModel = DataModel(data: data)
    }
}
