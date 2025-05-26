//
//  RunnerCell.swift
//  WeatherBoso
//
//  Created by Sophie on 5/21/25.
//

import UIKit

class RunnerCell: UICollectionViewCell {
    
    static let id = "RunnerCell"
    
    let locabg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let locaName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GmarketSansTTFMedium", size: 20)
        return label
    }()
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GmarketSansTTFLight", size: 12)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GmarketSansTTFLight", size: 14)
        return label
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
            $0.height.greaterThanOrEqualTo(90)

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
    
    func configure(with runningSpot: RunningSpot) {
        locabg.image = UIImage(named: runningSpot.imageName)
        locaName.text = runningSpot.name
        tempLabel.text = runningSpot.temperature
        statusLabel.text = runningSpot.weatherStatus
    }
    
    
    
}

