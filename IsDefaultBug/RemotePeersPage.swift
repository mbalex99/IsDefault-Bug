//
//  RemotePeersPage.swift
//  IsDefaultBug
//
//  Created by Maximilian Alexander on 9/30/21.
//

import SwiftUI
import DittoSwift
import Combine
import CombineDitto

struct RemotePeersPage: View {

    class ViewModel: ObservableObject {
        @Published var peers: [DittoRemotePeer] = []
        var cancellables = Set<AnyCancellable>()
        init() {
            DittoManager.shared
                .ditto
                .remotePeersPublisher()
                .assign(to: \.peers, on: self)
                .store(in: &cancellables)
        }
    }

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.peers) { peer in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(peer.deviceName)
                    }
                }
            }
            .navigationTitle("Remote Peers")
        }
    }
}

struct RemotePeersPage_Previews: PreviewProvider {
    static var previews: some View {
        RemotePeersPage()
    }
}
