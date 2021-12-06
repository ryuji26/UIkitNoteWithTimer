//
//  EventNames.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/12/05.
//

import Foundation

enum EventNames: String {
    case oepnedDocument

    func eventName() -> Notification.Name {
        return Notification.Name(rawValue)
    }
}
