//
//  FirebaseTesters.swift
//  Fastlane-UI
//
//  Created by softwave on 24/11/23.
//

import SwiftUI

extension Firebase {
    struct Testers: View {
        
        private let manager = TestersManager()
        
        @State private var rows = [TextFieldRow.Model]()
        
        var body: some View {
            ListView(
                title: "Testers",
                gitMessage: "Update firebase testers",
                isEnableButtonHidden: false,
                rowsGetter: self,
                isCommitActionDisabled: { models in
                    models.elementsEqual(to: manager.current)
                },
                commit: commit,
                rows: $rows)
        }
        
        private func commit() {
            do {
                try manager.apply(models: rows.models)
            } catch {
                print(error)
            }
        }
    }
}

extension Firebase.Testers: TextFieldRowsGetter {
    var readRows: [TextFieldRow.Model]  {
        (try? manager.read())?.rows ?? []
    }
    var currentRows: [TextFieldRow.Model] {
        manager.current.rows
    }
}

private class TestersManager {
    
    @Default(\.projectFolder) private var projectFolder: String
    
    private(set) var current = [Model]()
    
    private var path: String {
        projectFolder + "/" + firebaseTestersPathComponent
    }
    
    init() {
        let _ = try? read()
    }
    
    func apply(models: [Model]) throws {
        let stored = try read()
        let uni = models.uniqued()
        if stored != uni {
            try store(models: uni)
        }
    }

    func read() throws -> [Model] {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let models = try JSONDecoder().decode([Model].self, from: data)
        current = models
        return models
    }
    
    private func store(models: [Model]) throws {
        
        let url = URL(fileURLWithPath: path)
        
        func save(data: Data) throws {
            try data.write(to: url)
        }
        
        try save(data: Data())
        current.removeAll()
        let data = try JSONEncoder().encode(models)
        try save(data: data)
        current = models
    }
}

private extension TestersManager {
    struct Model {
        let email: String
        let enabled: Bool
    }
}

extension TestersManager.Model: Hashable {}

extension TestersManager.Model: Codable {}

private extension Array where Element == TextFieldRow.Model {
    func elementsEqual(to rows: [TestersManager.Model]) -> Bool {
        elementsEqual(rows) { (row, model) -> Bool in
            row.enable == model.enabled && row.text == model.email
        }
    }
    
    var models: [TestersManager.Model] {
        map {
            TestersManager.Model(
                email: $0.text,
                enabled: $0.enable
            )
        }
    }
}

private extension Array where Element == TestersManager.Model {
    var rows: [TextFieldRow.Model] {
        map {
            TextFieldRow.Model(
                text: $0.email,
                enable: $0.enabled
            )
        }
    }
}
