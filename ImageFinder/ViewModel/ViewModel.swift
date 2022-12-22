//
//  ViewModel.swift
//  ImageFinder
//
//  Created by jae on 2022/12/11.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel: RxViewModel, RxViewModelProtocol {
    
    struct Input {
        let requestImage: PublishRelay<ImageParams>
        let requestFilteredBookMarkImage: PublishRelay<String>
        let bookMarkImage: PublishRelay<Int>
        let requestSavedImages: PublishRelay<Void>
        let requestBookmarkedImages: PublishRelay<Void>
        let selectBookmarkedImageIndex: PublishRelay<Int>
        let deSelectBookmarkedImageIndex: PublishRelay<Int>
        let deleteBookmarkedImage: PublishRelay<Void>
    }
    
    struct Output {
        let loadImages: Signal<NetworkResult<ImageResponse, NSError>>
        let loadFilteredBookMarkImages: Signal<Void>
        let loadSavedImages: Signal<Void>
        let loadBookmarkedImages: Signal<Void>
    }
    
    struct Dependency {
        let interactor: Interactor
    }
    
    var input: ViewModel.Input!
    var output: ViewModel.Output!
    var dependency: ViewModel.Dependency!
    
    //MARK: - Input 중계 변수
    var requestImageRelay = PublishRelay<ImageParams>()
    var requestFilteredBookMarkImageRelay = PublishRelay<String>()
    var bookmarkImageRelay = PublishRelay<Int>()
    var requestSavedImagesRelay = PublishRelay<Void>()
    var requestBookmarkedImagesRelay = PublishRelay<Void>()
    var selectBookmarkedImageIndexRelay = PublishRelay<Int>()
    var deSelectBookmarkedImageIndexRelay = PublishRelay<Int>()
    var deleteBookmarkedImageRelay = PublishRelay<Void>()
    
    //MARK: - Output 중계 변수
    var loadImagesRelay = PublishRelay<NetworkResult<ImageResponse, NSError>>()
    var loadFilteredBookMarkImagesRelay = PublishRelay<Void>()
    var loadSavedImagesRelay = PublishRelay<Void>()
    var loadBookmarkedImagesRelay = PublishRelay<Void>()
    var showRemoveButtonRelay = PublishRelay<Void>()
    
    //MARK: - ViewModel 변수
    var imageResponse: ImageResponse?
    var recentKeyword = ""
    var tableType = TableType.searching
    var bookmarkedImages = [Document]()
    var filteredBookmarkedImages = [Document]()
    var deleteCandidateBookmark = [Document]()
    
    //MARK: - Init
    init(dependency: Dependency) {
        super.init()
        
        self.dependency = dependency
        
        self.input = ViewModel.Input(
            requestImage: self.requestImageRelay,
            requestFilteredBookMarkImage: self.requestFilteredBookMarkImageRelay,
            bookMarkImage: self.bookmarkImageRelay,
            requestSavedImages: self.requestSavedImagesRelay,
            requestBookmarkedImages: self.requestBookmarkedImagesRelay,
            selectBookmarkedImageIndex: self.selectBookmarkedImageIndexRelay,
            deSelectBookmarkedImageIndex: self.deSelectBookmarkedImageIndexRelay,
            deleteBookmarkedImage: self.deleteBookmarkedImageRelay
        )
        
        self.output = ViewModel.Output(
            loadImages: self.loadImagesRelay.asSignal(),
            loadFilteredBookMarkImages: self.loadFilteredBookMarkImagesRelay.asSignal(),
            loadSavedImages: self.loadSavedImagesRelay.asSignal(),
            loadBookmarkedImages: self.loadBookmarkedImagesRelay.asSignal()
        )
        
        self.bindInput()
        self.bindOutput()
    }
    
    //MARK: - binder
    fileprivate func bindInput() {
        self.requestImageRelay
            .flatMap { imageParam in
                self.dependency.interactor.getImages(parmas: imageParam)
            }
            .withUnretained(self)
            .subscribe { (self, imageResponse) in
                if let imageResponseModel = imageResponse {
                    self.imageResponse = imageResponse
                    
                    self.mappingReponseImageWithBookMarkedImage()
                    
                    self.loadImagesRelay.accept(NetworkResult.success(imageResponseModel))
                } else {
                    self.loadImagesRelay.accept(NetworkResult.falied(NSError(domain: "error", code: -2)))
                }
            }.disposed(by: self.disposeBag)
        
        self.requestFilteredBookMarkImageRelay
            .withUnretained(self)
            .subscribe { (self, keyWord) in
                if keyWord != "" {
                    self.filteredBookmarkedImages = self.bookmarkedImages.filter({ $0.keyWord == keyWord })
                    self.tableType = .filteredBookMark
                    self.loadBookmarkedImagesRelay.accept(())
                } else {
                    self.tableType = .bookmark
                    self.loadBookmarkedImagesRelay.accept(())
                }
            }.disposed(by: self.disposeBag)
        
        self.bookmarkImageRelay
            .withUnretained(self)
            .subscribe { (self, selectedIndex) in

                if var selectedDoc = self.imageResponse?.documents[selectedIndex] {
                    self.imageResponse!.documents[selectedIndex].isBookmarked = !self.imageResponse!.documents[selectedIndex].isBookmarked
                    
                    if let index = self.bookmarkedImages.firstIndex(where: { $0.imageURL == selectedDoc.imageURL }) {
                        self.bookmarkedImages.remove(at: index)
                    } else {
                        selectedDoc.keyWord = self.recentKeyword
                        self.bookmarkedImages.append(selectedDoc)
                    }
                }

            }.disposed(by: self.disposeBag)
        
        self.requestBookmarkedImagesRelay
            .withUnretained(self)
            .subscribe { (self, _) in
                self.tableType = .bookmark
                self.loadBookmarkedImagesRelay.accept(())
            }.disposed(by: self.disposeBag)
        
        self.requestSavedImagesRelay
            .withUnretained(self)
            .subscribe { (self, _) in
                self.tableType = .searching
                
                self.mappingReponseImageWithBookMarkedImage()
                
                self.loadSavedImagesRelay.accept(())
            }.disposed(by: self.disposeBag)
        
        self.selectBookmarkedImageIndexRelay
            .withUnretained(self)
            .subscribe { (self, index) in
                self.deleteCandidateBookmark.append(self.bookmarkedImages[index])
            }.disposed(by: self.disposeBag)
        
        self.deSelectBookmarkedImageIndexRelay
            .withUnretained(self)
            .subscribe { (self, index) in
                let deseletedImage = self.bookmarkedImages[index]
                
                if let index = self.deleteCandidateBookmark.firstIndex(where: { $0.imageURL == deseletedImage.imageURL }) {
                    self.deleteCandidateBookmark.remove(at: index)
                }
            }.disposed(by: self.disposeBag)
        
        self.deleteBookmarkedImageRelay
            .withUnretained(self)
            .subscribe { (self, _) in
                
                self.deleteCandidateBookmark.forEach { bookMarkImage in
                    if let deleteIndex = self.bookmarkedImages.firstIndex(where: { $0.imageURL == bookMarkImage.imageURL }) {
                        self.bookmarkedImages.remove(at: deleteIndex)
                    }
                }
                
                self.deleteCandidateBookmark.removeAll()
                
                self.loadBookmarkedImagesRelay.accept(())
            }.disposed(by: self.disposeBag)
    }
    
    fileprivate func bindOutput() {
        
    }
    
    //MARK: - 메서드
    
    //검색 화면에 보여지는 Image 들과 Bookmarked Image 들과 맵핑 하여 검색 화면에 북마크된 이미지를 표시하려는 목적의 메서드
    fileprivate func mappingReponseImageWithBookMarkedImage() {
        
        if let images = self.imageResponse?.documents,
           images.count > 0 && self.bookmarkedImages.count > 0
        {
            for i in 0...images.count - 1 {
                for j in 0...bookmarkedImages.count - 1 {
                    if images[i].imageURL == bookmarkedImages[j].imageURL {
                        self.imageResponse?.documents[i].isBookmarked = true
                        break
                    } else {
                        self.imageResponse?.documents[i].isBookmarked = false   
                    }
                }
            }
            
        }

    }
    
}

enum TableType {
    case searching
    case bookmark
    case filteredBookMark
}
