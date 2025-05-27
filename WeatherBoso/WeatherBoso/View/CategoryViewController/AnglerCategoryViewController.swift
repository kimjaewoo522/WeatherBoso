import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class AnglerCategoryViewController: UIViewController {

    private let searchBar = SearchBar()
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout())
    private let customNavBar = UIView()
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.setTitle("  낚아보소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GmarketSansTTFMedium", size: 29)
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()

    private let viewModel = AnglerCategoryViewModel()
    private let disposeBag = DisposeBag()

    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<AnglerSection>(
        configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnglerCell.id, for: indexPath) as! AnglerCell
            cell.locaName.text = item.name
            cell.tempLabel.text = item.temperature
            cell.statusLabel.text = item.status
            cell.locabg.image = UIImage(named: item.imageName)
            return cell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchAnglers()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customNavBar)
        view.addSubview(searchBar)
        view.addSubview(collection)
        customNavBar.addSubview(backButton)

        collection.register(AnglerCell.self, forCellWithReuseIdentifier: AnglerCell.id)

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

    private func setupBindings() {
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        viewModel.anglerSections
            .bind(to: collection.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collection.rx.modelSelected(Angler.self)
            .subscribe(onNext: { [weak self] item in
                let detailVC = AnglerDetailViewController(angler: item)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private static func collectionLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(90)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 30

        return UICollectionViewCompositionalLayout(section: section)
    }
}
