//
//  AdsSectionView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 07/08/25.
//

import Foundation
import SwiftUI

struct AdsSectionView: View {
    let url: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Iklan - Gulir ke bawah untuk melanjutkan")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(white: 0.95))
            
            Image("ads_banner") // replace with your asset name
                .resizable()
                .scaledToFit()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
        .padding(.vertical)
        
    }
}
