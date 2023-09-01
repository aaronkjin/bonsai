//
//  TransactionListViewModel.swift
//  Bonsai
//
//  Created by Aaron Jin on 8/30/23.
//

import Foundation
import Combine
import Collections // For the OrderedDictionary data structure

// Good practice to make a typealias for a data type to make it reusable and easy to refer to
typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)]

/* Fetches a list of transactions from a remote JSON API using Combine framework.
 *
 * This function constructs a URL to the JSON data source, initiates a network request, and
 * handles the async response using Combine publishers. It checks for valid HTTP responses,
 * decodes the received JSON data intro an array of Transaction objects, and updates the
 * ViewModel's transactions property. UI updates are handled on the main thread. Any errors
 * or successful completion of the network request are logged. The subscription to the publisher
 * is managed to prevent memory leaks.
 */
final class TransactionListViewModel: ObservableObject {
    // ObservableObject is part of the Combine framework that turns any object into a publisher
    // and will notify its subscribers of its state changes so that they can refresh their views
    
    // @Published sends notifications to the subscribers whenever its value has changed
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        // Mock data that I found on this website
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
            print("Invalid URL")
            return
        }
        
        // Initiate a network request and create a publisher for the data task
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    // Dump is like print, but in a more readable format (good for logging objects)
                    dump(response)
                    
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            // Use decode to convert JSON data into an array of Transaction objects
            .decode(type: [Transaction].self, decoder: JSONDecoder())
        
            // Switch to the main thread to handle UI updates
            .receive(on: DispatchQueue.main)
        
            // Sink subscribes to publisher events
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching transactions: ", error.localizedDescription)
                case .finished:
                    print("Finished fetching transactions")
                }
            // Weak: prevents memory leaks as it can release self from memory when necessary
            } receiveValue: { [weak self] result in
                self?.transactions = result
            }
            // Store the subscription in the cancellables set to manage its lifecycle
            .store(in: &cancellables)
    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        // Ensure that the transactions array is not empty before proceeding
        guard !transactions.isEmpty else { return [:] }
        
        let groupedTransactions = TransactionGroup(grouping: transactions) { $0.month }
        
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        print("accumulateTransactions")
        guard !transactions.isEmpty else { return [] }
        
        let today = "02/17/2022".dateParsed() // Date()
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        print("dateInterval", dateInterval)
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        // 60 secs x 60 mins x 24 hrs
        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter { $0.dateParsed == date && $0.isExpense }
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount }  // signedAmount is negative, making total a positive
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            cumulativeSum.append((date.formatted(), sum))
            print(date.formatted(), "dailyTotal: ", dailyTotal, "sum: ", sum)
        }
        
        return cumulativeSum
    }
}
