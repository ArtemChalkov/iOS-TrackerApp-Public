//
//  TrackerRecordStore.swift
//  Tracker
//


import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords(_ records: Set<TrackerRecord>)
}

final class TrackerRecordStore {
    
    // MARK: - Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    
    //MARK: Services
    private let store = Store.shared
    private var context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    //MARK: Data
    private var completedTrackers: Set<TrackerRecord> = []

    init() {
        self.context = store.persistentContainer.viewContext
    }
}

extension TrackerRecordStore {
    
    //MARK: CREATE
    //Добавление нового трекер рекорда,
    func add(_ newRecord: TrackerRecord) throws {
        
        //Ищем трекер по id trackerRecord
        let trackerCoreData = try trackerStore.getTrackerCoreData(by: newRecord.trackerId)
        
        let TrackerRecordCoreData = TrackerRecordCoreData(context: context)
        
        TrackerRecordCoreData.recordId = newRecord.id.uuidString
        TrackerRecordCoreData.date = newRecord.date
        TrackerRecordCoreData.tracker = trackerCoreData
        
        try context.save()
        completedTrackers.insert(newRecord)
        
        delegate?.didUpdateRecords(completedTrackers)
    }
    
    //MARK: REMOVE
    func remove(_ record: TrackerRecord) throws {
        
        //Все рекорды
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        //Фильтр по id рекорда
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.recordId), record.id.uuidString
        )
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
        try context.save()
        completedTrackers.remove(record)
        delegate?.didUpdateRecords(completedTrackers)
    }
    
    //MARK: READ
    func loadCompletedTrackers(by date: Date) throws {

        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        
        //Начало дня и конец дня
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)

        request.predicate = NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate!, endDate!])
        let recordsCoreData = try context.fetch(request)
        //Parsing
        let records = try recordsCoreData.map { try makeTrackerRecord(from: $0) }
        completedTrackers = Set(records)
        
        delegate?.didUpdateRecords(completedTrackers)
    }
    
    func loadCompletedTrackers() throws -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let recordsCoreData = try context.fetch(request)
        let records = try recordsCoreData.map { try makeTrackerRecord(from: $0) }
        return records
    }
    
    //MARK: PARSE
    private func makeTrackerRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
    
        print(coreData.recordId)
        print(coreData.date)
        print(coreData.tracker)
        
        if let idString = coreData.recordId,
           let id = UUID(uuidString: idString),
           let date = coreData.date,
           let trackerCoreData = coreData.tracker,
           let tracker = try? trackerStore.makeTracker(from: trackerCoreData) {
            
            return TrackerRecord(id: id, trackerId: tracker.id, date: date)
        } else {
            throw StoreError.decodeError
        }
    }
}
