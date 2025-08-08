//
//  NewsRepository.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RxSwift

protocol NewsRepositoryProtocol {
    
    func getNews() -> Observable<[Section]>
    
    func getSavedNews() -> Observable<[NewsModel]>

    func addNewsToSaved(game: ArticleListItem) -> Observable<Bool>
    
    func checkSave(id: String) -> Observable<Bool>
    
    func removeNewsFromSaved(id: String) -> Observable<Bool>
    
}

final class NewsRepository: NSObject {
    
    typealias NewsInstance = (LocaleDataSource, RemoteDataSource) -> NewsRepository
    fileprivate let remote: RemoteDataSource
    fileprivate let locale: LocaleDataSource
    private init(locale: LocaleDataSource, remote: RemoteDataSource) {
        self.locale = locale
        self.remote = remote
    }
    
    static let sharedInstance: NewsInstance = { localeRepo, remoteRepo in
        return NewsRepository(locale: localeRepo, remote: remoteRepo)
    }
}

extension NewsRepository: NewsRepositoryProtocol {
    func getNews() -> Observable<[Section]> {
        return self.remote.getNews()
    }
        
    func getSavedNews() -> Observable<[NewsModel]> {
        return self.locale.getSavedNews()
            .map { self.mapSavedNewsEntitiesToModels($0) }
    }
    
    func addNewsToSaved(game: ArticleListItem) -> Observable<Bool> {
        return self.locale.getSavedNewsInfo(from: game)
            .flatMap { self.locale.addNewsToSave(from: $0)}
    }
    
    func checkSave(id: String) -> Observable<Bool> {
        return self.locale.checkSaved(id: id)
    }
    
    func removeNewsFromSaved(id: String) -> Observable<Bool> {
        return self.locale.removeNewsFromSave(id: id)
    }
    
    func mapSavedNewsEntitiesToModels(_ entities: [SavedNewsEntity]) -> [NewsModel] {
        return entities.map {
            NewsModel(
                id: $0.id,
                title: $0.title,
                imageURL: $0.imageURL,
                newsDescription: $0.newsDescription,
                publishedTime: $0.publishedTime,
                PublishedDate: $0.publishedDate,
                newsURL: $0.newsURL,
                audioURL: $0.audioURL
            )
        }
    }
}
