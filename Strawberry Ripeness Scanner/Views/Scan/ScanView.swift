//
//  ScanView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/24/25.
//

import SwiftUI

struct ScanView: View {
    @EnvironmentObject var vm: ViewModel
    @State private var showDatePicker = false
    @State private var rotation: Double = 0
    @State var showDeleteImageConfirmation = false
    var body: some View {
        ZStack {
            VStack {
                //Text("Start Date: \(vm.date), End Date: \(vm.endDate)")
                Text("My Scans")
                    .font(.system(size: 34, weight: .bold))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                
                VStack {
                    
                    HStack {
                        HStack(spacing: 0) {
                            if vm.currentUser != nil {
                                Text("Cloud Status: ")
                                    .padding(.leading, 16)
                                    .font(.system(size: 14))
                                    .padding(.trailing, 0)
                                if vm.syncing {
                                    Text("Syncing ")
                                        .font(.system(size: 14))
                                    
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
                                } else {
                                    Text("Synced")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green)
                                    Image(systemName: "checkmark.icloud")
                                        .foregroundColor(.green)
                                }
                            }
                            
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button {
                                if vm.interval != .allTime {
                                    vm.interval = .allTime
                                    vm.loadImages()
                                }
                            } label: {
                                Text("All Time")
                            }
                            
                            Button {
                                if vm.interval != .today {
                                    vm.interval = .today
                                    vm.loadImages()
                                }
                            } label: {
                                Text("Today")
                            }
                            
                            Button {
                                vm.interval = .custom
                                vm.loadImages()
                            } label: {
                                Text("Custom Range: \(getDate(vm.date, "MM/dd/yyyy")) to \(getDate(vm.endDate, "MM/dd/yyyy"))")
                            }
                        } label: {
                            Text("Generate Report")
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .padding(.trailing, 16)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("Start")
                            .font(.system(size: 14))
                        Image(systemName: "calendar")
                            .font(.title3)
                            .offset(x: -2)
                            .overlay{
                                DatePicker("Select Date", selection: $vm.date,displayedComponents: [.date])
                                    .blendMode(.destinationOver)
                                
                            }
                        
                        Text("End")
                            .font(.system(size: 14))
                        Image(systemName: "calendar")
                            .font(.title3)
                            .offset(x: -2)
                            .overlay{
                                DatePicker("", selection: $vm.endDate, in: vm.date..., displayedComponents: [.date])
                                    .blendMode(.destinationOver)
                                
                            }
                    }
                    .padding(.trailing, 35)
                }
                .padding(.top, -25)
                .padding(.bottom, 10)
                
                
                VStack {
                    if !vm.isEditing {
                        imageScroll
                    }
                    selectedImage
                    HStack {
                        if !vm.isEditing {
                            pickerButtons
                                .padding(.horizontal)
                        }
                        Spacer()
                        if vm.imageChanged {
                            ButtonLabel(text: "Scan") {
                                vm.loading = true
                                vm.addMyImage(image: vm.image!)
                            }
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .clipShape(Circle())
                        }
                        Spacer()
                        if vm.image != nil {
                            editGroup
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, -5)
                    Spacer()
                }
                .task {
                    if FileManager().docExist(named: fileName) {
                        vm.loadMyImagesJSONFile()
                    }
                }
                .sheet(isPresented: $vm.showPicker) {
                    ImagePicker(sourceType: vm.source == .library ? .photoLibrary : .camera, selectedImage: $vm.image, onImagePicked: { image in // closure function
                        // only executed if user chooses image
                        vm.imageChanged = true
                        vm.isEditing = false
                    })
                }
                .alert("Error", isPresented: $vm.showFileAlert, presenting: vm.appError, actions:
                        { cameraError in
                    cameraError.button
                }, message: { cameraError in
                    Text(cameraError.message)
                })
            }
            if vm.loading {
                LoadingView(text: "Scanning...")
            }
        }
    }
}

#Preview {
    ScanView()
        .environmentObject(ViewModel())
}
