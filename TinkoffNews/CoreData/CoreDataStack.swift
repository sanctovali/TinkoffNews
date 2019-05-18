//
//  CoreDataStack.swift
//  TinkoffNews
//
//  Created by Valentin Kiselev on 18/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	private init() {}
	static let shared = CoreDataStack()
	
	lazy var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: "TinkoffNews")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	func getContext() -> NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func fetch<T: NSManagedObject>(_ objectType: T.Type, id: String) -> T? {
		let entityName = String(describing: objectType)
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		fetchRequest.predicate = NSPredicate(format: "id = %@", id)
		do {
			if let result = try CoreDataStack.shared.getContext().fetch(fetchRequest).first as? T {
				return result
			}
		} catch {
			print("Error in \(#function) at line \(#line): \(entityName) with id=\(id) not found")
			return nil
		}
		return nil
	}
	
}
