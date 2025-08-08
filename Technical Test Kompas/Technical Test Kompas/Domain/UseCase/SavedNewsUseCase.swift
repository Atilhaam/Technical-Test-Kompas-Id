//
//  SavedNewsUseCase.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 05/08/25.
//

import Foundation
import RxSwift

protocol SavedNewsUseCaseProtocol {
    
    func getSavedNews() -> Observable<[NewsModel]>
    func removeNews(id: String) -> Observable<Bool>
}

class SavedNewsUseCase: SavedNewsUseCaseProtocol {
    
    private let repository: NewsRepositoryProtocol
    
    required init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }
    
    func getSavedNews() -> Observable<[NewsModel]> {
        return repository.getSavedNews()
    }
    
    func removeNews(id: String) -> Observable<Bool> {
        return repository.removeNewsFromSaved(id: id)
    }
}
