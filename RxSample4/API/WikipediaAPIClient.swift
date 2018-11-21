//
//  WikipediaAPIClient.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WikipediaAPIClientProtocol {
    func search(_ query: String) -> Single<[WikipediaPage]>
}

final class WikipediaAPIClient: WikipediaAPIClientProtocol {

    private let session: URLSession
    
    init(urlSession: URLSession) {
        session = urlSession
    }
    
    func search(_ query: String) -> Single<[WikipediaPage]> {
        let request = createRequest(query)
        
        return session.rx
            .response(request: request)
            .map(mapToResult)
            .catchErrorJustReturn([])
            .asSingle()
    }
    
    internal func createRequest(_ query: String) -> URLRequest {
        let url = buildURL(query)
        return URLRequest(url: url)
    }
    
    private func buildURL(_ query: String) -> URL {
        var components = URLComponents(string: "https://ja.wikipedia.org")!
        components.path = "/w/api.php"
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "list", value: "search"),
            URLQueryItem(name: "srsearch", value: query)
        ]
        return components.url!
    }
    
    internal func mapToResult(response: HTTPURLResponse, data: Data) throws -> [WikipediaPage] {
        let response = try JSONDecoder().decode(WikipediaSearchResponse.self, from: data)
        return response.pages
    }
}
