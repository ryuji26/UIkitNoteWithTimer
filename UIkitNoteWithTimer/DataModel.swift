//
//  DataModel.swift
//  UIkitNoteWithTimer
//
//  Created by 髙橋　竜治 on 2021/12/01.
//
/*
 アプリのデータモデルを支えるのは、クロスプラットフォームの'PKDrawing'オブジェクトです。
 PKDrawingは、SwiftではCodableに準拠しています。→Codableとは、インスタンス（オブジェクト）情報を他の形式にデータ変換するプロトコル。
 Codableに準拠していますが、dataRepresentation()メソッドを使って、Dataオブジェクトとしてそのデータ表現を取得することもできます。
 */


import UIKit
import PencilKit
import os

/// データモデル構造体
struct DataModel: Codable {

    /// 描画ページのデフォルト名
    static let defaultDrawingNames: [String] = ["Notes"]

    /// canvasの幅
    static let canvasWidth: CGFloat = 768

    ///     var signature = PKDrawing() を削除
    var drawings: [PKDrawing] = []
}

/// データモデルの変更を監視するオブザーバー
protocol DataModelControllerObserver {
    /// データモデル変更時に呼び出されるメソッド
    func dataModelChanged()
}

/// データモデルへの変更を調整
class DataModelController {

    /// 基礎となるデータモデル
    var dataModel = DataModel()

    /// サムネイル関係
    var thumbnails = [UIImage]()
    var thumbnailTraitCollection = UITraitCollection() {
        didSet {
            // ユーザーインターフェースが変更されたらサムネイルを再生成
            if oldValue.userInterfaceStyle != thumbnailTraitCollection.userInterfaceStyle {
                generateAllThumbnails()
            }
        }
    }

    /// バックグラウンド操作のためのディスパッチキュー
    private let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .background)
    private let serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)

    /// 配列に自身を追加することで、変更の通知を開始する
    var observers = [DataModelControllerObserver]()

    /// サムネイルのサイズ
    static let thumbnailSize = CGSize(width: 192, height: 256)

    /// データモデルのdrawingsにアクセスするためのプロパティ
    var drawings: [PKDrawing] {
        get { dataModel.drawings }
        set { dataModel.drawings = newValue }
    }
    /// signatureはいらないのでコメントアウト
//    var signature: PKDrawing {
//        get { dataModel.signature }
//        set { dataModel.signature = newValue }
//    }

    /// 新しいデータモデルの初期化
    init() {
        loadDataModel()
    }

    /// 新しいサムネイルを生成
    func updateDrawing(_ drawing: PKDrawing, at index: Int) {
        dataModel.drawings[index] = drawing
        generateThumbnail(index)
        saveDataModel()
    }

    /// 全てのサムネイルの生成を行う
    private func generateAllThumbnails() {
        for index in drawings.indices {
            generateThumbnail(index)
        }
    }

    /// Helper method to cause regeneration of a specific thumbnail, using the current user interface style
    /// of the thumbnail view controller.
    private func generateThumbnail(_ index: Int) {
        let drawing = drawings[index]
        let aspectRatio = DataModelController.thumbnailSize.width / DataModelController.thumbnailSize.height
        let thumbnailRect = CGRect(x: 0, y: 0, width: DataModel.canvasWidth, height: DataModel.canvasWidth / aspectRatio)
        let thumbnailScale = UIScreen.main.scale * DataModelController.thumbnailSize.width / DataModel.canvasWidth
        let traitCollection = thumbnailTraitCollection

        thumbnailQueue.async {
            traitCollection.performAsCurrent {
                let image = drawing.image(from: thumbnailRect, scale: thumbnailScale)
                DispatchQueue.main.async {
                    self.updateThumbnail(image, at: index)
                }
            }
        }
    }

    /// Helper method to replace a thumbnail at a given index.
    private func updateThumbnail(_ image: UIImage, at index: Int) {
        thumbnails[index] = image
        didChange()
    }

    /// Helper method to notify observer that the data model changed.
    private func didChange() {
        for observer in self.observers {
            observer.dataModelChanged()
        }
    }

    /// ファイルのURL
    private var saveURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory.appendingPathComponent("PencilKitDraw.data")
    }

    /// ファイルをストレージに保存
    func saveDataModel() {
        let savingDataModel = dataModel
        let url = saveURL
        serializationQueue.async {
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(savingDataModel)
                try data.write(to: url)
            } catch {
                os_log("Could not save data model: %s", type: .error, error.localizedDescription)
            }
        }
    }

    /// ストレージからデータを読み込む
    private func loadDataModel() {
        let url = saveURL
        serializationQueue.async {
            // Load the data model, or the initial test data.
            let dataModel: DataModel

            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let decoder = PropertyListDecoder()
                    let data = try Data(contentsOf: url)
                    dataModel = try decoder.decode(DataModel.self, from: data)
                } catch {
                    os_log("Could not load data model: %s", type: .error, error.localizedDescription)
                    dataModel = self.loadDefaultDrawings()
                }
            } else {
                dataModel = self.loadDefaultDrawings()
            }

            DispatchQueue.main.async {
                self.setLoadedDataModel(dataModel)
            }
        }
    }

    /// データモデルがない場合、初期化して構築
    private func loadDefaultDrawings() -> DataModel {
        var testDataModel = DataModel()
        for sampleDataName in DataModel.defaultDrawingNames {
            guard let data = NSDataAsset(name: sampleDataName)?.data else { continue }
            if let drawing = try? PKDrawing(data: data) {
                testDataModel.drawings.append(drawing)
            }
        }
        return testDataModel
    }

    /// Helper method to set the current data model to a data model created on a background queue.
    private func setLoadedDataModel(_ dataModel: DataModel) {
        self.dataModel = dataModel
        thumbnails = Array(repeating: UIImage(), count: dataModel.drawings.count)
        generateAllThumbnails()
    }

    /// 新規データ作成
    func newDrawing() {
        let newDrawing = PKDrawing()
        dataModel.drawings.append(newDrawing)
        thumbnails.append(UIImage())
        updateDrawing(newDrawing, at: dataModel.drawings.count - 1)
    }
}
