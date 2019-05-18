//
//  NewsEntity.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation
import CoreData

extension NewsEntity {
	static func createNew(from dictionary: [String: AnyObject]) -> NewsEntity? {
		guard 	let id = dictionary["id"] as? String,
			let title = dictionary["title"] as? String,
			let urlSlug = dictionary["slug"] as? String,
			let date = dictionary["date"] as? String
			//let text = dictionary["text"] as? String
			else { return nil }
		
		guard CoreDataStack.shared.fetch(NewsEntity.self, id: id) == nil else { return nil }
		
		let context = CoreDataStack.shared.getContext()
		guard let newsEntity = NSEntityDescription.insertNewObject(forEntityName: "NewsEntity", into: context) as? NewsEntity else { return nil }
		newsEntity.id = id
		newsEntity.title = title
		newsEntity.urlSlug = urlSlug
		newsEntity.date = date
		return newsEntity
		
	}
}
