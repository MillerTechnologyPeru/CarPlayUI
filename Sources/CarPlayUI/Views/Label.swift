//
//  Label.swift
//
//
//  Created by Alsey Coleman Miller on 12/11/23.
//

import Foundation
import TokamakCore

public struct Label<Title, Icon> : View where Title : View, Icon : View {
    
    let title: Title
    
    let icon: Icon

    /// Creates a label with a custom title and icon.
    public init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title()
        self.icon = icon()
    }
    
    public var body: TupleView<(Title, Icon)> {
        title
        icon
    }
}

extension Label where Title == Text, Icon == Image {

    /// Creates a label with an icon image and a title generated from a string.
    ///
    /// - Parameters:
    ///    - title: A string used as the label's title.
    ///    - image: The name of the image resource to lookup.
    public init<S>(_ title: S, image name: String) where S : StringProtocol {
        self.init(
            title: { Text(title) },
            icon: { Image(name) }
        )
    }
    
    /// Creates a label with a system icon image and a title generated from a
    /// string.
    ///
    /// - Parameters:
    ///    - title: A string used as the label's title.
    ///    - systemImage: The name of the image resource to lookup.
    public init<S>(_ title: S, systemImage name: String) where S : StringProtocol {
        self.init(
            title: { Text(title) },
            icon: { Image(systemName: name) }
        )
    }
}
