// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
import SkipKit

public struct ContentView: View {
    @AppStorage("tab") var tab = Tab.chat
    @AppStorage("name") var name = "Skipper"
    @State var appearance = ""
    @State var isBeating = false

    public init() {
    }

    public var body: some View {
        TabView(selection: $tab) {
            TimelineView()
                .tabItem { Label("Timeline", systemImage: "calendar") }
                .tag(Tab.timeline)

            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble") }
                .tag(Tab.chat)

            SettingsView(appearance: $appearance)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
    }
}

enum Tab : String, Hashable {
    case timeline, chat, settings
}

struct TimelineView : View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(1..<1_000) { i in
                    NavigationLink("Item \(i)", value: i)
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: Int.self) { i in
                Text("Item \(i)")
                    .font(.title)
                    .navigationTitle("Screen \(i)")
            }
        }
    }
}

struct ChatMessage : Identifiable {
    let id: UUID = UUID()
    let imageURL: URL?
    let messageText: String?
}

struct MediaButton : View {
    let type: MediaPickerType // either .camera or .library
    @Binding var selectedImageURL: URL?
    @State private var showPicker = false

    var body: some View {
        Button(type == .camera ? "Take Photo" : "Select Media") {
            showPicker = true // activate the media picker
        }
        .withMediaPicker(type: .camera, isPresented: $showPicker, selectedImageURL: $selectedImageURL)
    }
}


struct ChatView : View {
    @State var message: String = ""
    @State var error: Error? = nil

    @State private var selectedImageURL: URL?
    @State private var showingPhotoPicker = false
    @State private var showingMediaPicker = false

    @State var messages: [ChatMessage] = []

    var body: some View {
        VStack {
            List {
                Section {
                    Text("Chat")
                        .font(.largeTitle)

                    ForEach(messages) { message in
                        if let imageURL = message.imageURL {
                            AsyncImage(url: imageURL) {
                                $0.image?.resizable().aspectRatio(contentMode: .fit)
                            }
                        }

                        if let messageText = message.messageText {
                            Text(messageText)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            if let error = error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
            }

            MessageEntryField()
                .padding(.bottom, 50)
                .onChange(of: selectedImageURL) { imageURL in
                    // whenever we have added a new image, create a new message with the image and clear the current image URL
                    addImageURL(imageURL: imageURL)
                }
        }
    }

    func MessageEntryField() -> some View {
        HStack {
            Button {
                logger.log("take photo")
                self.showingPhotoPicker = true
            } label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel(Text("Button to take a photo for the message"))
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .padding(2.0)
            .withMediaPicker(type: .camera, isPresented: $showingPhotoPicker, selectedImageURL: $selectedImageURL)

            Button {
                logger.log("select media")
                self.showingMediaPicker = true
            } label: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel(Text("Button to select picture from media library for the message"))
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .padding(2.0)
            .withMediaPicker(type: .library, isPresented: $showingMediaPicker, selectedImageURL: $selectedImageURL)

            TextField("Chat", text: $message, prompt: Text("Enter chat message"))
                .textFieldStyle(.plain)
                .lineLimit(1)
                .font(.body)
                //.padding(0.0)
                //.frame(height: 40.0) // FIXME: default vertical padding in Android makes the text invisible
                .onSubmit {
                    addTextMessage()
                }

            Button {
                logger.log("send message")
                addTextMessage()
            } label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel(Text("Button to send the current message"))
            }
            .buttonStyle(.plain)
            .rotationEffect(.degrees(45.0))
            .frame(width: 28, height: 28)
            .padding(2.0)
            .disabled(message.isEmpty)
        }
        .padding(.horizontal, 8.0)
        //.frame(height: 40.0)
        .padding(.vertical, 4.0)
        .border(.gray, width: 1.0)
        .padding(.horizontal, 4.0)
    }

    func addTextMessage() {
        if self.message.isEmpty == false {
            self.messages.append(ChatMessage(imageURL: nil, messageText: self.message))
            self.message = ""
        }
    }

    /// Adds the given image URL to the chat list
    func addImageURL(imageURL: URL?) {
        if let imageURL = imageURL {
            self.selectedImageURL = nil // clear the URL
            self.messages.append(ChatMessage(imageURL: imageURL, messageText: nil))
        }
    }
}

struct SettingsView : View {
    @Binding var appearance: String

    var body: some View {
        NavigationStack {
            Form {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
