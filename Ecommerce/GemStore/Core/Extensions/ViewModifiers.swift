//
//  ViewModifiers.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct CardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

struct ResponsiveFrame: ViewModifier {
    let height: CGFloat?
    let alignment: Alignment
    
    init(height: CGFloat? = nil, alignment: Alignment = .center) {
        self.height = height
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: height,
                maxHeight: height,
                alignment: alignment
            )
    }
}


