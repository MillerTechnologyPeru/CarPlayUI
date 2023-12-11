//
//  Image.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import UIKit

public struct Image: Equatable, Hashable, Codable {
    
    let storage: Storage
    
    public init(data: Data, scale: CGFloat = 1.0) {
        self.storage = .data(data, scale: scale)
    }
    
    public init(named imageName: String, bundle: Bundle = .main) {
        self.storage = .name(imageName, bundle: bundle == .main ? nil : bundle.bundleIdentifier)
    }
    
    public init(file path: String) {
        self.storage = .file(path)
    }
    
    @available(iOS 13.0, *)
    public init(system imageName: String) {
        self.storage = .system(imageName)
    }
}

internal extension Image {
    
    enum Storage: Equatable, Hashable, Codable {
        
        case data(Data, scale: CGFloat = 1.0)
        
        case file(String)
        
        case name(String, bundle: String? = nil)
        
        case system(String)
    }
}

internal extension UIImage {
    
    convenience init?(_ image: Image, traitCollection: UITraitCollection? = nil) {
        switch image.storage {
        case let .data(data, scale: scale):
            self.init(data: data, scale: scale)
        case let .name(name, bundle: bundle):
            self.init(named: name, in: bundle.flatMap { Bundle(identifier: $0) } ?? .main, compatibleWith: traitCollection)
        case let .system(imageName):
            guard #available(iOS 13.0, *) else {
                return nil
            }
            self.init(systemName: imageName, compatibleWith: traitCollection)
        case let .file(path):
            self.init(contentsOfFile: path)
        }
    }
    
    static func unsafe(
        _ image: Image,
        traitCollection: UITraitCollection? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> UIImage {
        guard let image = UIImage(image, traitCollection: traitCollection) else {
            fatalError("Unable to load image \(image.storage)", file: file, line: line)
        }
        return image
    }
}
