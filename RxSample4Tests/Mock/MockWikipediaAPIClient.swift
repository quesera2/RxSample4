//
//  MockWikipediaAPIClient.swift
//  RxSample4Tests
//
//  Created by quesera2 on 2018/11/21.
//  Copyright © 2018 quesera2. All rights reserved.
//

import Foundation
import RxSwift
@testable import RxSample4

final class MockWikipediaAPIClient: WikipediaAPIClientProtocol {

    private let result: [WikipediaPage]
    
    init(_ expectResult: [WikipediaPage]) {
        result = expectResult
    }
    
    func search(_ query: String) -> Single<[WikipediaPage]> {
        return Single.just(result)
    }
}
