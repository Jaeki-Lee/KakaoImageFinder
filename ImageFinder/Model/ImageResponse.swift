//
//  ImageResponse.swift
//  ImageFinder
//
//  Created by jae on 2022/12/11.
//

import Foundation

// MARK: - ImageResponse
struct ImageResponse: Codable {
    var documents: [Document]
    let meta: Meta
}

// MARK: - Document
struct Document: Codable, Equatable {
    let collection, datetime, displaySitename: String
    let docURL: String
    let height: Int
    let imageURL: String
    let thumbnailURL: String
    let width: Int
    var isBookmarked: Bool = false
    var keyWord: String = ""

    enum CodingKeys: String, CodingKey {
        case collection, datetime
        case displaySitename = "display_sitename"
        case docURL = "doc_url"
        case height
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
        case width
    }
}

// MARK: - Meta
struct Meta: Codable {
    let isEnd: Bool
    let pageableCount, totalCount: Int

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}

struct BookmarkedImage {
    let collection, datetime, displaySitename: String
    let docURL: String
    let height: Int
    let imageURL: String
    let thumbnailURL: String
    let width: Int
    var isBookmarked: Bool = false
    var searchKeyword: String = ""
}

