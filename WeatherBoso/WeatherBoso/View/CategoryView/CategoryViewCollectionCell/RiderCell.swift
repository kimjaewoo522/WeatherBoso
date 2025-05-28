import UIKit
import SnapKit

class RiderCell: UICollectionViewCell {

    static let id = "RiderCell"

    let locabg: UIImageView = {
        let b = UIImageView()
        b.contentMode = .scaleToFill
        b.clipsToBounds = true
        b.layer.cornerRadius = 16
        return b
    }()

    private let overlayView: UIView = {
        let v = UIView()
        
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    let locaName: UILabel = {
        let n = UILabel()
        n.textAlignment = .right
        n.font = UIFont(name: "GmarketSansTTFMedium", size: 18)
        n.textColor = .black
        return n
    }()

    let tempLabel: UILabel = {
        let t = UILabel()
        t.textAlignment = .right
        t.font = UIFont(name: "GmarketSansTTFLight", size: 14)
        t.textColor = .black
        return t
    }()

    let statusLabel: UILabel = {
        let s = UILabel()
        s.textAlignment = .right
        s.font = UIFont(name: "GmarketSansTTFLight", size: 14)
        s.textColor = .black
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(locabg)
        locabg.addSubview(overlayView)
        [locaName, tempLabel, statusLabel].forEach { overlayView.addSubview($0) }
    }

    private func setupConstraints() {
        locabg.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        locaName.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(16)
        }

        tempLabel.snp.makeConstraints {
            $0.top.equalTo(locaName.snp.bottom).offset(4)
            $0.trailing.equalTo(locaName.snp.trailing)
        }

        statusLabel.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(4)
            $0.trailing.equalTo(tempLabel.snp.trailing)
        }
    }

        func configure(with model: LocationWeatherModel, weather: WeatherEntry?) {
            locabg.image = UIImage(named: model.imageName)
            locaName.text = model.name
            
            if let weather = weather {
                tempLabel.text = "\(Int(weather.main.temp))℃"
                statusLabel.text = weather.weather.first?.description ?? "정보 없음"
            } else {
                tempLabel.text = "-"
                statusLabel.text = "로딩 중"
            }
        }
    }
