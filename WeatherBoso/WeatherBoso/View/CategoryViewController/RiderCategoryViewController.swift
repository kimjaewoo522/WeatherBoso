//
//  RiderCategoryView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class RiderCategoryViewController: UIViewController{
    
    let searchBar = SearchBar()
    
    lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )
    
    let arrow: UIButton = {
        let a = UIButton()
        a.setImage(UIImage(systemName: "arrow.right.circle",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        a.tintColor = .black
        return a
    }()
    
    let bosoTitle: UILabel = {
        let t = UILabel()
        t.text = "낚아보소"
        t.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [collection, arrow, bosoTitle, searchBar].forEach({view.addSubview($0)})
        
        view.backgroundColor = .white
        setConst()
        
    }
    
    func setConst() {
        
        arrow.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(-17)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        bosoTitle.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(-17)
            $0.leading.equalTo(arrow.snp.trailing).offset(15)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(bosoTitle.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(56)
        }
        
        collection.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(27)
            $0.leading.trailing.equalToSuperview().inset(23)
        }
          
    }
    
    func collectionSet() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(
            top: 0, leading: 0,
            bottom: 23, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(90)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
}

