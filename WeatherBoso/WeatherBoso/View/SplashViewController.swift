//
//  SplashView.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/21/25.
//

import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Logo")
        
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let mainVC = MainViewController()
            let nav = UINavigationController(rootViewController: mainVC)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .crossDissolve
            self.present(nav, animated: true)
            
            
        }

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logoImage)
        
    }
    private func setConstraints() {
        logoImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    
}
