//
//  WikipediaSearchViewModelTest.swift
//  RxSample4Tests
//
//  Created by quesera2 on 2018/11/21.
//  Copyright © 2018 quesera2. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import RxSample4

class WikipediaSearchViewModelTest: XCTestCase {

    func testViewModel() {
        let scheduler = TestScheduler(initialClock: 0)
        let target = createTarget(with: dummy)
        let disposeBag = DisposeBag()
        
        // テストシナリオ
        // VT 10〜30 で文字を三文字入力、VT 70 に文字削除で二文字に落とす
        let searchWordObservable = scheduler.createHotObservable([
            next(10, "S"),
            next(20, "Se"),
            next(30, "Sea"),
            next(40, "Sea,"),
            next(50, "Sea,Y"),
            next(60, "Sea,Yo"),
            next(70, "Se"),
            next(80, "Sea"),
        ])
        // VT 100 にセルをタップ
        let cellSelectEventObservable = scheduler.createHotObservable([
            next(100, WikipediaPage(id: 301, title: "Sea,You Next"))
        ])
        
        let input = WikipediaSearchViewModel.Input(queryText: searchWordObservable.asObservable(),
                                                   cellSelected: cellSelectEventObservable.asObservable())
        let output = target.transform(input)
        
        let searchResult = BehaviorRelay<[WikipediaPage]>(value: [])
        let navigationTitle = BehaviorRelay(value: "Wikipedia Search API")
        let showWikipediaPage = BehaviorRelay<URL?>(value: nil)
        
        output.searchResult
            .drive(searchResult)
            .disposed(by: disposeBag)
        output.navigationTitle
            .drive(navigationTitle)
            .disposed(by: disposeBag)
        output.showWikipediaPage
            .emit(to: showWikipediaPage)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(0) {
            XCTAssertEqual(searchResult.value, [])
            XCTAssertEqual(navigationTitle.value, "Wikipedia Search API")
            XCTAssertNil(showWikipediaPage.value)
        }
        
        scheduler.scheduleAt(29) {
            XCTAssertEqual(searchResult.value, [])
            XCTAssertEqual(navigationTitle.value, "Wikipedia Search API")
        }
        
        // VT 30 で検索結果とタイトル更新
        scheduler.scheduleAt(30) {
            XCTAssertEqual(searchResult.value, self.dummy)
            XCTAssertEqual(navigationTitle.value, "Sea 検索結果:3件")
            XCTAssertNil(showWikipediaPage.value)
        }
        
        scheduler.scheduleAt(69) {
            XCTAssertEqual(navigationTitle.value, "Sea,Yo 検索結果:3件")
        }
        
        // VT 70 でタイトルが初期表示に戻る
        scheduler.scheduleAt(70) {
            XCTAssertEqual(navigationTitle.value, "Wikipedia Search API")
        }
        
        scheduler.scheduleAt(99) {
            XCTAssertNil(showWikipediaPage.value)
        }
        
        // VT 100 で選択したアイテムの URL を流す
        scheduler.scheduleAt(100) {
            XCTAssertEqual(searchResult.value, self.dummy)
            XCTAssertEqual(navigationTitle.value, "Sea 検索結果:3件")
            XCTAssertEqual(showWikipediaPage.value?.absoluteString, "https://ja.wikipedia.org/w/index.php?curid=301")
        }
        
        scheduler.start()
    }
    
    func testCreateTitle() {
        let target = createTarget(with: [])
        
        // 三文字・データあり
        let pattern1 = target.createTitle(query: "Sea", result: dummy)
        XCTAssertEqual(pattern1, "Sea 検索結果:3件")
        
        // 二文字・データあり（境界値）
        let pattern2 = target.createTitle(query: "Se", result: dummy)
        XCTAssertEqual(pattern2, "Wikipedia Search API")
        
        // 検索結果 0 件
        let pattern3 = target.createTitle(query: "Sea,Ye", result: [])
        XCTAssertEqual(pattern3, "Sea,Ye 検索結果:0件")
        
        // ゼロ文字
        let pattern4 = target.createTitle(query: "", result: [])
        XCTAssertEqual(pattern4, "Wikipedia Search API")
    }
    
    private func createTarget(with data: [WikipediaPage]) -> WikipediaSearchViewModel {
        let apiClient = MockWikipediaAPIClient(data)
        let dependency = WikipediaSearchViewModel.Dependency(apiClient: apiClient)
        return WikipediaSearchViewModel(dependency)
    }
    
    private var dummy: [WikipediaPage] {
        return [
            WikipediaPage(id: 103, title: "Sea,You ＆ Me"),
            WikipediaPage(id: 301, title: "Sea,You Next"),
            WikipediaPage(id: 307, title: "Sea,Your Memory")
        ]
    }

}
