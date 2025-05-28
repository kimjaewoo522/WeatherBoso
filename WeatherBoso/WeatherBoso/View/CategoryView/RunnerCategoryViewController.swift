//
//  RunnerCategoryViewController.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

// MARK: - 러너 카테고리 화면

final class RunnerCategoryViewController: UIViewController {

    // MARK: - UI 컴포넌트 정의

    private let searchBar = SearchBar()
    private let viewModel = RunnerCategoryViewModel()
    private let disposeBag = DisposeBag()

    private lazy var collection = UICollectionView(
        frame: .zero, collectionViewLayout: collectionSet()
    )

    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  뛰어보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()

    // MARK: - 콜렉션 뷰 데이터소스

    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<RunningSpotSection>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RunnerCell.self), for: indexPath) as? RunnerCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        })

    override func viewDidLoad() {
        super.viewDidLoad()

        [collection, searchBar, customNavBar].forEach { view.addSubview($0) }
        customNavBar.addSubview(backButton)
        view.backgroundColor = .white

        collection.register(RunnerCell.self, forCellWithReuseIdentifier: String(describing: RunnerCell.self))
        collection.showsVerticalScrollIndicator = false

        setConstraints()
        bindViewModel()
        bindCellTap()
        bindSearchBar()

        // 뒤로 가기 버튼 액션
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - 셀 선택 시 액션

    private func bindCellTap() {
        collection.rx.modelSelected(RunningSpot.self)
            .withUnretained(self)
            .bind { owner, runningSpot in
                let detailVC = RunnerDetailViewController()
                detailVC.latitude = runningSpot.lat
                detailVC.longitude = runningSpot.lon
                detailVC.locationName = runningSpot.name
                detailVC.isFromSearch = false
                owner.navigationController?.pushViewController(detailVC, animated: true)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - 검색바 검색 처리

    private func bindSearchBar() {
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .flatMapLatest { query -> Observable<Event<(latitude: String, longitude: String, address: String)>> in
                RunnerViewModel.shared.fetchCoordinates(for: query)
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let coord):
                    guard let lat = Double(coord.latitude),
                          let lon = Double(coord.longitude) else { return }
                    let detailVC = RunnerDetailViewController()
                    detailVC.latitude = lat
                    detailVC.longitude = lon
                    detailVC.locationName = coord.address
                    detailVC.isFromSearch = true
                    self.navigationController?.pushViewController(detailVC, animated: true)
                case .error:
                    let alert = UIAlertController(title: "오류", message: "주소를 찾을 수 없습니다. 다시 입력해 주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - 러닝 스팟 데이터 바인딩

    private func bindViewModel() {
        viewModel.fetchRunningSpotSections()
            .bind(to: collection.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - 레이아웃 제약 설정

    private func setConstraints() {
        customNavBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        searchBar.snp.makeConstraints {
            $0.top.equalTo(customNavBar.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(56)
        }

        collection.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(27)
            $0.leading.trailing.equalToSuperview().inset(23)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - 콜렉션 뷰 레이아웃 구성

    private func collectionSet() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10

        return UICollectionViewCompositionalLayout(section: section)
    }
}
