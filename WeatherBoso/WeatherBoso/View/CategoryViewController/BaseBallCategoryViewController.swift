//
//  BaseBallCategoryView.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BaseBallCategoryViewController: UIViewController{
    
    private let searchBar = SearchBar()
    
    private let disposeBag = DisposeBag()
    lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )
    
    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  야구보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [collection, searchBar, customNavBar].forEach { view.addSubview($0) }
        customNavBar.addSubview(backButton)
        view.backgroundColor = .white
        setConst()
        
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setConst() {
        
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(56)
        }
        
        collection.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(27)
            $0.leading.trailing.equalToSuperview().inset(23)
        }
        
    }
    
    private func collectionSet() -> UICollectionViewCompositionalLayout {
        
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

