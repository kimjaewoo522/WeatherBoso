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

    private let surfButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MainSurfing"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bind()
    }
    private func setupUI() {
        view.backgroundColor = .white
        [surfButton]
            .forEach { view.addSubview ($0) }
    }
    private func setupConstraints() {
        surfButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(200)
        }
    }
    
    private func bind() {
        surfButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive { _ in
                let nextVC = SurferCategoryViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
    }
}

