//
//  ViewController.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift

final class MainViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.text = "취미 골라 BoSo"
        label.font = UIFont(name: "GmarketSansTTFMedium", size: 32)
       return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "이젠 날씨도 취미별로!\n원하는 취미를 골라 커스텀 날씨를 볼 수 있습니다"
        label.font = UIFont(name: "GmarketSansTTFLight", size: 14)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var vStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        [hStackView1, hStackView2, hStackView3].forEach
        { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var hStackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 36
        [surfButton, baseballButton].forEach
        { stackView.addArrangedSubview($0) }
        return stackView
    }()
    private let surfButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainSurfing"), for: .normal)
        return button
    }()
    private let baseballButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainBaseball"), for: .normal)
        return button
    }()
    private lazy var hStackView2: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 36
        [fishingButton, runningButton].forEach
        { stackView.addArrangedSubview($0) }
        return stackView
    }()

    private let fishingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainFishing"), for: .normal)
        return button
    }()
    private let runningButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainRunning"), for: .normal)
        return button
    }()
    private lazy var hStackView3: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 36
        [ridingButton, etcButton].forEach
        { stackView.addArrangedSubview($0) }
        return stackView
    }()

    private let ridingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainRiding"), for: .normal)
        return button
    }()
    private let etcButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainETC"), for: .normal)
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bind()
    }
    private func setupUI() {
        view.backgroundColor = .white
        [mainLabel, subLabel, vStackView]
            .forEach { view.addSubview ($0) }
    }
    private func setupConstraints() {
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(32)
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(32)
        }
        
        vStackView.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(40)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(32)
            
        }
        [surfButton, baseballButton, fishingButton, runningButton, ridingButton, etcButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(150)
                $0.height.equalTo(170)
            }
        }

    }
    
    private func bind() {
        surfButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = SurferCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
        baseballButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = BaseBallCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
        fishingButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = AnglerCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
        runningButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = RunnerCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
        ridingButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = RiderCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

