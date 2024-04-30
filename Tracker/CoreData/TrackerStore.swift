//
//  TrackerStore.swift
//  Tracker
//

import UIKit
import CoreData

enum CompleteStatus {
    case complete
    case uncomplete
    case none
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    var delegate: TrackerStoreDelegate? { get set}
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws
    func deleteTracker(_ tracker: Tracker) throws
    func togglePin(for tracker: Tracker) throws
    func loadFilteredTrackers(date: Date, searchString: String) throws
    
    var completedTrackers: Set<TrackerRecord> { get set }
    var completeStatus: CompleteStatus { get set }
}

final class TrackerStore: NSObject {
    
    //Delegate
    weak var delegate: TrackerStoreDelegate?
    
    //Services
    private let store = Store.shared
    private var context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    
    //Filter
    private var currentDate = Date()
    var completeStatus = CompleteStatus.none
    var completedTrackers: Set<TrackerRecord> = []

    override init() {
        self.context = store.persistentContainer.viewContext
    }
    
    //MARK: - NSFetchedResultsController
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.createdAt, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    //MARK: FILTER
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        
        self.currentDate = date
        
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
    
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {
        guard
            let emoji = data.emoji,
            let color = data.color,
            let category = data.category
        else { return }
        
        let trackerCoreData = try getTrackerCoreData(by: tracker.id)
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        trackerCoreData?.name = data.name
        trackerCoreData?.emoji = emoji
        trackerCoreData?.colorHex = ColorMarshalling.serialize(color: color)
        trackerCoreData?.schedule = DayOfWeek.code(data.schedule)
        trackerCoreData?.category = categoryCoreData
        try context.save()
    }
    
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let trackerToDelete = try getTrackerCoreData(by: tracker.id) else { throw StoreError.deleteError }
        context.delete(trackerToDelete)
        try context.save()
    }
    
    func togglePin(for tracker: Tracker) throws {
        
        guard let trackerToToggle = try getTrackerCoreData(by: tracker.id) else { throw StoreError.pinError }
        trackerToToggle.isPinned.toggle()
        try context.save()
    }
    
    private var pinnedTrackers: [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        let trackers = fetchedObjects.compactMap { try? makeTracker(from: $0) }
        return trackers.filter({ $0.isPinned })
    }
    
    private var sections: [[Tracker]] {
        guard let sectionsCoreData = fetchedResultsController.sections else { return [] }
        var sections: [[Tracker]] = []
        
        if !pinnedTrackers.isEmpty {
            sections.append(pinnedTrackers)
        }
        
        sectionsCoreData.forEach { section in
            var sectionToAdd = [Tracker]()
            section.objects?.forEach({ object in
                
                guard
                    let trackerCoreData = object as? TrackerCoreData,
                    let tracker = try? makeTracker(from: trackerCoreData),
                    !pinnedTrackers.contains(where: { $0.id == tracker.id })
                else { return }
                
                
                let isCompleted = completedTrackers.contains { item in
                    let sameDay = Calendar.current.isDate(item.date, equalTo: currentDate, toGranularity: .day)
                    return sameDay && item.trackerId == tracker.id
                }
                
                
                if completeStatus == .complete, isCompleted {
                    sectionToAdd.append(tracker)
                }
                    
                if completeStatus == .uncomplete, !isCompleted {
                    sectionToAdd.append(tracker)
                }
                
                if completeStatus == .none {
                    sectionToAdd.append(tracker)
                }
                
                //sectionToAdd.append(tracker)
            })
            if !sectionToAdd.isEmpty {
                sections.append(sectionToAdd)
            }
        }
        return sections
    }
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
//    var numberOfSections: Int {
//        fetchedResultsController.sections?.count ?? 0
//    }
    var numberOfSections: Int {
        sections.count
    }
    
//    func numberOfRowsInSection(_ section: Int) -> Int {
//        fetchedResultsController.sections?[section].numberOfObjects ?? 0
//    }
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].count
    }
    
    
    func headerLabelInSection(_ section: Int) -> String? {
        
        if !pinnedTrackers.isEmpty && section == 0 {
            return "Trackers.pin".localized
        }
        guard let category = sections[section].first?.category else { return nil }
        return category.name
        
//        guard let trackerCoreData = fetchedResultsController.sections?[section].objects?.first as? TrackerCoreData else { return nil }
//        return trackerCoreData.category?.name ?? nil
    }
    
//    func tracker(at indexPath: IndexPath) -> Tracker? {
//        let trackerCoreData = fetchedResultsController.object(at: indexPath)
//        do {
//            let tracker = try makeTracker(from: trackerCoreData)
//            return tracker
//        } catch {
//            return nil
//        }
//    }
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let tracker = sections[indexPath.section][indexPath.item]
        return tracker
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
           let daysCount = coreData.records,
           let categoryCoreData = coreData.category,
           let category = try? trackerCategoryStore.makeCategory(from: categoryCoreData) {
            
            let color = ColorMarshalling.deserialize(hexString: colorHex)
            let scheduleString = coreData.schedule
            let schedule = DayOfWeek.decode(from: scheduleString)
            
            
            return Tracker(
                id: id,
                name: name,
                emoji: emoji,
                color: color!,
                category: category,
                isPinned: coreData.isPinned,
                daysCount: daysCount.count,
                schedule: schedule
            )
        } else {
            throw StoreError.decodeError
        }
    }
}


extension TrackerStore {
//    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
//        fetchedResultsController.fetchRequest.predicate = NSPredicate(
//            format: "%K == %@",
//            #keyPath(TrackerCoreData.trackerId), id.uuidString
//        )
//        try fetchedResultsController.performFetch()
//        return fetchedResultsController.fetchedObjects?.first
//    }
    
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        guard let tracker = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchTrackerError }
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
        return tracker
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

extension TrackerStore {
    enum StoreError: Error {
        case decodeError, fetchTrackerError, deleteError, pinError
    }
}





