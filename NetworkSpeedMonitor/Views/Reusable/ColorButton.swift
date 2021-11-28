//
//  ColorButton.swift
//  Theaterbae
//
//  Created by admin on 9/15/21.
//

import SwiftUI

struct ColorButton: View {
    
    var text:String
    var color:Color? // defaults to blue
    
    var body: some View {
        ZStack {
            Rectangle()
                // Button color
                .foregroundColor(color ?? .blue)
                // Height
                .frame(height:48)
                // Edge rounding
                .cornerRadius(10)
            Text(text)
                // Text color
                .foregroundColor(Color.white)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
        }
    }
}

struct ColorButton_Previews: PreviewProvider {
    static var previews: some View {
        ColorButton(text: "Button Text", color: .blue)
    }
}
