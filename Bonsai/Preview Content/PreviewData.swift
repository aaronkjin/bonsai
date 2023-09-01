//
//  PreviewData.swift
//  Bonsai
//
//  Created by Aaron Jin on 8/30/23.
//

import Foundation

// First entry from the API to be called
var transactionPreviewData = Transaction(id: 1, date: "02/20/2022", institution: "Desjardins", account: "Visa Desjardins", merchant: "Apple", amount: 11.49, type: "debit", categoryId: 801, category: "Software", isPending: false, isTransfer: false, isExpense: true, isEdited: false)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 10)
