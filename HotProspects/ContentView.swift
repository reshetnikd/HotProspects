//
//  ContentView.swift
//  HotProspects
//
//  Created by Dmitry Reshetnik on 26.03.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import SwiftUI

class User: ObservableObject {
    @Published var name = "Taylor Swift"
}

struct EditView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        TextField("Name", text: $user.name)
    }
}

struct DisplayView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        Text(user.name)
    }
}

class DelayedUpdater: ObservableObject {
    var value = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    init() {
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
}

enum NetworkError: Error {
    case badURL, requestFailed, unknown
}

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject var updater = DelayedUpdater()
    
    let user = User()
    
    var body: some View {
//        Text("Value is: \(updater.value)")
        Image("example")
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
//        VStack {
//            EditView()
//            DisplayView()
//        }
//        .environmentObject(user)
//        TabView(selection: $selectedTab) {
//            Text("Tab 1")
//                .onTapGesture {
//                    self.selectedTab = 1
//                }
//                .tabItem {
//                    Image(systemName: "star")
//                    Text("One")
//                }
//                .tag(0)
//
//            Text("Tab 2")
//                .tabItem {
//                    Image(systemName: "star.fill")
//                    Text("Two")
//                }
//                .tag(1)
//        }
//        Text("Hello, World!")
//            .onAppear {
//                self.fetchData(from: "https://www.apple.com") { result in
//                    switch result {
//                    case .success(let str):
//                        print(str)
//                    case .failure(let error):
//                        switch error {
//                        case .badURL:
//                            print("Bad URL")
//                        case .requestFailed:
//                            print("Network problems")
//                        case .unknown:
//                            print("Unknown error")
//                        }
//                    }
//                }
//            }
    }
    
    func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        // check the URL is OK, otherwise return with a failure
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // the task has completed - push our work back to the main thread
            DispatchQueue.main.async {
                if let data = data {
                    // success: convert the data to a string and send it back
                    let stringData = String(decoding: data, as: UTF8.self)
                    completion(.success(stringData))
                } else if error != nil {
                    // any sort of network failure
                    completion(.failure(.requestFailed))
                } else {
                    // this ought not to be possible, yet here we are
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
