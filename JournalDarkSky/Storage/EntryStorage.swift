//
//  EntryStorage.swift
//  JournalDarkSky
//
//  Created by Jared Warren on 1/22/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

class EntryStorage {
    
    static private let entriesFileName = "entries"
    
    static func saveEntries(entires: [Entry]) {
        do {
            let data = try JSONEncoder().encode(entires)
            JSONRepository.saveData(data: data, name: entriesFileName)
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    static func loadEntries() -> [Entry] {
        
        do {
            guard let data = JSONRepository.loadData(name: entriesFileName) else { return [] }
            let entries = try JSONDecoder().decode([Entry].self, from: data)
            return entries
        } catch {
            print(error, error.localizedDescription)
            return []
        }
    }
}
