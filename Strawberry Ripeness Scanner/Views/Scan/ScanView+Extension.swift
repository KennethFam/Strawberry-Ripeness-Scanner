//
//  ContentView+Extension.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/25/25.
//

import SwiftUI

extension ScanView {
    var imageScroll: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Report (\(vm.reportInterval)):")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(vm.ripe) Ripe(s), \(vm.nearlyRipe) Nearly Ripe(s), \(vm.unripe) Unripe(s)")
                        .font(.system(size: 14, weight: .bold))
                }
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vm.displayedImages) { myImage in
                        VStack {
                            Image(uiImage: myImage.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 2)
                            Text("Ripe: \(myImage.ripe)")
                                .font(.system(size: 12))
                            Text("Nearly Ripe: \(myImage.nearlyRipe)")
                                .font(.system(size: 12))
                            Text("Unripe: \(myImage.unripe)")
                                .font(.system(size: 12))
                            Text("Date: \(getDate(myImage.date, "MM/dd/yyyy"))")
                                .font(.system(size: 12))
                        }
                        .onTapGesture {
                            vm.display(myImage)
                            if vm.imageChanged {
                                vm.imageChanged = false
                            }
                        }
                    }
                }
            }.padding(.horizontal)
        }
    }
    
    func getDate(_ date: Date, _ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    var selectedImage: some View {
        Group {
            if let image = vm.image {
                ZoomableScrollView {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.6)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
    }
    
    var editGroup: some View {
        Group {
            HStack {
                Button {
                    if vm.selectedImage == nil || vm.imageChanged {
                        vm.addMyImage(image: vm.image!)
                    } else {
                        vm.reset()
                    }
                } label: {
                    // describe what the save/update button should do based on whether image is nil
                    ButtonLabel(symbolName: vm.selectedImage == nil || vm.imageChanged ? "square.and.arrow.down.fill" : "xmark.circle",
                                label: vm.selectedImage == nil || vm.imageChanged ? "Scan" : "Close")
                }
                if !vm.deleteButtonIsHidden && !vm.imageChanged {
                    Button {
                        vm.deleteSelected()
                    } label: {
                        ButtonLabel(symbolName: "trash", label: "Delete")
                    }
                }
            }
        }
    }
    
    var pickerButtons: some View {
        HStack {
            Button {
                vm.source = .camera
                vm.showPhotoPicker()
            } label: {
                // set button to style we made in ButtonLabel
                ButtonLabel(symbolName: "camera", label: "Camera")
            }
            .alert("Error", isPresented: $vm.showCameraAlert, presenting: vm.cameraError, actions:
                    { cameraError in
                cameraError.button
            }, message: { cameraError in
                Text(cameraError.message)
            })
            Button {
                vm.source = .library
                vm.showPhotoPicker()
            } label: {
                // set button to style we made in ButtonLabel
                ButtonLabel(symbolName: "photo", label: "Photos")
            }
        }
    }
}
