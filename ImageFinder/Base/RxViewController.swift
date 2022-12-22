//
//  RxViewController.swift
//  ImageFinder
//
//  Created by jae on 2022/12/11.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class RxViewController<T: RxViewModel>: UIViewController, Deinitializable {
    typealias ViewModel = T
    
    var viewModel: ViewModel!
    
    var disposeBag = DisposeBag()
    
    func deinitialize() {
        self.disposeBag = DisposeBag()
        self.viewModel.deinitialize()
        self.viewModel = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.deinitialize()

    }
}

