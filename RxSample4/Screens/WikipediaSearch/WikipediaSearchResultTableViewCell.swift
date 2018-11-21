//
//  WikipediaSearchResultTableViewCell.swift
//  RxSample4
//
//  Created by quesera2 on 2018/11/20.
//  Copyright © 2018 quesera2. All rights reserved.
//

import UIKit

final class WikipediaSearchResultTableViewCell: UITableViewCell {
    
    func update(_ data: WikipediaPage) {
        textLabel?.text = data.title
        detailTextLabel?.text = data.urlString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}
