//
//  WSManager.swift
//  Stonks
//
//  Created by Maxim Perehod on 22.02.2021.
//

import Foundation

// MARK: - недоделланый класс вебсокета
class WSManager {
    public static let shared = WSManager() // singletone 
    private init(){}
    
    private var dataArray = [Stock]()
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://mboum.com/api/v1/tr/trending?apikey=demo")!)
    

    public func connectToWebSocket() {
        webSocketTask.resume()
        webSocketTask.receive { result in
            switch result {
                case .failure(let error): print("\(error)")
                case .success(let data): print(data)
                
            }
            
            
        }
    }
}
