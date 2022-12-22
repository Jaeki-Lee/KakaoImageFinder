//
//  ViewController.swift
//  ImageFinder
//
//  Created by jae on 2022/12/10.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class ViewController: RxViewController<ViewModel> {
    
    //MARK: - UI 객체
    let searchTextField = UITextField().then {
        $0.backgroundColor = .lightGray
        $0.placeholder = "찾으려는 이미지를 검색 해주세요.."
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .left
        $0.layer.cornerRadius = 20
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        $0.leftView = paddingView
        $0.rightView = paddingView
        $0.leftViewMode = .always
    }
    
    lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .white
        $0.allowsSelection = false
        $0.rowHeight = UITableView.automaticDimension
        $0.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.reuseId)
        $0.isHidden = true
    }
    
    let switchToBookMarkButton = UIButton().then {
        $0.setTitle("북마크 페이지로", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    let switchToSearchingkButton = UIButton().then {
        $0.setTitle("검색 페이지로", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1.0
        $0.isHidden = true
    }
    
    let deleteBookmarkedImagesButton = UIButton().then {
        $0.setTitle("선택된 이미지 삭제", for: .normal)
        $0.setTitleColor(UIColor.red, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1.0
        $0.isHidden = true
    }
    
    let noResultLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다.."
        $0.textColor = UIColor.black
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.searchTextField.delegate = self
        self.dismissKeyboard()
        
        self.initViewModel()
        self.setViews()
        
        self.bindInput()
        self.bindOutput()
        
    }
    
    //MARK: - 화면 그리는 메소드
    fileprivate func initViewModel() {
        let viewModel = ViewModel(
            dependency: ViewModel.Dependency(
                interactor: Interactor()
            )
        )
        
        self.viewModel = viewModel
    }
    
    fileprivate func setViews() {
        self.view.addSubview(self.searchTextField)
        self.view.addSubview(self.noResultLabel)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.switchToBookMarkButton)
        self.view.addSubview(self.switchToSearchingkButton)
        self.view.addSubview(self.deleteBookmarkedImagesButton)
        
        self.searchTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.searchTextField.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.noResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.switchToBookMarkButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
        
        self.switchToSearchingkButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
        
        self.deleteBookmarkedImagesButton.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    //MARK: - binder
    fileprivate func bindInput() {
        self.switchToBookMarkButton.rx
            .controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { (self, _) in
                
                self.searchTextField.text = ""
                self.viewModel.input.requestBookmarkedImages.accept(())
                
            }.disposed(by: self.disposeBag)
        
        self.switchToSearchingkButton.rx
            .controlEvent(.touchUpInside)
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { (self, _) in
                
                self.searchTextField.text = ""
                self.viewModel.input.requestSavedImages.accept(())
                
            }.disposed(by: self.disposeBag)
        
        self.deleteBookmarkedImagesButton.rx
            .controlEvent(.touchUpInside)
            .withUnretained(self)
            .subscribe { (self, _) in
                self.viewModel.input.deleteBookmarkedImage.accept(())
            }.disposed(by: self.disposeBag)
        
    }
    

    fileprivate func bindOutput() {
        self.viewModel.output.loadImages
            .withUnretained(self)
            .emit { (self, networkResult) in
                switch networkResult {
                case .success(_):
                    if let imageResponse = self.viewModel.imageResponse,
                       imageResponse.documents.count > 0
                    {
                        self.noResultLabel.isHidden = true
                        self.tableView.isHidden = false
                        
                        self.tableView.reloadData()
                    } else {
                        self.noResultLabel.isHidden = false
                        self.tableView.isHidden = true
                        
                        self.showAlertDialog(title: "검색 결과가 없습니다.")
                    }
                case .falied(_):
                    self.showAlertDialog(title: "오류가 발생 했습니다. 다시 시도해주세요")
                }
                
            }.disposed(by: self.disposeBag)
        
        self.viewModel.output.loadBookmarkedImages
            .withUnretained(self)
            .emit { (self, _) in
                self.switchToBookMarkButton.isHidden = true
                self.switchToSearchingkButton.isHidden = false
                self.deleteBookmarkedImagesButton.isHidden = false
                
                self.tableView.allowsMultipleSelection = true
                self.tableView.reloadData()
            }.disposed(by: self.disposeBag)
        
        self.viewModel.output.loadSavedImages
            .withUnretained(self)
            .emit { (self, _) in
                self.switchToBookMarkButton.isHidden = false
                self.switchToSearchingkButton.isHidden = true
                self.deleteBookmarkedImagesButton.isHidden = true
                
                self.tableView.allowsMultipleSelection = false
                self.tableView.reloadData()
            }.disposed(by: self.disposeBag)

    }
    
    //MARK: - 메소드
    fileprivate func showAlertDialog(title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(title: "확인", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(action)
            
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboardTouchOutside)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}


extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let imageResponse = self.viewModel.imageResponse else { return 0 }
        
        switch self.viewModel.tableType {
        case .searching:
            return imageResponse.documents.count
        case .bookmark:
            return self.viewModel.bookmarkedImages.count
        case .filteredBookMark:
            return self.viewModel.filteredBookmarkedImages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reuseId, for: indexPath) as! ImageTableViewCell
        
        
        switch self.viewModel.tableType {
        case .searching:
            if let doc = self.viewModel.imageResponse?.documents[indexPath.row] {
                
                cell.renderForSearchResultCell(doc: doc,
                                               selfIndex: indexPath.row,
                                               bookmarkRelay: self.viewModel.input.bookMarkImage)
                
            }
        case .bookmark:
            let doc = self.viewModel.bookmarkedImages[indexPath.row]
                
            cell.renderForBookmarkCell(doc: doc)
        case .filteredBookMark:
            let doc = self.viewModel.filteredBookmarkedImages[indexPath.row]
            
            cell.renderForBookmarkCell(doc: doc)
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.input.selectBookmarkedImageIndex.accept(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.viewModel.input.deSelectBookmarkedImageIndex.accept(indexPath.row)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let keyWord = textField.text {
                switch self.viewModel.tableType {
                case .searching:
                    self.searchingAPI(keyWord: keyWord)
                case .bookmark:
                    self.viewModel.input.requestFilteredBookMarkImage.accept(keyWord)
                case .filteredBookMark:
                    self.viewModel.input.requestFilteredBookMarkImage.accept(keyWord)
                }
            }
        }
        return true
    }
    
    fileprivate func searchingAPI(keyWord: String) {
        
        if self.viewModel.recentKeyword == "" {
            
            self.viewModel.recentKeyword = keyWord
            
            self.viewModel.requestImageRelay.accept(
                ImageParams(
                    query: self.viewModel.recentKeyword,
                    sort: "accuracy",
                    page: 1,
                    size: 10
                )
            )
        }
        
        if self.viewModel.recentKeyword != keyWord {
            
            self.viewModel.requestImageRelay.accept(
                ImageParams(
                    query: keyWord,
                    sort: "accuracy",
                    page: 1,
                    size: 10
                )
            )
            
            self.viewModel.recentKeyword = keyWord
        }
        
        
    }
    
}
