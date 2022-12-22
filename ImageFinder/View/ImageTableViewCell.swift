//
//  ImageTableViewCell.swift
//  ImageFinder
//
//  Created by jae on 2022/12/11.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SDWebImage

class ImageTableViewCell: UITableViewCell {
    
    //MARK: - 변수
    var selfIndex = 0
    var bookmarkRelay: PublishRelay<Int>?
    
    var isBookemarked: Bool = false {
        didSet {
            if isBookemarked {
                self.bookmarkButton.setImage(UIImage(named: "icon_bookmark"), for: .normal)
            } else {
                self.bookmarkButton.setImage(UIImage(named: "icon_bookmark_off"), for: .normal)
            }
        }
    }
    
    //MARK: - UI 객체
    let searchedImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.sd_imageIndicator = SDWebImageActivityIndicator.gray
    }
    
    let bookmarkButton = UIButton().then {
        $0.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        $0.setImage(UIImage(named: "icon_bookmark_off"), for: .normal)
        $0.layer.cornerRadius = 1
        $0.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }

    //MARK: - Init, Deinit
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
    }
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        
        self.setBaseView()
    }
    
    //MARK: - 화면 그리는 메소드
    fileprivate func setBaseView() {
        self.contentView.addSubview(self.searchedImageView)
        self.contentView.addSubview(self.bookmarkButton)
        
        self.bookmarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(50)
        }

    }
    
    //MARK: - 검색화면 사용 셀
    public func renderForSearchResultCell(doc: Document, selfIndex: Int, bookmarkRelay: PublishRelay<Int>) {
        let imageHeight = (doc.height * Int(self.frame.width)) / doc.width
        self.bookmarkButton.isHidden = false
        
        self.searchedImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(imageHeight)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        self.searchedImageView.sd_setImage(with: URL(string: doc.imageURL))
        
        self.isBookemarked = doc.isBookmarked
        
        self.selfIndex = selfIndex
        self.bookmarkRelay = bookmarkRelay
    }
    
    //MARK: - 북마크 사용 셀
    public func renderForBookmarkCell(doc: Document) {
        let imageHeight = (doc.height * Int(self.frame.width)) / doc.width
        self.bookmarkButton.isHidden = true
        
        self.searchedImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(imageHeight)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        self.searchedImageView.sd_setImage(with: URL(string: doc.imageURL))
    }
    
    //MARK: - 메소드
    
    //북마크 버튼을 동작 함수
    @objc func bookmarkTapped() {
        if let bookmarkRelay = self.bookmarkRelay {
            bookmarkRelay.accept(selfIndex)
            self.isBookemarked = !self.isBookemarked
        }
    }
    
    //북마크 화면에서 삭제할 셀을 클릭할때 셀의 UI 변화를 주기 위한 함수
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.imageView?.backgroundColor = .gray
        } else {
            self.imageView?.backgroundColor = .clear
        }
        
    }
    
    //MARK: - cell id 로 사용
    static var reuseId: String {
        return NSStringFromClass(self)
    }
}
