import UIKit
import SnapKit

// 날씨 정보를 담는 단순한 데이터 모델 (제목 + 값)
struct WeatherData {
    let title: String
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

        // 뷰에 스택뷰들을 추가
        addSubview(headerStack)
        addSubview(largeStack)
        addSubview(imageView)
        // 라벨 스타일 지정
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .boldSystemFont(ofSize: 58)

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
    }

    // 각자 뷰에서 입맛대로 넣을 수 있게.
    func updateWeatherHeader(title: String, location: String, temperature: String, status: String) {
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

    // 중간 정보(WeatherInfo 리스트)를 화면에 표시
    // smallstack을 두개 묶어서 medium으로 만들어주기.
    func updateWeatherInfo(items: [WeatherData]) {
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

    // title, value를 smallstack으로 만들어줌.
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
}
