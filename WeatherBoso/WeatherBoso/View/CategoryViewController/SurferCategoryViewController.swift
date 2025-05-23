import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class SurferCategoryViewController: UIViewController {
    
    private let searchBar = SearchBar()
    
    private let viewModel = SurferCategoryViewModel()
    private let disposeBag = DisposeBag()

    private lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: collectionSet())

    private let customNavBar = UIView()
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  파도보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()

    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<BeachSection>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SurferCell.self), for: indexPath) as? SurferCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: item)
            return cell
        })

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(collection)
        view.addSubview(searchBar)
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)

        collection.register(SurferCell.self, forCellWithReuseIdentifier: String(describing: SurferCell.self))

        setConstraints()
        bindViewModel()
        bindCellTap()

        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func bindCellTap() {
        collection.rx.modelSelected(Beach.self)
            .withUnretained(self)
            .bind { beach in
                let detailVC = SurferDetailViewController()
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.fetchBeachSections()
            .bind(to: collection.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

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
            $0.leading.trailing.bottom.equalToSuperview().inset(23)
        }
    }

    private func collectionSet() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 30

        return UICollectionViewCompositionalLayout(section: section)
    }
}
