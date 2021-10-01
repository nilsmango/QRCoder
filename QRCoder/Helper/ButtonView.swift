//
//  ButtonView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct ButtonView<ButtonContent: View>: View {
    
    let action: () -> Void
    let content: ButtonContent
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> ButtonContent) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(width: 175,height: 55)
                .background(Color("ButtonColor"))
                .clipShape(Capsule())
        }
    }
}

