//
//  DownloadManager.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/9/21.
//

import SwiftUI

protocol DownloadManagerDelegate {
    func didFinished(success: Bool)
    func didFailed(failure: Bool)
    func inProgress(progress: Float, totalBytesWritten: Float, totalBytesExpectedToWrite: Float)
}

class DownloadManager: NSObject, ObservableObject {
    
    enum FileExtension: String {
        case pdf = "pdf"
        case epub = "epub"
    }
    
    static let shared = DownloadManager()
    
    var delegate: DownloadManagerDelegate?
    
    private var fileUrl: URL?
    private var downloadTask: URLSessionDownloadTask!
    
    func download(with fileUrl: URL, type: FileExtension = .pdf) {
        self.fileUrl = fileUrl.appendingPathExtension(type.rawValue)
        
        let configuration = URLSessionConfiguration.default
        configuration.sessionSendsLaunchEvents = true
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        if downloadTask?.state == .running {
            downloadTask?.cancel()
        }
        
        downloadTask = session.downloadTask(with: fileUrl)
        print("[reader] download \(fileUrl.absoluteString)")
        downloadTask?.resume()
    }
    
    func exist(with filename: String, type: FileExtension = .pdf) -> Bool {
        guard let directoryUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileUrl = directoryUrl.appendingPathComponent(filename).appendingPathExtension(type.rawValue)
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    func read(with filename: String, type: FileExtension = .pdf) -> Data? {
        guard let directoryUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileUrl = directoryUrl.appendingPathComponent(filename).appendingPathExtension(type.rawValue)
        guard FileManager.default.fileExists(atPath: fileUrl.path) else { return nil }
        
        do {
            return try Data(contentsOf: fileUrl)
        } catch {
            return nil
        }
    }
    
    func remove(with filename: String, type: FileExtension = .pdf) -> Bool {
        guard let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileUrl = directoryUrl.appendingPathComponent(filename).appendingPathExtension(type.rawValue)
        print("[reader] remove \(fileUrl.absoluteString)")
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(atPath: fileUrl.path)
            print("File is removed")
            return true
        } catch {
            print("Failed to removing file: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeAll() -> Bool {
        guard let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            for fileURL in fileUrls {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            return true
        } catch {
            print("Failed to removing files: \(error.localizedDescription)")
            return false
        }
    }
    
    func bundle(with filename: String, type: FileExtension = .pdf) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: type.rawValue) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let directoryUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        if let url = fileUrl, let directoryUrl = directoryUrl {
            let destinationFileUrl = directoryUrl.appendingPathComponent(url.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                    let replaceItemAtDestinationFileUrl = try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: location)
                    print("Replace item at path: \(String(describing: replaceItemAtDestinationFileUrl?.path))")
                } else {
                    try FileManager.default.moveItem(at: location, to: destinationFileUrl)
                }
                
                print("Downloaded file path: \(destinationFileUrl.path)")
                delegate?.didFinished(success: true)
            } catch {
                print("Failed moving directory: \(error.localizedDescription)")
                delegate?.didFailed(failure: true)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Task completed: \(task), error: \(String(describing: error?.localizedDescription))")
        
        if error != nil {
            delegate?.didFailed(failure: true)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            if totalBytesExpectedToWrite > 0 {
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                print("Download progress: \(progress)")
                self.delegate?.inProgress(progress: progress, totalBytesWritten: Float(totalBytesWritten) , totalBytesExpectedToWrite: Float(totalBytesExpectedToWrite))
            }
        }
    }
}
