//
//  SavedNewsEntity.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//
//
import Foundation
import RealmSwift

class SavedNewsEntity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var newsDescription: String = ""
    @objc dynamic var publishedTime: String = ""
    @objc dynamic var publishedDate: String = ""
    @objc dynamic var newsURL: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
