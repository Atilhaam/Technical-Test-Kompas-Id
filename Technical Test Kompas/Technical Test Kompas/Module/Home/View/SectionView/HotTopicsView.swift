//
//  HotTopicsView.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 03/08/25.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct HotTopicsView: View {
    let section: HotTopicsSection

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(section.title ?? "")
                    .font(.headline)
                    .bold()
            }
            .padding(.horizontal)

            
            if let items = section.data {
                ForEach(items) { item in
                    HStack {
                        if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
                            WebImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 80)
                                .clipped()
                                .cornerRadius(8)
                                .padding(.vertical, -40)
                                .padding(.horizontal, -16)
                        }

                        Text(item.title ?? "")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 32)
                            .padding(.vertical, 16)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    )
                }
                .padding(.horizontal)


            }
            
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
}
