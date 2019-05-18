//
//  NewsEntity+CoreDataProperties.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//
//

import Foundation
import CoreData


extension NewsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsEntity> {
        return NSFetchRequest<NewsEntity>(entityName: "NewsEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var date: String?
    @NSManaged public var title: String?
    @NSManaged public var text: NSDate?
    @NSManaged public var viewsCounter: Int16

}
