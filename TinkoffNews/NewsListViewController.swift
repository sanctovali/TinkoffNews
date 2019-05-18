//
//  ViewController.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit
import CoreData

class NewsListViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	private var currentPage = 0
	private var news = [NewsEntity]()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateNewsData()
	}
	
	func updateNewsData() {
		NetworkManager.shared.getnewsList(page: currentPage) { (result) in
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
	
	func handleData(data: [[String: AnyObject]]) {
		news = data.compactMap { NewsEntity.createNew(from: $0) }
		CoreDataStack.shared.saveContext()
		
		let context = CoreDataStack.shared.getContext()
		let fetchRequest = NSFetchRequest<NewsEntity>(entityName: "NewsEntity")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
		
		do {
			let result = try context.fetch(fetchRequest)
			news = result
			tableView.reloadData()
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
			AlertsManager.shared.showWarning(title: error.localizedDescription)
		}
	}
}


extension NewsListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return news.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.cellIdentifier, for: indexPath) as? NewsTableViewCell else {
			let cell = NewsTableViewCell(style: .default, reuseIdentifier: NewsTableViewCell.cellIdentifier)
			return cell
		}
		let newsToPresent = news[indexPath.row]
		cell.configure(with: newsToPresent)
		
		return cell
	}
}

extension NewsListViewController: UITableViewDelegate {
	
}
//MARK: Handle UI Setting Extension
extension NewsListViewController {
	private func setupUI() {
		tableView.register(UINib.init(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: NewsTableViewCell.cellIdentifier)
		tableView.showsVerticalScrollIndicator = false
		tableView.dataSource = self
		tableView.delegate = self
	//	tableView.estimatedRowHeight = 100
		//tableView.rowHeight = UITableView.automaticDimension
		//tableView.addSubview(self.refreshControl)
	}
	
	private func setupRefreshControl() {
		if let refresh = tableView.refreshControl {
			refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		}
	}
	
	@objc
	func handleRefresh(_ refreshControl: UIRefreshControl) {
		//reloadNews()
		self.tableView.reloadData()
		refreshControl.endRefreshing()
	}
}
