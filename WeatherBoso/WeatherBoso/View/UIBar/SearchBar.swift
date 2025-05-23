//
//  SearchBar.swift
//  WeatherBoso
//
//  Created by Sophie on 5/21/25.
//

import UIKit
import SnapKit

class SearchBar: UISearchBar {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        backgroundColor = .white
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.placeholder = "어디 타소?"
        self.setImage(UIImage(systemName: "magnifyingglass"),
                      for: .search, state: .normal)
       
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.font = UIFont(
            name: "GmarketSansTTFLight", size: 20)
        searchTextField.backgroundColor = UIColor.white
        
        
    }
}
