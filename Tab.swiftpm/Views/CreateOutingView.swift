//
//  CreateOutingView.swift
//  Tab
//

import SwiftUI
import PhotosUI
import CoreLocation
import UIKit

struct CreateOutingView: View {
    @EnvironmentObject var draft: OutingDraft
    @Binding var path: NavigationPath

    @FocusState private var isTextFieldFocused: Bool
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem?

    let icons = [
        "mappin.circle.fill",
        "fork.knife",
        "party.popper.fill",
        "cup.and.saucer.fill",
        "photo.fill.on.rectangle.fill"
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Visual Display
                        Group {
                            if let image = draft.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                                    .onTapGesture { showImagePicker = true }

                            } else if let iconName = draft.selectedIcon {
                                Image(systemName: iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))

                            } else {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .foregroundStyle(Color(red: 110/255, green: 180/255, blue: 160/255))
                            }
                        }
                        .padding(.top, 40)

                        // MARK: Icon Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(icons.indices, id: \.self) { index in
                                    let icon = icons[index]
                                    IconButton(
                                        icon: icon,
                                        isSelected: draft.selectedIcon == icon,
                                        isPhotoIcon: index == icons.count - 1
                                    ) {
                                        if index == icons.count - 1 {
                                            showImagePicker = true
                                        } else {
                                            draft.selectedIcon = icon
                                            draft.selectedImage = nil
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // MARK: Location Input
                        HStack(spacing: 10) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))

                            TextField("Enter location/outing name", text: $draft.locationName)
                                .focused($isTextFieldFocused)
                                .submitLabel(.done)
                                .font(.system(.callout, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.label))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        )
                        .padding(.horizontal)

                        // MARK: Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Outing Date")
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color(red: 70/255, green: 140/255, blue: 125/255))

                            DatePicker("", selection: $draft.outingDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        )
                        .padding(.horizontal)

                        Color.clear.frame(height: 20)
                    }
                }

                // MARK: Continue — pinned to bottom
                Button {
                    path.append("addFriends")
                } label: {
                    Text("Continue")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity, maxHeight: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 70/255, green: 140/255, blue: 125/255),
                                    Color(red: 110/255, green: 180/255, blue: 160/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .padding(.top, 12)
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("New Tab")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture { isTextFieldFocused = false }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTextFieldFocused = false }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    draft.selectedImage = image
                    draft.selectedIcon = nil
                }
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let isPhotoIcon: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? Color(red: 70/255, green: 140/255, blue: 125/255).opacity(0.2)
                          : Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color(red: 70/255, green: 140/255, blue: 125/255) : Color.clear,
                        lineWidth: 2
                    )
            )
            .foregroundStyle(
                isSelected
                ? Color(red: 70/255, green: 140/255, blue: 125/255)
                // Light mode: original teal. Dark mode: secondaryLabel for legibility
                : (colorScheme == .dark
                   ? Color(.secondaryLabel)
                   : Color(red: 70/255, green: 140/255, blue: 125/255))
            )
            .onTapGesture(perform: action)
    }
}
