//
//  IframView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import Foundation
import SwiftUI

struct IframeView: View {
    let url: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nama Widget")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                }) {
                    Text("Lihat Selengkapnya")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            Image("iframe_campaign") 
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
        }
        .padding(.horizontal)

    }
}
