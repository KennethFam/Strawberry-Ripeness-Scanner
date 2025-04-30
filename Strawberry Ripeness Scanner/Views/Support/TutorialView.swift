//
//  TutorialView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

import SwiftUI

struct TutorialView: View {
    @Binding var path: [ScanPath]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                PageTitle(title: "Tutorial View")
                
                Text("Scanning:")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("When you start the app, you will be greeted with a screen similar to this one:")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Image("start_screen")
                    .resizable()
                    .scaledToFill()
                Text("There are two icons at the bottom left: camera and photo. You can tap the camera icon to open your camera to take a picture, or you can click the photo icon to select a picture from your photo library. Once you have taken or selected a picture, you should see the image displayed like so:")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Image("picked_image")
                    .resizable()
                    .scaledToFill()
                Text("Notice the 3 new icons at the bottom: the big red circle with the word \"SCAN\", the blue icon with an arrow pointing down towards a square, and an X with a circle around it. The X with a circle around it will reset the current image when press (e.g. it will display the default image shown in the first picture at the top). The big red circle with the word \"SCAN\" will scan the image and mark the ripeness of the strawberry or strawberries in the image if there are any. The blue icon with an arrow pointing down towards a square will save the displayed image to your photo library. If you choose to save the image, the icon will change into a green photo icon with a checkmark upon a successeful save. You can also pick a different image using the camera or photo icon. When you finally have the image you want to scan, tap the big red circle with the word \"SCAN\". Once the image is scanned, the result will be displayed like so:")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Image("scanned_image")
                    .resizable()
                    .scaledToFill()
                Text("Each strawberry in the image will be encompassed in a rectange, also known as a bounding box. In the top left corner of each bounding box, you will notice a rectangle with a word in it. This word indicates the ripeness class of the strawberry. Above the scanned image will be small image icons. This is where you can access your scans (slide the images left or right). Under each scan is the date it was taken and the count of each ripeness class.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                HStack(spacing: 0) {
                    Text("Check out our ")
                    NavigationLink(value: ScanPath.ripenessGuide) {
                        Text("Ripeness Guide")
                    }
                    
                    Text(" to learn about ripeness.")
                }
                .font(.system(size: 16))
                .padding(.leading, 16)
                
                Text("Account & Photo Back-Ups:")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("We offer a free photo back-up feature. Simply click on \"Account\" at the bottom right and register for an account or log in for the back-up to happen.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("login")
                    .resizable()
                    .scaledToFill()
                Image("registration")
                    .resizable()
                    .scaledToFill()
                Text("Once you register or log in, you will be greeted with your user profile (shown below). On this screen, you can check your name, email, and app version. You are also given the option to sign out or delete your account.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("profile")
                    .resizable()
                    .scaledToFill()
                Text("If you go back to the Scan page by tapping on \"Scan\" at the bottom left. There, you will see scans linked to your account (e.g. it will load in scans performed on other devices, or scans that were on your account but were deleted after you had logged out. If you delete a scan when you are logged in, it will be gone forever. Under \"My Scans\" at the top, you will see your cloud status. If it displays \"Synced\", your scans have been synced with the cloud. If it displays \"Syncing\", new scans are being uploaded, or some old scans are being downloaded from the cloud.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("synced")
                    .resizable()
                    .scaledToFill()
                
                Text("Report Generation:")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("This app offers a report generation feature. This feature allows you to generate a report of scans done in a certain period of time. You can select \"All Time\" (default) to display all of your scans, \"Today\" to display scans done today, or you can pick a custom time range. Under \"Generate Report\" at the top right of the scan page, there is a start calendar and an end calendar. If you want to use a custom time range, tap on each calendar to pick your start date and end date respectively. It should look like so:")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("start_date")
                    .resizable()
                    .scaledToFill()
                Image("end_date")
                    .resizable()
                    .scaledToFill()
                Text("After you pick your time range, or you decided you want to pick one of the preset intervals, tap on \"Generate Report\" to see your options.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("report_menu")
                    .resizable()
                    .scaledToFill()
                Text("Let's say we generated a report from 4/20/25-4/22/25. Above your scans, you should see the report interval after \"Report\" in parentheses along with the total count of each class in the interval below it.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("report")
                    .resizable()
                    .scaledToFill()
                
                Text("Scan Feedback:")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("If you have feedback on a specific scan (e.g. the scan did not pick up a strawberry, the ripeness class seems inaccurate, etc.), tap on the scan that you want to give feedback on. It should be displayed like this:")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("image_for_feedback")
                    .resizable()
                    .scaledToFill()
                Text("At the bottom middle, there should be some text displayed: \"Have feedback? Tap here!\". Tap on the text, and it will take you to the feedback page with the image that you are writing feedback on displayed.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("feedback_view")
                    .resizable()
                    .scaledToFill()
                Text("Fill out all of the fields and click \"SUBMIT\" to submit your feedback.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                HStack(spacing: 0) {
                    Text("For other issues, ")
                    NavigationLink(value: ScanPath.support) {
                        Text("contact support")
                    }
                    
                    Text(" instead.")
                }
                .padding(.leading, 16)
                .font(.system(size: 16))
                
                Text("Tool Menu:")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("In the top right corner of the Scan page, you should see 3 dots surrounded by a circle. If you click on that icon, you should see these options displayed:")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                Image("tool_menu")
                    .resizable()
                    .scaledToFill()
                Text("\"Reverse Order\" reverses the order of your scans (newest to oldest is the default order), \"Save All Images\" saves all of your scans to your photo album, and \"Delete All Images\" deletes all of your scans.")
                    .padding(.leading, 16)
                    .font(.system(size: 16))
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if path.count > 1 {
                    Button {
                        path.removeAll()
                    } label: {
                        Image(systemName: "house.fill")
                    }
                }
            }
        }
    }
}
