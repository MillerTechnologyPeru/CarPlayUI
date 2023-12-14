//
//  Image.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/23.
//

import Foundation
import UIKit
import CarPlay
import TokamakCore

internal extension UIImage {
    
    convenience init?(
        _ image: _ImageProxy,
        environment: EnvironmentValues = .defaultEnvironment
    ) {
        self.init(image.provider.resolve(in: environment), traitCollection: nil)
    }
    
    convenience init?(_ image: _AnyImageProviderBox._Image, traitCollection: UITraitCollection? = nil) {
        switch image.storage {
        case let .named(imageName, bundle: bundle):
            self.init(named: imageName, in: bundle, compatibleWith: traitCollection)
        case let .system(imageName):
            guard #available(iOS 13.0, *) else {
                return nil
            }
            self.init(systemName: imageName, compatibleWith: traitCollection)
        case let .resizable(storage, capInsets: capInsets, resizingMode: resizingMode):
            self.init(image, traitCollection: traitCollection)
        }
    }
    
    static func unsafe(
        _ image: _ImageProxy,
        environment: EnvironmentValues = .defaultEnvironment,
        file: StaticString = #file,
        line: UInt = #line
    ) -> UIImage {
        guard let image = UIImage(image, environment: environment) else {
            fatalError("Unable to load image \(image.provider)", file: file, line: line)
        }
        return image
    }
    
    static func unsafe(
        _ image: _AnyImageProviderBox._Image,
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
