//
//  WikipediaPage.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import Foundation

struct WikipediaPage: Equatable, Decodable {
    let id: Int
    let title: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "pageid"
        case title
    }
}

extension WikipediaPage {
    
    var urlString: String { return "https://ja.wikipedia.org/w/index.php?curid=\(id)" }
    
    var url: URL { return URL(string: urlString)! }

}
