//
//  DittoManager.swift
//  IsDefaultBug
//
//  Created by Maximilian Alexander on 9/30/21.
//

import DittoSwift
import Combine
import CombineDitto

class DittoManager {

    static let shared = DittoManager()

    let ditto: Ditto

    var isSyncEnabled = CurrentValueSubject<Bool, Never>(false)

    init() {
        ditto = Ditto(identity: DittoIdentity.development(appID: "isdefaultbug"))
        try! ditto.setLicenseToken("o2d1c2VyX2lkdFVzZXI6IG1heEBkaXR0by5saXZlZmV4cGlyeXgYMjAyMS0xMC0zMVQwMToyODo0OC42MDBaaXNpZ25hdHVyZXhYckp5bGdOT09ReGkwU2d4elZnRFRFcUsvbnMvU1JSdURtNnJVZzlLcjZOMDBWbkpvN2pZdzhWNXZQa3ZnK2MvbFlXTVp5TG4vSkxoWitXQjdLdEhGMmc9PQ==")
        startSync()
    }

    func startSync() {
        do {
            try ditto.tryStartSync()
            isSyncEnabled.send(true)
        } catch(let err) {
            fatalError(err.localizedDescription)
        }
    }

    func stopSync() {
        ditto.stopSync()
        isSyncEnabled.send(false)
    }

    var car: AnyPublisher<DittoDocument?, Never> {
        return ditto.store["cars"].findByID("honda").publisher()
            .map{ $0.document }
            .eraseToAnyPublisher()
    }

}
