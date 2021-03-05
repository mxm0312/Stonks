//
//  StockModel.swift
//  Stonks
//
//  Created by Maxim Perehod on 16.02.2021.
//

import Foundation

// MARK: - Структура акции
struct Stock {
    var symbol: String?
    var longName: String?
    var bookValue: Double?
    var regularMarketChange: Double?
    var regularMarketChangePercent: Double?
}
