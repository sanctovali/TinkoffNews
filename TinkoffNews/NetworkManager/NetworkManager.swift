//
//  NetworkManager.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation



	struct PaginationSettings {
		private init() {}
		static let shared = PaginationSettings()
		private(set) var pageSize = 20
		mutating func setPageSize(to size: Int) {
			if size > 0 {
				pageSize = size
			} else {
				pageSize = 0
			}
		}
	}


enum Result<T> {
	case succes(T)
	case error(String)
}

class NetworkManager {
	
	private init() {}
	static let shared = NetworkManager()
	
	func getnewsList(page: Int, completion: @escaping(Result<[[String: AnyObject]]>) -> ()) {
		let pageSettings = PaginationSettings.shared
		guard let url = URL(string: "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticles?pageSize=\(pageSettings.pageSize)&pageOffset=\(pageSettings.pageSize * page)") else { print("urlError"); return }
		let session = URLSession.shared
		let task = session.dataTask(with: url) {(data, _, error) in
			guard error == nil else {
				print("Error in \(#function) at line \(#line):\(error!.localizedDescription) ")
				return completion(.error(error!.localizedDescription))
			}
			guard let data = data else {
				return completion(.error("No data received"))
			}
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				guard let response = json as? [String: AnyObject] else {
					return completion(.error(error?.localizedDescription ?? "No data retrieve"))
				}
				guard let incomingDict = response["response"] as? [String: AnyObject] else {
					return completion(.error(error?.localizedDescription ?? "No data retrieve"))
				}
				guard let incomingArray = incomingDict["news"] as? [[String: AnyObject]] else {
					return completion(.error(error?.localizedDescription ?? "No valid data retrieve"))
				}
				DispatchQueue.main.async {
					completion(.succes(incomingArray))
				}
			} catch let error {
				print("Error in \(#function) at line \(#line): \(error.localizedDescription)")
				completion(.error(error.localizedDescription))
			}
		}
		task.resume()
	}
	
	
	
}
