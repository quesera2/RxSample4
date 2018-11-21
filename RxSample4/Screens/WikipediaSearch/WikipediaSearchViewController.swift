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

class WikipediaSearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel: WikipediaSearchViewModel = {
        let apiClient = WikipediaAPIClient()
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
        
        let input = WikipediaSearchViewModel.Input(queryText: query)
        
        let output = viewModel.transform(input)
        
        output.searchResult
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: WikipediaSearchResultTableViewCell.self)) { $2.update($1) }
            .disposed(by: disposeBag)
        
        output.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(WikipediaPage.self)
            .subscribe(onNext: { [weak self] item in
                let safariViewController = SFSafariViewController(url: item.url)
                self?.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

