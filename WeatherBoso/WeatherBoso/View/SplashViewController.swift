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
        
        // 스플래시 뷰가 로드 된 이후 
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToMain()
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
    
    private func transitionToMain() {
        // MainViewController를 생성
        let mainVC = MainViewController()
        let nav = UINavigationController(rootViewController: mainVC)

        // 현재 window 가져오기
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {

            // 전환 애니메이션
            UIView.transition(with: window,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = nav
            }, completion: nil)
        }
    }

}



