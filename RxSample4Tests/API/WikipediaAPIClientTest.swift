//
//  WikipediaAPIClientTest.swift
//  RxSample4Tests
//
//  Created by quesera2 on 2018/11/21.
//  Copyright © 2018 quesera2. All rights reserved.
//

import XCTest
@testable import RxSample4

class WikipediaAPIClientTest: XCTestCase {
    
    let target = WikipediaAPIClient(urlSession: .shared)
    
    func testBuildUrl() {
        let result = target.createRequest("Swift")
        XCTAssertNotNil(result.url)
        XCTAssertEqual(result.httpMethod, "GET")
        XCTAssertEqual(result.url?.absoluteString , "https://ja.wikipedia.org/w/api.php?format=json&action=query&list=search&srsearch=Swift")
    }
    
    func testDecodeJson() throws {
        let json = dummyJson.data(using: .utf8)!
        let url = URL(string: "http://example.com/")!
        let dummyResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        
        let result = try target.mapToResult(response: dummyResponse, data: json)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1652941)
        XCTAssertEqual(result[0].title, "深愛")
        XCTAssertEqual(result[1].id, 1314482)
        XCTAssertEqual(result[1].title, "深愛〜only one〜")
    }

    func testDecodeBrokenJson() {
        let json = brokenJson.data(using: .utf8)!
        let url = URL(string: "http://example.com/")!
        let dummyResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        
        XCTAssertThrowsError(try target.mapToResult(response: dummyResponse, data: json)) { error in
            XCTAssertTrue(error is DecodingError)
            guard case DecodingError.keyNotFound(let codingKey, let context) = error else {
                XCTFail("failure decoding with unexpected error")
                return
            }
            // search 配列の 2 番目の要素の pageId が存在しない
            XCTAssertEqual(codingKey.stringValue, "pageid")
            XCTAssertEqual(context.codingPath.count, 2)
            XCTAssertEqual(context.codingPath[0].stringValue, "search")
            XCTAssertEqual(context.codingPath[1].intValue, 1)
        }
    }
    
    private let dummyJson = """
{
    "batchcomplete": "",
    "continue": {
        "sroffset": 10,
        "continue": "-||"
    },
    "query": {
        "searchinfo": {
            "totalhits": 256
        },
        "search": [
            {
                "ns": 0,
                "title": "深愛",
                "pageid": 1652941,
                "size": 13587,
                "wordcount": 1154,
                "snippet": "ダミー",
                "timestamp": "2018-10-29T07:53:57Z"
            },
            {
                "ns": 0,
                "title": "深愛〜only one〜",
                "pageid": 1314482,
                "size": 4190,
                "wordcount": 322,
                "snippet": "ダミー",
                "timestamp": "2017-04-19T20:45:05Z"
            }
        ]
    }
}
"""
    
    private let brokenJson = """
{
    "query": {
        "search": [
            {
                "title": "深愛",
                "pageid": 1652941,
            },
            {
                "title": "深愛〜only one〜",
            }
        ]
    }
}
"""

}
