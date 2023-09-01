//
//  BonsaiApp.swift
//  Bonsai
//
//  Created by Aaron Jin on 8/24/23.
//

import SwiftUI

@main
struct BonsaiApp: App {
    // @StateObject: follows the life cycle of the app
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionListVM)
        }
    }
}
