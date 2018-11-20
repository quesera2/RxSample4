//
//  WikipediaSearchViewModel.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Dependency
    associatedtype Input
    associatedtype Output
    
    init(_ dependency: Dependency)
    
    func transform(_ input: Input) -> Output
}

struct WikipediaSearchViewModel: ViewModelType {
    
    struct Dependency {
        let apiClient: WikipediaAPIClientProtocol
        let debounceScheduler: SchedulerType
    }
    
    struct Input {
        let queryText: Observable<String>
    }
    
    struct Output {
        let searchResult: Driver<[WikipediaPage]>
        let navigationTitle: Driver<String>
    }
    
    private let apiClient: WikipediaAPIClientProtocol
    private let debounceScheduler: SchedulerType
    
    init(_ dependency: Dependency) {
        self.apiClient = dependency.apiClient
        self.debounceScheduler = dependency.debounceScheduler
    }
    
    func transform(_ input: Input) -> Output {
        
        let searchWord = input.queryText
            .share(replay: 1)
        
        let result = searchWord.filter { $0.count >= 3 }
            .debounce(0.3, scheduler: debounceScheduler)
            .flatMap(self.apiClient.search)
            .share(replay: 1)
        
        let title = Observable.combineLatest(searchWord, result, resultSelector: createTitle)
        
        return Output(searchResult: result.asDriver(onErrorDriveWith: .empty()),
                      navigationTitle: title.asDriver(onErrorDriveWith: .empty()))
    }
    
    private func createTitle(query: String, result: [WikipediaPage]) -> String {
        if query.count < 3 {
            return "Wikipedia Search API"
        } else {
            return "\(query) 検索結果:\(result.count)件"
        }
    }
}
