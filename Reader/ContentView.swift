//
//  ContentView.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/9/21.
//

import SwiftUI
import PDFViewer

struct ContentView: View, DownloadManagerDelegate {
    
    func didFailed(failure: Bool) {
        print("[Log] didFailed: \(failure)")
    }
    
    func didFinished(success: Bool) {
        print("[Log] didFinished: \(success)")
    }
    
    func inProgress(progress: Float, totalBytesWritten: Float, totalBytesExpectedToWrite: Float) {
        inProgress = (progress * 100).rounded()
    }
    
    static let filename = "8edaf63d470427fb87c754a0fe88f1218e9fb948039352efa6599f18e36f0b44"
    static let path = "2022/8/3/\(filename)"

    let key = "LELG6W6nH2zUzGq6ZUZC7CbnGaGPL2PR"
    let iv = "qqZ76twqHHEL"

    @State private var url: String = "https://cdn-ebook.dek-d.com/\(path)"
    @State private var inProgress: Float = .zero
    @State var data: Data?
            
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack(alignment: .center) {
                        TextField("User name (email address)", text: $url)
                        
                        HStack(spacing: 20) {
                            Button("Download pdf") {
                                /// url expired in 10 mins
                                let manager = DownloadManager.shared
                                manager.delegate = self
                                manager.download(with: URL(string: url)!, type: .pdf)
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Download epub") {
                                /// url expired in 10 mins
                                let manager = DownloadManager.shared
                                manager.delegate = self
                                manager.download(with: URL(string: url)!, type: .epub)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                    }
                    .padding()
                    
                    Text(inProgress.description + " %")
                    
                    HStack {
                        Button("Encrypt") {
                            if let data = data, let encrypted = encrypt(data: data) {
                                self.data = encrypted
                            }
                        }
                        
                        Divider()
                        
                        Button("Decrypt") {
                            let encrpyted = DownloadManager.shared.read(with: Self.filename)
                            if let encrpyted = encrpyted {
                                self.data = decrypt(data: encrpyted)
                            }
                        }
                    }
                    
                    Divider()

                    HStack {
                        Button("Remove") {
                            let acknowledged = DownloadManager.shared.remove(with: Self.filename)
                            self.data = nil
                            print("File removed is \(acknowledged)")
                        }
                        
                        Divider()
                        
                        Button("Remove all") {
                            let acknowledged = DownloadManager.shared.removeAll()
                            self.data = nil
                            print("All file removed is \(acknowledged)")
                        }
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: {
                        if let decrypted = data {
                            PDFKitView(data: decrypted)
                        }
                    }, label: {
                        Text("Read")
                    })
                }
            }
            .navigationBarTitle("Reader", displayMode: .automatic)
            .preferredColorScheme(.dark)
        }
    }
        
    func encrypt(data: Data) -> Data? {
        let cryper = AES256Crypter(key: key, iv: iv)
        
        do {
            let encryptedData = try cryper.encrypt(with: data)
            return encryptedData
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func decrypt(data: Data) -> Data {
        let cryper = AES256Crypter(key: key, iv: iv)

        do {
            let decrypted = try cryper.decrypt(with: data)
            return decrypted
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
