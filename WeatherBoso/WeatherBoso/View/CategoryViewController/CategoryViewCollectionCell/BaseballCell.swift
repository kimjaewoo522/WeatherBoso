//
//  BaseballCell.swift
//  WeatherBoso
//
//  Created by Sophie on 5/21/25.
//

import UIKit

class BaseballCell: UICollectionViewCell {
    
    static let id = "BaseballCell"
    
    let locabg: UIImageView = {
        let b = UIImageView()
        b.contentMode = .scaleAspectFill
        b.clipsToBounds = true
        b.layer.cornerRadius = 20
        return b
    }()
    
    let locaName: UILabel = {
        let n = UILabel()
        n.font = UIFont(name: "GmarketSansTTFMedium", size: 20)
        return n
    }()
    
    let tempLabel: UILabel = {
        let t = UILabel()
        t.font = UIFont(name: "GmarketSansTTFLight", size: 12)
        return t
    }()
    
    let statusLabel: UILabel = {
        let s = UILabel()
        s.font = UIFont(name: "GmarketSansTTFLight", size: 14)
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [locabg, locaName, tempLabel, statusLabel].forEach(
            {contentView.addSubview($0)})
        setConst()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConst() {
        
        locabg.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        locaName.snp.makeConstraints {
            $0.top.equalToSuperview().inset(11)
            $0.trailing.equalToSuperview().inset(9)
        }
        
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(locaName.snp.bottom).offset(5)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(14)
            $0.trailing.equalToSuperview().inset(9)
        }
    }
    
    /// 배열 전체 필요한 것이 아닌 값을 하나만 받아오도록
    ///  why? 컬렉션뷰는 인덱스패스 순서대로 호출되는 ..
    func setData(with location: StadiumModel) {
        
        locaName.text = location.stadiumName
        locabg.image = UIImage(named: location.teamLogo)
        tempLabel.text = location.temp ?? ""
        statusLabel.text = location.description ?? ""
    }
    
    
}
