//
//  SurferCell.swift
//  WeatherBoso
//
//  Created by Sophie on 5/21/25.
//

import UIKit

class SurferCell: UICollectionViewCell {
    
    static let id = "AnglerCell"
    
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
    
    
    
}

