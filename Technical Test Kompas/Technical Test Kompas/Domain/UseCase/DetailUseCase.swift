//
//  DetailUseCase.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RxSwift

protocol DetailUseCaseProtocol {
    
    func saveNews(_ article: ArticleListItem) -> Observable<Bool>
    func removeNews(id: String) -> Observable<Bool>
    func checkSaved(id: String) -> Observable<Bool>

}

class DetailUseCase: DetailUseCaseProtocol {
    
    private let repository: NewsRepositoryProtocol
    
    required init(repository: NewsRepositoryProtocol) {
        self.repository = repository
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
    
}
