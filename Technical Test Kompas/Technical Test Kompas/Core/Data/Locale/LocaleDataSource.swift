//
//  LocaleDataSource.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RealmSwift
import RxSwift

protocol LocaleDataSourceProtocol: AnyObject {
    func getSavedNews() -> Observable<[SavedNewsEntity]>
    func getSavedNewsInfo(from news: ArticleListItem) -> Observable<SavedNewsEntity>
    func checkSaved(id: String) -> Observable<Bool>
    func addNewsToSave(from news: SavedNewsEntity) -> Observable<Bool>
    func removeNewsFromSave(id: String) -> Observable<Bool>
}

final class LocaleDataSource: NSObject {
    
    private let realm: Realm?
    private init(realm: Realm?) {
        self.realm = realm
    }
    
    static let sharedInstance: (Realm?) -> LocaleDataSource = { realmDatabase in
        return LocaleDataSource(realm: realmDatabase)
    }
}

extension LocaleDataSource: LocaleDataSourceProtocol {
    func getSavedNews() -> Observable<[SavedNewsEntity]> {
        return Observable<[SavedNewsEntity]>.create { observer in
            if let realm = self.realm {
                let games: Results<SavedNewsEntity> = {
                    realm.objects(SavedNewsEntity.self)
                }()
                observer.onNext(games.toArray(ofType: SavedNewsEntity.self))
                observer.onCompleted()
            } else {
                observer.onError(DatabaseError.invalidInstance)
            }
            return Disposables.create()
        }
    }
    
    func getSavedNewsInfo(from news: ArticleListItem) -> Observable<SavedNewsEntity> {
        return Observable<SavedNewsEntity>.create { observer in
            let newSavedNews = SavedNewsEntity()
            newSavedNews.id = news.id ?? ""
            newSavedNews.title = news.title ?? ""
            newSavedNews.publishedTime = news.publishedTime ?? ""
            newSavedNews.publishedDate = news.publishedDate ?? ""
            newSavedNews.imageURL = news.imageURL ?? ""
            newSavedNews.newsDescription = news.description ?? ""
            newSavedNews.newsURL = news.newsURL ?? ""
            observer.onNext(newSavedNews)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func checkSaved(id: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            if let realm = self.realm {
               let object = realm.object(ofType: SavedNewsEntity.self, forPrimaryKey: id)
                if object != nil {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            } else {
                print("ini error di kosong")
                observer.onError(DatabaseError.invalidInstance)
            }
            return Disposables.create()
        }
    }
    
    func addNewsToSave(from news: SavedNewsEntity) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            if let realm = self.realm {
                do {
                    try realm.write {
                        realm.add(news, update: .all)
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                } catch {
                    observer.onError(DatabaseError.requestFailed)
                    print("error disini")
                }
            } else {
                observer.onError(DatabaseError.invalidInstance)
            }
            return Disposables.create()
        }
    }
    
    
    
    func removeNewsFromSave(id: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            if let realm = self.realm {
                if let game = realm.object(ofType: SavedNewsEntity.self, forPrimaryKey: id) {
                    do {
                        try realm.write {
                            realm.delete(game)
                            observer.onNext(true)
                            observer.onCompleted()
                        }
                    } catch {
                        observer.onError(DatabaseError.requestFailed)
                    }
                } else {
                    observer.onError(DatabaseError.requestFailed)
                }
                
            } else {
                observer.onError(DatabaseError.requestFailed)
            }
            return Disposables.create()
        }
    }
    
    
}

extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for index in 0..<count {
            if let result = self[index] as? T {
                array.append(result)
            }
        }
        return array
    }
}

enum DatabaseError: LocalizedError {

  case invalidInstance
  case requestFailed
  
  var errorDescription: String? {
    switch self {
    case .invalidInstance: return "Database can't instance."
    case .requestFailed: return "Your request failed."
    }
  }

}

