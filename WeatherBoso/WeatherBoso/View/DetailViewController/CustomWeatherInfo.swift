import UIKit
import SnapKit

// 날씨 정보를 담는 단순한 데이터 모델 (제목 + 값)
struct WeatherData {
    let title: String
    let value: String
}

struct TimeWeatherInfo {
    let time: String
    let image: String
    let value: String
}

// 공통 UI 컴포넌트: 타이틀과 날씨 정보를 간단하게 표시하는 뷰
// 상단에 타이틀, 위치, 상태, 온도
// 하단에 날씨 정보들을 2개씩 묶어서 자동 배치
final class CustomWeatherInfoView: UIView {
    
    private let titleLabel = UILabel()
    private let locationStatusLabel = UILabel()
    private let tempLabel = UILabel()
    private let imageView = UIImageView()
    private let headerStack = UIStackView()
    private let largeStack = UIStackView()
    private let timeStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
    }
    
    // 외부에서 타이틀 색상 변경 가능
    func setImageTC(_ imageName: String,_ color: UIColor) {
        titleLabel.textColor = color
        imageView.image = UIImage(named: imageName)
    }
    
    private func setupUI() {
        // 스택 방향: 세로
        headerStack.axis = .vertical
        headerStack.spacing = 10
        
        largeStack.axis = .vertical
        largeStack.spacing = 16
        largeStack.alignment = .fill
        
        timeStack.axis = .horizontal
        timeStack.alignment = .center
        timeStack.distribution = .fillEqually //균등하게 나눠주기
        
        // 뷰에 스택뷰들을 추가
        addSubview(headerStack)
        addSubview(largeStack)
        addSubview(imageView)
        addSubview(timeStack)
        // 라벨 스타일 지정
        imageView.contentMode = .scaleAspectFit
        
//        titleLabel.font = .boldSystemFont(ofSize: 58)
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 58)

        locationStatusLabel.font = .systemFont(ofSize: 16)
        locationStatusLabel.textColor = .darkGray
        
        tempLabel.font = .systemFont(ofSize: 50)
    }
    
    private func setupLayout() {
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(150)
            $0.trailing.equalToSuperview().inset(30)
            //            $0.leading.equalToSuperview().inset(
            $0.width.height.equalTo(200)
        }
        
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        largeStack.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(200) // 상단 스택과 간격
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        timeStack.snp.makeConstraints {
            $0.top.equalTo(largeStack.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100) //
            $0.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
    
    // 상단 헤더뷰 설정
    func makeHeaderStack(title: String, location: String, temperature: String, status: String) {
        titleLabel.text = title
        locationStatusLabel.text = "📍\(location) / \(status)"
        tempLabel.text = temperature
        
        // 기존에 들어간 라벨들 제거하고 새로 추가
        headerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        [titleLabel, locationStatusLabel, tempLabel].forEach {
            headerStack.addArrangedSubview($0)
        }
        
        // 라벨 간 간격 지정
        headerStack.setCustomSpacing(32, after: titleLabel)
        headerStack.setCustomSpacing(10, after: locationStatusLabel)
    }
    
    // 중단 정보 설정
    func makeLargeStack(items: [WeatherData]) {
        largeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var smallStackRow: [UIStackView] = []
        
        for item in items {
            let smallStack = makeSmallStack(title: item.title, value: item.value)
            smallStackRow.append(smallStack)
            
            if smallStackRow.count == 2 {
                let mediumStack = UIStackView(arrangedSubviews: smallStackRow)
                mediumStack.axis = .horizontal
                mediumStack.spacing = 106
                mediumStack.distribution = .fillEqually
                largeStack.addArrangedSubview(mediumStack)
                smallStackRow.removeAll()
            }
        }
    }
    
    // 중단에 들어갈 title, value를 smallstack으로 만들어줌
    private func makeSmallStack(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .gray
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 32)
        valueLabel.textColor = .black
        
        let smallStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        smallStack.axis = .vertical
        smallStack.spacing = 5
        return smallStack
    }
    // 하단 시간별 날씨 정보 스택뷰 설정
    func makeTimeStack(data: [TimeWeatherInfo]) {
        timeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for weather in data {
            
            let timeLabel = UILabel()
            timeLabel.text = weather.time
            timeLabel.font = .systemFont(ofSize: 14)
            timeLabel.textColor = .black
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: weather.image)
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints {
                $0.size.equalTo(40) //
            }
            
            let valueLabel = UILabel()
            valueLabel.text = weather.value
            valueLabel.font = .boldSystemFont(ofSize: 25)
            
            let smallTimeStack = UIStackView(arrangedSubviews: [timeLabel, imageView, valueLabel])
            smallTimeStack.axis = .vertical
            smallTimeStack.alignment = .center
            smallTimeStack.spacing = 5
            
            timeStack.addArrangedSubview(smallTimeStack)
        }
    }
}
