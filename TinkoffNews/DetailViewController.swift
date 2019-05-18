//
//  DetailViewController.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
	@IBOutlet weak var newsWebView: WKWebView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var news: NewsEntity! {
		didSet {
			updateNewsData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super .viewWillAppear(animated)
		setupUI()
	}
	
	
	func updateNewsData() {
		NetworkManager.shared.getNewsContent(urlSlug: news.urlSlug!) { (result) in
			switch result {
			case .succes(let data):
				DispatchQueue.main.async { [weak self] in
					self?.handleData(data: data)
				}
			case .error(let errorDescription):
				AlertsManager.shared.showWarning(title: errorDescription)
			}
		}
	}
	
	func handleData(data: String) {
		news.text = data
		newsWebView.loadHTMLString(data, baseURL: nil)
		titleLabel.text = news.title!
		dateLabel.text = handleDate(news.date!)
		activityIndicator.stopAnimating()
	}
	
	func handleDate(_ date: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.current
		dateFormatter.timeZone = TimeZone.current
		
		let dateString = date
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		guard let newsDate = dateFormatter.date(from: dateString) else { return "" }
			dateFormatter.dateFormat = "HH:mm MMM d, yyyy"
			return dateFormatter.string(from: newsDate)
	}
	
	@IBAction func dismissButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}

extension DetailViewController {
	func setupUI() {
		activityIndicator.hidesWhenStopped = true
		activityIndicator.startAnimating()
	}
}
