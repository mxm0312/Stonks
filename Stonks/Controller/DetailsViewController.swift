//
//  DetailsViewController.swift
//  Stonks
//
//  Created by Maxim Perehod on 22.02.2021.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var stock = Stock(symbol: "", longName: "", price: 0, regularMarketChange: 0, regularMarketChangePercent: 0)
    
    @IBOutlet var tickerLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var changeLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        
        tickerLabel.text = stock.symbol
        fullNameLabel.text = stock.longName
        
        let regularChange = round((stock.regularMarketChange!)*100)/100
        let changePercent = round((stock.regularMarketChangePercent!)*100 )/100
        
        priceLabel.text = "$"+String(stock.price!)
        if stock.regularMarketChange! < 0 {
            changeLabel.text = "-$" + String((-1)*regularChange) + " (\((-1)*changePercent)%)"
            changeLabel.textColor = UIColor.systemRed
        } else {
            changeLabel.text = "+$" + String(regularChange) + " (\(changePercent)%)"
            changeLabel.textColor = UIColor.systemGreen
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    
}
