//
//  TrackerStore.swift
//  Tracker
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
}

final class TrackerStore: NSObject {
    
    //Delegate
    weak var delegate: TrackerStoreDelegate?
    
    //Services
    private let store = Store.shared
    private var context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()

    override init() {
        self.context = store.persistentContainer.viewContext
    }
    
    //MARK: - NSFetchedResultsController
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.categoryId, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    //MARK: FILTER
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        var predicates = [NSPredicate]()
        
        //TODO: - Разобраться как работает
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let iso860WeekdayIndex = weekdayIndex > 1 ? weekdayIndex - 2 : weekdayIndex + 5
        
        var regex = "" //1...111
        for index in 0..<7 {
            if index == iso860WeekdayIndex {
                regex += "1"
            } else {
                regex += "."
            }
        }
        //
        
        predicates.append(NSPredicate(
            format: "%K == nil OR (%K != nil AND %K MATCHES[c] %@)",
            #keyPath(TrackerCoreData.schedule),
            #keyPath(TrackerCoreData.schedule),
            #keyPath(TrackerCoreData.schedule), regex
        ))
        
        if !searchString.isEmpty {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[CoreData] %@",
                #keyPath(TrackerCoreData.name), searchString
            ))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try fetchedResultsController.performFetch()
        
        delegate?.didUpdate()
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func headerLabelInSection(_ section: Int) -> String? {
        guard let trackerCoreData = fetchedResultsController.sections?[section].objects?.first as? TrackerCoreData else { return nil }
        return trackerCoreData.category?.name ?? nil
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        do {
            let tracker = try makeTracker(from: trackerCoreData)
            return tracker
        } catch {
            return nil
        }
    }
    
    //MARK: CREATE
    //Создание трекера в БД из Swift-моделей трекера и категории
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.createdAt = Date()
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = ColorMarshalling.serialize(color: tracker.color)
        trackerCoreData.schedule = DayOfWeek.code(tracker.schedule) // [.monday, .saturday] -> "Понедельник,Суббота"
        trackerCoreData.category = categoryCoreData
        try context.save()
    }
}

//MARK: - CRUD
extension TrackerStore {
    
    //MARK: PARSE
    //Создание Swift-модели трекера из CoreData-модели трекера
    func makeTracker(from coreData: TrackerCoreData) throws -> Tracker {
        
        if let idString = coreData.trackerId,
           let id = UUID(uuidString: idString),
           let name = coreData.name,
           let emoji = coreData.emoji,
           let colorHex = coreData.colorHex,
           let daysCount = coreData.records {
            
            let color = ColorMarshalling.deserialize(hexString: colorHex)
            let scheduleString = coreData.schedule
            let schedule = DayOfWeek.decode(from: scheduleString)
            
            return Tracker(
                id: id,
                name: name,
                emoji: emoji,
                color: color!,
                daysCount: daysCount.count,
                schedule: schedule
            )
        } else {
            throw StoreError.decodeError
        }
    }
}


extension TrackerStore {
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.first
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}



