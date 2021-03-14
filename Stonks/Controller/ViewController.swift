//
//  ViewController.swift
//  Stonks
//
//  Created by Maxim Perehod on 16.02.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate {
    

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var stonks = [Stock]()
    var stonksFiltered = [Stock]() /* массив фильтрованных поисковой строкой акций */
    var searchActive = false // флаг для searchBar
    
    let APIKEY = "TNrz28kgIr62osfzv3h2VPuczfSHpIInoMpaD0i1tnp0YIZfmqc76Uc18XCF"
    
    var favouriteStocks = UserDefaults.standard.stringArray(forKey: "favourite") ?? [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(favouriteStocks)
        overrideUserInterfaceStyle = .light
        searchBar.delegate = self
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        // MARK:- Вызов метода загрузки акций в другой нити исполнения
        DispatchQueue.global(qos: .utility).async {
            self.loadTrandStocks(url: "https://mboum.com/api/v1/tr/trending?apikey=\(self.APIKEY)")
//            self.loadInfoAboutStock(ticker: "AAPL")
//            self.loadInfoAboutStock(ticker: "F")
        }
    }
    
    // MARK: - tableView stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchActive {
            return stonksFiltered.count
        } else {
            return stonks.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    // MARK: - нажатие на ячейку в tableView. Передаю в информацию о выбранной акции в DetailsViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stonk = Stock(symbol: stonks[indexPath.section].symbol ?? "", longName: stonks[indexPath.section].longName ?? "", bookValue: stonks[indexPath.section].bookValue ?? 0, regularMarketChange: stonks[indexPath.section].regularMarketChange ?? 0, regularMarketChangePercent: stonks[indexPath.section].regularMarketChangePercent ?? 0)
        performSegue(withIdentifier: "fromMainSegue", sender: stonk)
        
    }
    // MARK: - подготовка DetailsViewController в котором будет информация об акции
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMainSegue" {
            if let vc = segue.destination as? DetailsViewController {
                if let stonk = sender as? Stock {
                    // передаю данные о выбранной акции в переменную stock в DetailsVC
                    vc.stock.symbol = stonk.symbol
                    vc.stock.longName = stonk.longName
                    vc.stock.bookValue = stonk.bookValue
                    vc.stock.regularMarketChange = stonk.regularMarketChange
                    vc.stock.regularMarketChangePercent = stonk.regularMarketChangePercent
                }
            }
        }
    }
    
    // Установка отступа между ячейками в tableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! TableViewCell
        
        
        // MARK: - В зависимости от флага searchActive пользователь видит фильтрованные или нефильтрованные поисковой строкой акции
        if searchActive == false {
            cell.roundView.layer.cornerRadius = 20
            cell.favButton.addTarget(self, action: #selector(addToFavourite(sender:)), for: .touchUpInside) // добавляем таргет для добавления в избранные
            cell.favButton.tag = indexPath.section
            if (UIImage(named: stonks[indexPath.section].symbol ?? "") != nil) {
                cell.stockImage.image = UIImage(named: stonks[indexPath.section].symbol ?? "none")
            } else {
                cell.stockImage.image = UIImage(named: "none")
            }
            cell.stockImage.layer.cornerRadius = 15
            cell.stockImage.clipsToBounds = true
            cell.symbol.text = stonks[indexPath.section].symbol
            // делаю кнопку добавить в любимые активной, если акция уже добавлена у пользователя в любимык
            if favouriteStocks.contains(stonks[indexPath.section].symbol ?? "") {
                cell.favButton.tintColor = UIColor.systemYellow
            } else {
                cell.favButton.tintColor = UIColor.gray
            }
            // делаю четные ячейки чуть серыми
            if indexPath.section % 2 == 0 {
                cell.roundView.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 247/255, alpha: 1)
            }
            cell.fullName.text = stonks[indexPath.section].longName
            let bookValue = stonks[indexPath.section].bookValue ?? 0
            let regularChange = round((stonks[indexPath.section].regularMarketChange ?? 0)*100)/100
            let changePercent = round((stonks[indexPath.section].regularMarketChangePercent ?? 0)*100 )/100
            cell.price.text = "$" + String(bookValue)
            if regularChange < 0 {
                cell.change.textColor = UIColor.red
                cell.change.text = "-$" + String(regularChange*(-1)) + " (\(changePercent*(-1))%)"
            } else {
                cell.change.textColor = UIColor.systemGreen
                cell.change.text = "+$" + String(regularChange) + " (\(changePercent)%)"
            }
        } else {
            cell.roundView.layer.cornerRadius = 20
            cell.favButton.addTarget(self, action: #selector(addToFavourite(sender:)), for: .touchUpInside) // добавляем таргет для добавления в избранные
            cell.favButton.tag = indexPath.section
            if (UIImage(named: stonks[indexPath.section].symbol ?? "") != nil) {
                cell.stockImage.image = UIImage(named: stonks[indexPath.section].symbol ?? "none")
            } else {
                cell.stockImage.image = UIImage(named: "none")
            }
            cell.stockImage.layer.cornerRadius = 15
            cell.stockImage.clipsToBounds = true
            cell.symbol.text = stonksFiltered[indexPath.section].symbol
            // делаю кнопку добавить в любимые активной, если акция уже добавлена у пользователя в любимык
            if favouriteStocks.contains(stonksFiltered[indexPath.section].symbol ?? "") {
                cell.favButton.tintColor = UIColor.systemYellow
            } else {
                cell.favButton.tintColor = UIColor.gray
            }
            // делаю четные ячейки чуть серыми
            if indexPath.section % 2 == 0 {
                cell.roundView.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 247/255, alpha: 1)
            }
            cell.fullName.text = stonksFiltered[indexPath.section].longName
            let bookValue = stonksFiltered[indexPath.section].bookValue ?? 9
            let regularChange = round((stonksFiltered[indexPath.section].regularMarketChange ?? 0)*100)/100
            let changePercent = round((stonksFiltered[indexPath.section].regularMarketChangePercent ?? 0)*100 )/100
            cell.price.text = "$" + String(bookValue)
            if regularChange < 0 {
                cell.change.textColor = UIColor.red
                cell.change.text = "-$" + String(regularChange*(-1)) + " (\(changePercent*(-1))%)"
            } else {
                cell.change.textColor = UIColor.systemGreen
                cell.change.text = "$" + String(regularChange) + " (\(changePercent)%)"
            }
        }
        
        
        return cell
        
    }
    
    // Добавить в избранные
    @objc func addToFavourite(sender: UIButton) {
        
        if searchActive == false {
            if favouriteStocks.contains(stonks[sender.tag].symbol ?? "") {
                if let index = favouriteStocks.firstIndex(of: stonks[sender.tag].symbol ?? "") {
                    favouriteStocks.remove(at: index)
                }
                UserDefaults.standard.setValue(favouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.gray
            } else {
                favouriteStocks.append(stonks[sender.tag].symbol ?? "")
                UserDefaults.standard.setValue(favouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.systemYellow
            }

        } else {
            if favouriteStocks.contains(stonksFiltered[sender.tag].symbol ?? "") {
                if let index = favouriteStocks.firstIndex(of: stonksFiltered[sender.tag].symbol ?? "") {
                    favouriteStocks.remove(at: index)
                }
                UserDefaults.standard.setValue(favouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.gray
            } else {
                favouriteStocks.append(stonksFiltered[sender.tag].symbol ?? "")
                UserDefaults.standard.setValue(favouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.systemYellow
            }
        }
    }
    
    // убираю клавиатуру по нажатию на return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - метод, получающий трендовые тикеры и потом для каждого полученного трендового тикера вызывает метод loadInfoAboutStock
      func loadTrandStocks(url: String) {
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
                                if count != 3 {
                                    self.loadInfoAboutStock(ticker: ticker)
                                    count += 1
                                } else {
                                    break
                                }
                              }
                          }
                      }
                  } catch  {
                      print("балин")
                  }
              }
          }.resume()
      }
      
      // MARK: - метод, грузящий информацию об акции тикер которой передается в качестве параметра функции
      func loadInfoAboutStock(ticker: String) {
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
                                  stock.bookValue = stockDict["ask"] as? Double ?? 0
                                  stock.regularMarketChange = stockDict["regularMarketChange"] as? Double ?? 0
                                  stock.regularMarketChangePercent = stockDict["regularMarketChangePercent"] as? Double ?? 0
                                  self.stonks.append(stock)
                                  DispatchQueue.main.async {
                                      self.tableView.reloadData()
                                  }
                              }
                          }
                      }
          
                  } catch {
                     
                  }
          
              } else {
                  print(error)
                  print(data)
              }
          }.resume()
      }
    
    // MARK: - Поиск по тикеру или названию
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        

        guard !searchText.isEmpty else {
            stonksFiltered = stonks
            tableView.reloadData()
            return

        }
        // фильтруем акции по префиксу тикера или полного имени
        stonksFiltered = stonks.filter({$0.longName!.lowercased().prefix(searchText.count) == searchText.lowercased() || $0.symbol!.lowercased().prefix(searchText.count) == searchText.lowercased()})
        
        // меняеем флаг
        if (stonksFiltered.count == 0) {
            let alert = UIAlertController(title: "Упс", message: "Такой акции не нашлось", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    
    // убрать клавиатуру по нажатию на Searck на клавиатуре
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

