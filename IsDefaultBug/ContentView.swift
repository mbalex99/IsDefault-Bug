//
//  ContentView.swift
//  IsDefaultBug
//
//  Created by Maximilian Alexander on 9/30/21.
//

import SwiftUI
import DittoSwift
import CombineDitto
import Combine
import Fakery

struct ContentView: View {

    class ViewModel: ObservableObject {
        @Published var isShowingPeersPage = false
        @Published var car: DittoDocument?

        let faker = Faker()
        var cancellables = Set<AnyCancellable>()

        init() {
            DittoManager.shared
                .ditto.store["cars"].findByID("honda").publisher()
                .map{ $0.document }
                .assign(to: \.car, on: self)
                .store(in: &cancellables)

            // bootstrap it with an
            attemptInsertDefault()
        }

        func showPeersPage() {
            isShowingPeersPage = true
        }

        func randomizeColor() {
            DittoManager.shared.ditto.store["cars"].findByID("honda")
                .update { mutableDoc in
                    mutableDoc?["color"].set(self.faker.lorem.word())
                }
        }

        func randomizeMileage() {
            DittoManager.shared.ditto.store["cars"].findByID("honda")
                .update { mutableDoc in
                    mutableDoc?["mileage"].set(Float.random(in: 0..<1000000))
                }
        }

        func attemptInsertDefault() {
            try! DittoManager.shared.ditto.store["cars"].insert([
                "_id": "honda",
                "color": "red",
                "mileage": 1000
            ], isDefault: true)
        }
    }

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let car = viewModel.car {
                    Text("_id: \(car["_id"].stringValue)")
                    Text("color: \(car["color"].string ?? "nil")")
                    if let mileage = car["mileage"].float {
                        Text("mileage: \(mileage)")
                    } else {
                        Text("mileage: nil")
                    }

                } else {
                    Text("No car document, no value, no id")
                }
            }
            .navigationTitle("IsDefault Bug")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Remote Peers") {
                        viewModel.showPeersPage()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("🔄 Color") {
                        viewModel.randomizeColor()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("🔄 Mileage") {
                        viewModel.randomizeMileage()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Insert Default") {
                        viewModel.attemptInsertDefault()
                    }
                }
                
            }
            .sheet(isPresented: $viewModel.isShowingPeersPage) {
                RemotePeersPage()
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
