//
//  ViewController.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

final class WikipediaSearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel: WikipediaSearchViewModel = {
        let apiClient = WikipediaAPIClient(urlSession: .shared)
        let dependency = WikipediaSearchViewModel.Dependency(apiClient: apiClient)
        return WikipediaSearchViewModel(dependency)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        let query = searchBar.rx
            .text
            .orEmpty
            .debounce(0.3, scheduler: MainScheduler.instance)
            .asObservable()
        
        let cellSelected = tableView.rx
            .modelSelected(WikipediaPage.self)
            .asObservable()
        
        let input = WikipediaSearchViewModel.Input(queryText: query,
                                                   cellSelected: cellSelected)
        
        let output = viewModel.transform(input)
        
        output.searchResult
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: WikipediaSearchResultTableViewCell.self)) { $2.update($1) }
            .disposed(by: disposeBag)
        
        output.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.showWikipediaPage
            .emit(onNext: { [weak self] url in
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

