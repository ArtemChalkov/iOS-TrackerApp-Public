//
//  TrackerCategoryStore.swift
//  Tracker
//

import UIKit
import CoreData

enum StoreError: Error {
    case decodeError
    case fetchCategoryError
    case deleteError
    case pinError
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    //MARK: Services
    //private let store = Store.shared
    private let context: NSManagedObjectContext
    
    //MARK: Data
    var categories = [TrackerCategory]()
    
    var categoriesCoreData: [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    convenience override init() {
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let context = Store.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        
        self.context = context
        
        super.init()
//        do {
//            try self.setupCategories(with: context)
//        } catch {
//            print(error)
//        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.createdAt, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
}

//MARK: - Private
extension TrackerCategoryStore {
    
//    //MARK: - Setup
//    //Create or fetch categories from DB
//    private func setupCategories(with context: NSManagedObjectContext) throws {
//        
//        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
//        let categoryResult = try context.fetch(categoryRequest)
//        
//        //Запросили из БД если результат 0 то создаем категорию в БД
//        if categoryResult.count == 0 {
//            let _ = [
//                TrackerCategory(name: "Домашний уют"),
//                //TrackerCategory(name: "Радостные мелочи"),
//            ].map { category in
//                let categoryCoreData = TrackerCategoryCoreData(context: context)
//                
//                categoryCoreData.categoryId = category.id.uuidString
//                categoryCoreData.createdAt = Date()
//                categoryCoreData.name = category.name
//                return categoryCoreData
//            }
//            try context.save()
//            return
//        }
//        
//        //Если результат не 0, то выгржуаем и парсим категории в модели
//        categories = try categoryResult.map { try makeCategory(from: $0) }
//    }
    
}

//MARK: - Public
extension TrackerCategoryStore {
    
    //Парсинг СoreData-модели в Swift-модель
    func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        
        if let idString = coreData.categoryId,
           let id = UUID(uuidString: idString),
           let name = coreData.name {
            return TrackerCategory(id: id, name: name)
        } else {
            throw StoreError.decodeError
        }
    }
    
    @discardableResult
    func makeCategory(with name: String) throws -> TrackerCategory {
        let category = TrackerCategory(name: name)
        let TrackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        TrackerCategoryCoreData.categoryId = category.id.uuidString
        TrackerCategoryCoreData.createdAt = Date()
        TrackerCategoryCoreData.name = category.name
        try context.save()
        return category
    }
    
    //Вытаскиваем конкертную категорию по id (чтобы положить трекер)
    func categoryCoreData(with id: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString)
        let category = try context.fetch(request)
        return category[0]
    }
    
    func updateCategory(with data: TrackerCategory.Data) throws {
        let category = try getCategoryCoreData(by: data.id)
        category.name = data.name
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let categoryToDelete = try getCategoryCoreData(by: category.id)
        context.delete(categoryToDelete)
        
        try context.save()
    }
    
    private func getCategoryCoreData(by id: UUID) throws -> TrackerCategoryCoreData {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.categoryId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        guard let category = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchCategoryError }
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
        return category
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
