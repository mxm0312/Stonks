//
//  FavouriteViewController.swift
//  Stonks
//
//  Created by Maxim Perehod on 16.02.2021.
//

import UIKit

class FavouriteViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    
    var stonksFiltered = [Stock]() /* массив фильтрованных поисковой строкой акций*/
    var myFavouriteStocks = UserDefaults.standard.stringArray(forKey: "favourite") ?? [String]()
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var loader = Loader(APIKEY: "TNrz28kgIr62osfzv3h2VPuczfSHpIInoMpaD0i1tnp0YIZfmqc76Uc18XCF")
    var searchActive = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        overrideUserInterfaceStyle = .light
        searchBar.delegate = self
        tableView.rowHeight = 100
        
        
       for ticker in myFavouriteStocks {
            loader.loadInfoAboutStock(ticker: ticker, tableView: tableView)
        }
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
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
    
    // MARK: - нажатие на ячейку в tableView. Передаю в информацию о выбранной акции в DetailsViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stonk = Stock(symbol: stonks[indexPath.section].symbol, longName: stonks[indexPath.section].longName, price: stonks[indexPath.section].price, regularMarketChange: stonks[indexPath.section].regularMarketChange, regularMarketChangePercent: stonks[indexPath.section].regularMarketChangePercent)
        performSegue(withIdentifier: "fromFavSegue", sender: stonk)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromFavSegue" {
            if let vc = segue.destination as? DetailsViewController {
                if let stonk = sender as? Stock {
                    // передаю данные о выбранной акции в переменную stock в DetailsVC
                    vc.stock.symbol = stonk.symbol
                    vc.stock.longName = stonk.longName
                    vc.stock.price = stonk.price
                    vc.stock.regularMarketChange = stonk.regularMarketChange
                    vc.stock.regularMarketChangePercent = stonk.regularMarketChangePercent
                }
            }
        }
        
    }
    
    // MARK: - отоброжение ячейки с акцией
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favTableViewCell") as! TableViewCell
        
        
        // MARK: - В зависимости от флага searchActive пользователь видит фильтрованные или нефильтрованные поисковой строкой акции
        if searchActive == false {
            cell.roundView.layer.cornerRadius = 20
            cell.favButton.addTarget(self, action: #selector(addToFavourite(sender:)), for: .touchUpInside) // даем каждой кнопке
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
            if myFavouriteStocks.contains(stonks[indexPath.section].symbol ?? "") {
                cell.favButton.tintColor = UIColor.systemYellow
            } else {
                cell.favButton.tintColor = UIColor.gray
            }
            
            
            // делаю четные ячейки чуть серыми
            if indexPath.section % 2 != 0 {
                cell.roundView.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 247/255, alpha: 1)
            }
            
            
            cell.fullName.text = stonks[indexPath.section].longName
            let bookValue = stonks[indexPath.section].price ?? 9
            let regularChange = round((stonks[indexPath.section].regularMarketChange ?? 0)*100)/100
            let changePercent = round((stonks[indexPath.section].regularMarketChangePercent ?? 0)*100 )/100
            cell.price.text = "$" + String(bookValue)
            
            
            if regularChange < 0 {
                cell.change.textColor = UIColor.red
                cell.change.text = "-$" + String(regularChange*(-1)) + " (\(changePercent*(-1))%)"
            } else {
                cell.change.textColor = UIColor.systemGreen
                cell.change.text = "$" + String(regularChange) + " (\(changePercent)%)"
            }
            
        } else {
            
            cell.roundView.layer.cornerRadius = 20
            cell.favButton.addTarget(self, action: #selector(addToFavourite(sender:)), for: .touchUpInside) // даем каждой кнопке
            cell.favButton.tag = indexPath.section
            
            
            if (UIImage(named: stonksFiltered[indexPath.section].symbol ?? "") != nil) {
                cell.stockImage.image = UIImage(named: stonksFiltered[indexPath.section].symbol ?? "none")
            } else {
                cell.stockImage.image = UIImage(named: "none")
            }
            
            
            cell.stockImage.layer.cornerRadius = 15
            cell.stockImage.clipsToBounds = true
            cell.symbol.text = stonksFiltered[indexPath.section].symbol
            
            
            // делаю кнопку добавить в любимые активной, если акция уже добавлена у пользователя в любимык
            if myFavouriteStocks.contains(stonksFiltered[indexPath.section].symbol ?? "") {
                cell.favButton.tintColor = UIColor.systemYellow
            } else {
                cell.favButton.tintColor = UIColor.gray
            }
            
            
            // делаю четные ячейки чуть серыми
            if indexPath.section % 2 != 0 {
                cell.roundView.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 247/255, alpha: 1)
            }
            
            cell.fullName.text = stonksFiltered[indexPath.section].longName
            let bookValue = stonksFiltered[indexPath.section].price ?? 9
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
    
    @objc func addToFavourite(sender: UIButton) {
        
        if searchActive == false {
            
            if myFavouriteStocks.contains(stonks[sender.tag].symbol ?? "") {
                if let index = myFavouriteStocks.firstIndex(of: stonks[sender.tag].symbol ?? "") {
                    myFavouriteStocks.remove(at: index)
                }
                UserDefaults.standard.setValue(myFavouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.gray
            } else {
                myFavouriteStocks.append(stonks[sender.tag].symbol ?? "")
                UserDefaults.standard.setValue(myFavouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.systemYellow
            }

        } else {
            if myFavouriteStocks.contains(stonksFiltered[sender.tag].symbol ?? "") {
                if let index = myFavouriteStocks.firstIndex(of: stonksFiltered[sender.tag].symbol ?? "") {
                    myFavouriteStocks.remove(at: index)
                }
                UserDefaults.standard.setValue(myFavouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.gray
            } else {
                myFavouriteStocks.append(stonksFiltered[sender.tag].symbol ?? "")
                UserDefaults.standard.setValue(myFavouriteStocks, forKey: "favourite")
                sender.tintColor = UIColor.systemYellow
            }

        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        

        guard !searchText.isEmpty else {
                stonksFiltered = stonks
                tableView.reloadData()
                return // When no items are typed, load your array still

            }
        stonksFiltered = stonks.filter({$0.longName!.lowercased().prefix(searchText.count) == searchText.lowercased() || $0.symbol!.lowercased().prefix(searchText.count) == searchText.lowercased()})
        
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stonks.removeAll()
    }

    
}
