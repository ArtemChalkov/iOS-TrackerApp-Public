//
//  TrackerCategoryStore.swift
//  Tracker
//

import UIKit
import CoreData

enum StoreError: Error {
    case decodeError
}

final class TrackerCategoryStore {
    
    //MARK: Services
    private let store = Store.shared
    private let context: NSManagedObjectContext
    
    //MARK: Data
    var categories = [TrackerCategory]()
   
    init() {
        context = store.persistentContainer.viewContext
        do {
            try setupCategories(with: context)
        } catch {
            print(error)
        }
    }
}

//MARK: - Private
extension TrackerCategoryStore {
    //MARK: - Setup
    //Create or fetch categories from DB
    private func setupCategories(with context: NSManagedObjectContext) throws {
        
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        let categoryResult = try context.fetch(categoryRequest)
        
        //Запросили из БД если результат 0 то создаем категорию в БД
        if categoryResult.count == 0 {
            let _ = [
                TrackerCategory(name: "Домашний уют"),
                //TrackerCategory(name: "Радостные мелочи"),
            ].map { category in
                let categoryCoreData = TrackerCategoryCoreData(context: context)
                
                categoryCoreData.categoryId = category.id.uuidString
                categoryCoreData.createdAt = Date()
                categoryCoreData.name = category.name
                return categoryCoreData
            }
            try context.save()
            return
        }
        
        //Если результат не 0, то выгржуаем и парсим категории в модели
        categories = try categoryResult.map { try makeCategory(from: $0) }
    }
    
    //Парсинг СoreData-модели в Swift-модель
    private func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        
        if let idString = coreData.categoryId,
           let id = UUID(uuidString: idString),
           let name = coreData.name {
            return TrackerCategory(id: id, name: name)
        } else {
            throw StoreError.decodeError
        }
    }
}

//MARK: - Public
extension TrackerCategoryStore {
    //Вытаскиваем конкертную категорию по id (чтобы положить трекер)
    func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString)
        let category = try context.fetch(request)
        return category[0]
    }
}
