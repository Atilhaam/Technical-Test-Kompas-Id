//
//  HomeUseCase.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RxSwift

protocol HomeUseCaseProtocol {
    
    func getNews() -> Observable<[Section]>
    func saveNews(_ article: ArticleListItem) -> Observable<Bool>
    func removeNews(id: String) -> Observable<Bool>
    func checkSaved(id: String) -> Observable<Bool>
    func getSavedNews() -> Observable<[NewsModel]> 
}

class HomeUseCase: HomeUseCaseProtocol {
    
    private let repository: NewsRepositoryProtocol
    
    required init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }
    
    func getNews() -> Observable<[Section]> {
        return repository.getNews()
    }
    
    func saveNews(_ article: ArticleListItem) -> Observable<Bool> {
        return repository.addNewsToSaved(game: article)
    }
    
    func removeNews(id: String) -> Observable<Bool> {
        return repository.removeNewsFromSaved(id: id)
    }
    
    func checkSaved(id: String) -> Observable<Bool> {
        return repository.checkSave(id: id)
    }
    
    func getSavedNews() -> Observable<[NewsModel]> {
        return repository.getSavedNews()
    }

    
}
