//
//  ContentView+Extension.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/25/25.
//

import SwiftUI

extension ScanView {
    var enableMassEditGroup: Bool {
        vm.myImages.count > 0
    }
    
    var imageScroll: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Report (\(vm.reportInterval)):")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(vm.ripe) Ripe(s), \(vm.nearlyRipe) Nearly Ripe(s), \(vm.unripe) Unripe(s), \(vm.rotten) Rotten(s)")
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
                            Text("Date: \(getDate(myImage.date, "MM/dd/yyyy"))")
                                .font(.system(size: 12))
                            Text("Ripe: \(myImage.ripe)")
                                .font(.system(size: 12))
                            Text("Nearly Ripe: \(myImage.nearlyRipe)")
                                .font(.system(size: 12))
                            Text("Unripe: \(myImage.unripe)")
                                .font(.system(size: 12))
                            Text("Rotten: \(myImage.rotten)")
                                .font(.system(size: 12))
                        }
                        .onTapGesture {
                            if vm.imageChanged {
                                vm.imageChanged = false
                            }
                            vm.display(myImage)
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
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .padding(.horizontal)
            }
        }
    }
    
    var editGroup: some View {
        Group {
            HStack {
                if vm.image != nil {
                    if vm.imageSaved {
                        Image(systemName: "photo.badge.checkmark")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                    } else {
                        ButtonLabel(symbolName: "square.and.arrow.down.fill") {
                            vm.writeToPhotoAlbum(image: vm.image!)
                        }
                    }
                }
                if !vm.deleteButtonIsHidden && !vm.imageChanged {
                    ButtonLabel(symbolName: "trash") {
                        showDeleteImageConfirmation = true
                    }
                    .confirmationDialog("Are you sure you want to delete this image?", isPresented: $showDeleteImageConfirmation, titleVisibility: .visible) {
                        Button("Delete Image", role: .destructive) {
                            vm.deleteImage(vm.selectedImage!)
                        }
                    }
                }
                if vm.selectedImage != nil || vm.imageChanged {
                    ButtonLabel(symbolName: "xmark.circle") {
                        vm.reset()
                    }
                }
            }
        }
    }
    
    var pickerButtons: some View {
        HStack {
            ButtonLabel(symbolName: "camera") {
                vm.source = .camera
                vm.showPhotoPicker()
            }
            .alert("Error", isPresented: $vm.showCameraAlert, presenting: vm.cameraError, actions:
                    { cameraError in
                cameraError.button
            }, message: { cameraError in
                Text(cameraError.message)
            })
            ButtonLabel(symbolName: "photo") {
                vm.source = .library
                vm.showPhotoPicker()
            }
        }
    }
    
    var menuEditGroup: some View {
        Menu {
            Button {
                vm.reversedOrder.toggle()
            } label: {
                Label("Reverse Order", systemImage: "arrow.left.arrow.right")
            }
            
            Button {
                vm.saveAllImages()
            } label: {
                Label("Save All Images", systemImage: "square.and.arrow.down")
            }
            
            Button {
                showDeleteAllImagesConfirmation = true
            } label: {
                Label("Delete All Images", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 25))
        }
        .confirmationDialog("Are you sure you want to delete all of your images?", isPresented: $showDeleteAllImagesConfirmation, titleVisibility: .visible) {
            Button("Delete Images", role: .destructive) {
                loadingText = "Deleting images..."
                vm.loading = true
                vm.deleteImages = true
            }
        }
    }
    
    var loadingCircle: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(.black)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    self.rotation = 360
                }
                .onDisappear {
                    self.rotation = 0
                }
        }
        .compositingGroup()
        .frame(width: 12)
    }
}
