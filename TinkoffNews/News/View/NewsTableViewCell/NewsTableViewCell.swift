//
//  NewsTableViewCell.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

	@IBOutlet weak var countLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	
	static let cellIdentifier = "titleCell"
	
	func configure(with news: NewsEntity) {
		titleLabel.text = news.title
		let counterText = news.viewsCounter > 99 ? "99+" : "\(news.viewsCounter)"
		countLabel.text = counterText
		countLabel.layer.cornerRadius = countLabel.bounds.height / 2
		countLabel.layer.masksToBounds = true
	}
    
}
