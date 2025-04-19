//
//  SideMenuView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var path: [ScanPath]
    @Binding var presentSideMenu: Bool
    @State var pressedTab: SideMenuRowType?
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: 270)
                    .shadow(color: .purple.opacity(0.1), radius: 5, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Text("Support Center")
                            .font(.system(size: 25, weight: .bold))
                            .padding(.bottom, 30)
                        
                        Spacer()
                    }
                    
                    ForEach(SideMenuRowType.allCases, id: \.self) { row in
                        RowView(tab: row,imageName: row.iconName, title: row.title) {
                            path.append(row.pathCase)
                            presentSideMenu.toggle()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 100)
                .frame(width: 270)
                .background(Color.white)
            }
            
            Spacer()
        }
        .background(.clear)
    }
    
    func RowView(tab: SideMenuRowType, imageName: String, title: String, hideDivider: Bool = false, action: @escaping (() -> ())) -> some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    Rectangle()
                        .fill(tab == pressedTab ? .green : .white)
                        .frame(width: 5)
                    ZStack {
                        Image(systemName: imageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(tab == pressedTab ? .white : .black)
                            .frame(width: 26, height: 26)
                    }
                    .frame(width: 30, height: 30)
                    Text(title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(tab == pressedTab ? .white : .black)
                    Spacer()
                }
                .contentShape(Rectangle()) // makes whole stack tappable, needed when using plain button style
            }
        }
        .frame(height: 50)
        .background(
            LinearGradient(colors: [tab == pressedTab ? .red : .white], startPoint: .leading, endPoint: .trailing)
        )
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    pressedTab = tab
                }
                .onEnded { _ in
                    pressedTab = nil
                }
        )
    }
}
