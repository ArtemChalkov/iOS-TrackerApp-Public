//
//  Store.swift
//  Tracker
//


import Foundation
import CoreData

final class Store {
    
    static let shared = Store()
    
    private init () {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Код для обработки ошибки
            }
        })
        return container
    }()
    
}
