//
//  Loader.swift
//  Stonks
//
//  Created by Maxim Perehod on 17.03.2021.
//

import UIKit

// MARK: - класс через который будет осуществлятся работа с API mboum.com
class Loader {
    
    var APIKEY: String // наш ключ
    
    init(APIKEY: String) {
        self.APIKEY = APIKEY
    }
    
    // MARK: - метод, получающий трендовые тикеры и потом для каждого полученного трендового тикера вызывает метод loadInfoAboutStock
    /* Параметры функции: ссылка; tableView, который будем обновлять; количество трендовых акций, которое будем грузить */
    func loadTrandStocks(url: String, tableView: UITableView, amount: Int) {
          // MARK: - запрос на загрузку трендовых акций
          URLSession.shared.dataTask(with: NSURL(string: url) as! URL) {
              data, response, error in
              if error == nil && data != nil {
                
                  do {
                      let json = try JSONSerialization.jsonObject(with: data!, options: [])
              
                      if let dict = json as? [[String: Any]] {
                          if let tickers = dict[0]["quotes"] as? [String] {
                              var count = 0 // переменная, чтобы ограничить количество вызово функции loadInfoAbputStock
                              for ticker in tickers {
                                // MARK: - еще один запрос на закгрузку информации о стоимости акции
                                if count != amount {
                                    self.loadInfoAboutStock(ticker: ticker, tableView: tableView)
                                    count += 1
                                } else {
                                    break
                                }
                              }
                          }
                      } else {
                        // если что-то идет не так просто гружу акции по демо ключу
                        
                        self.APIKEY = "demo"
                        self.loadInfoAboutStock(ticker: "AAPL", tableView: tableView)
                        self.loadInfoAboutStock(ticker: "F", tableView: tableView)
                      }
                  } catch  {
                    // если что-то идет не так просто гружу акции по демо ключу
                    
                    self.APIKEY = "demo"
                    self.loadInfoAboutStock(ticker: "AAPL", tableView: tableView)
                    self.loadInfoAboutStock(ticker: "F", tableView: tableView)
                  }
              } else {
                // если что-то идет не так просто гружу акции по демо ключу
               
                self.APIKEY = "demo"
                self.loadInfoAboutStock(ticker: "AAPL", tableView: tableView)
                self.loadInfoAboutStock(ticker: "F", tableView: tableView)
              }
          }.resume()
      }
      
      // MARK: - метод, грузящий информацию об акции тикер которой передается в качестве параметра функции
    func loadInfoAboutStock(ticker: String, tableView: UITableView) {
        guard NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=\(ticker)&apikey=\(self.APIKEY)") != nil else {
            return
        }
          URLSession.shared.dataTask(with: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=\(ticker)&apikey=\(self.APIKEY)") as! URL) {
                  (data, response, error) in
          
              if error == nil && data != nil {
          
                  do {
                      let json = try JSONSerialization.jsonObject(with: data!, options: [])
                      if let dict = json as? [[String: Any]] {
                          // MARK: - Загрузка каждой отдельной i акции в массив акций в виде структуры Stock
                          for i in dict {
                              if let stockDict = i as? [String: Any] {
                                  var stock = Stock()
                                  stock.symbol = stockDict["symbol"] as? String ?? ""
                                  stock.longName = stockDict["longName"] as? String ?? ""
                                  stock.price = stockDict["ask"] as? Double ?? 0
                                  stock.regularMarketChange = stockDict["regularMarketChange"] as? Double ?? 0
                                  stock.regularMarketChangePercent = stockDict["regularMarketChangePercent"] as? Double ?? 0
                                  stonks.append(stock)
                                  DispatchQueue.main.async {
                                      tableView.reloadData()
                                  }
                              }
                          }
                      } else {
                        // если что-то идет не так грузим акции по демо ключу
                        self.APIKEY = "demo"
                        self.loadInfoAboutStock(ticker: ticker, tableView: tableView)
                      }
          
                  } catch {
                    self.APIKEY = "demo"
                    self.loadInfoAboutStock(ticker: ticker, tableView: tableView)
                  }
          
              } else {
                
                self.APIKEY = "demo"
                self.loadInfoAboutStock(ticker: ticker, tableView: tableView)
                
              }
          }.resume()
      }
}
