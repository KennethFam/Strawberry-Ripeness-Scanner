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
    var body: some View {
        VStack {
            //Text("Start Date: \(vm.date), End Date: \(vm.endDate)")
            Text("My Scans")
                .font(.system(size: 34, weight: .bold))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            VStack {
                HStack {
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
                VStack {
                    if vm.image != nil {
                        editGroup
                    }
                    if !vm.isEditing {
                        pickerButtons
                    }
                }
                .padding()
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
    }
}

#Preview {
    ScanView()
        .environmentObject(ViewModel())
}
