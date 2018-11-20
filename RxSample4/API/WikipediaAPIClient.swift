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

class WikipediaAPIClient: WikipediaAPIClientProtocol {

    private let session: URLSession
    
    init(_ session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func search(_ query: String) -> Single<[WikipediaPage]> {
        let request = createRequest(query)
        
        return session.rx
            .response(request: request)
            .map(mapToResult)
            .catchErrorJustReturn([])
            .asSingle()
    }
    
    private func createRequest(_ query: String) -> URLRequest {
        let components = initializeComponent(host: "https://ja.wikipedia.org", query: query)
        return URLRequest(url: components.url!)
    }
    
    private func initializeComponent(host: String, query: String) -> URLComponents {
        var components = URLComponents(string: host)!
        components.path = "/w/api.php"
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "list", value: "search"),
            URLQueryItem(name: "srsearch", value: query)
        ]
        return components
    }
    
    private func mapToResult(response: HTTPURLResponse, data: Data) throws -> [WikipediaPage] {
        let response = try JSONDecoder().decode(WikipediaSearchResponse.self, from: data)
        return response.pages
    }
}
