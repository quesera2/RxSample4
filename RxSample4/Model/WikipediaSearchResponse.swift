//
//  WikipediaSearchResponse.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import Foundation

struct WikipediaSearchResponse: Decodable {
    let pages: [WikipediaPage]
    
    private enum CodingKeys: String, CodingKey {
        case query
    }
    
    private enum InnerCodingKeys: String, CodingKey {
        case search
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder
            .container(keyedBy: CodingKeys.self)
            .nestedContainer(keyedBy: InnerCodingKeys.self, forKey: .query)
        self.pages = try container.decode([WikipediaPage].self, forKey: .search)
    }
}
