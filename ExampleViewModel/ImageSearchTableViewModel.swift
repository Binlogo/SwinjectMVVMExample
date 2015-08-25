//
//  ImageSearchTableViewModel.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import ReactiveCocoa
import ExampleModel

public final class ImageSearchTableViewModel: ImageSearchTableViewModeling {
    public var cellModels: PropertyOf<[ImageSearchTableViewCellModeling]> { return PropertyOf(_cellModels) }
    private let _cellModels = MutableProperty<[ImageSearchTableViewCellModeling]>([])
    
    /// Accepts property injection.
    public var imageDetailViewModel: ImageDetailViewModelModifiable?
    
    private let imageSearch: ImageSearching
    private let network: Networking
    
    private var foundImages = [ImageEntity]()
    
    public init(imageSearch: ImageSearching, network: Networking) {
        self.imageSearch = imageSearch
        self.network = network
    }
    
    public func startSearch() {
        func toCellModel(image: ImageEntity) -> ImageSearchTableViewCellModeling {
            return ImageSearchTableViewCellModel(image: image, network: self.network) as ImageSearchTableViewCellModeling
        }
        
        imageSearch.searchImages()
            .map { response in
                (response.images, response.images.map { toCellModel($0) })
            }
            .observeOn(UIScheduler())
            .on(next: { images, cellModels in
                self.foundImages = images
                self._cellModels.value = cellModels
            })
            .start()
    }

    public func selectCellAtIndex(index: Int) {
        imageDetailViewModel?.update(foundImages, atIndex: index)
    }
}
