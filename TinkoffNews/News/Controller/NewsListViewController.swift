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
	
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action:
			#selector(self.handleRefresh(_:)),
								 for: .valueChanged)
		refreshControl.tintColor = #colorLiteral(red: 0.936944797, green: 0.8678727418, blue: 0.217387357, alpha: 1)
		return refreshControl
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		updateNewsData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchData()
	}
	//MARK: Data handling
	///Loading niews list from news service
	private func updateNewsData() {
		NetworkManager.shared.getNewslist(page: currentPage) { (result) in
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
	
	private func handleData(data: [[String: AnyObject]]) {
		news = data.compactMap { NewsEntity.createNew(from: $0) }
		CoreDataStack.shared.saveContext()
		fetchData()
	}
	///loading data news list from local cache
	private func fetchData() {
		guard let fetchedData = CoreDataStack.shared.fetchAll(NewsEntity.self) else {
			return
		}
		news = fetchedData
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	///loading +20 more news from news service
	private func getMoreNews() {
		currentPage += 1
		updateNewsData()
	}
	
}

//MARK: UITableViewDataSource methods
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
//MARK: UITableViewDelegate methods
extension NewsListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "showDetail", sender: indexPath)
		
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == "showDetail" else { return }
		let indexPath = sender as! IndexPath
		guard let dvc = segue.destination as? DetailViewController else {
			print("Internal error in \(#function): destination is unreacheble")
			return
		}
		dvc.news = news[indexPath.row]
		tableView.reloadRows(at: [indexPath], with: .none)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == news.count - 1 {
			getMoreNews()
		}
	}
}

//MARK: Handle UI Setting Extension
extension NewsListViewController {
	private func setupUI() {
		tableView.register(UINib.init(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: NewsTableViewCell.cellIdentifier)
		tableView.showsVerticalScrollIndicator = false
		tableView.dataSource = self
		tableView.delegate = self
		tableView.addSubview(self.refreshControl)
		navigationBarSetup()
	}
	
	private func navigationBarSetup() {
		self.navigationItem.title = "Tinkoff News"
		self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.8479318443)
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}

	
	@objc
	func handleRefresh(_ refreshControl: UIRefreshControl) {
		updateNewsData()
		self.tableView.reloadData()
		refreshControl.endRefreshing()
	}
}
