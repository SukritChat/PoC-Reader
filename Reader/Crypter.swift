//
//  Crypter.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/9/21.
//

import Foundation
import CryptoKit

protocol Crypter {
    func encrypt(with data: Data) throws -> Data?
    func decrypt(with encrypted: Data) throws -> Data
}

struct AES256Crypter: Crypter {
    
    enum Error: Swift.Error {
        case incorrectKeySize
        case incorrectParameterSize
        case nonceFailed
        case encryptedFailed
        case decryptFailed
    }
    
    private let key: SymmetricKey
    private let nonce: Data
    private var tag: Data? = nil
    
    init(key: String, iv: String, tag: String? = nil) {
        /// A key is given in hex string. The key length is 256 bits.
        /// key: An encryption key of 128, 192 or 256 bits
        self.key = try! SymmetricKey(string: key)
        
        /// nonce is initialization vector
        self.nonce = iv.data(using: .utf8)!
        
        if let tag = tag {
            /// The authentication tag
            self.tag = tag.data(using: .utf8)!
        }
    }
    
    private func seal(with data: Data) throws -> Data? {
        do {
            let sealedData = try AES.GCM.seal(data, using: key, nonce: AES.GCM.Nonce(data: nonce))
            let encrypted = sealedData.combined
            return encrypted
        } catch {
            throw Error.encryptedFailed
        }
    }
    
    private func open(with encrypted: Data) throws -> Data {
        do {
            if let tag = tag {
                let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: encrypted, tag: tag)
                let decrypted = try AES.GCM.open(sealedBox, using: key)
                return decrypted
            } else {
                /// Sort position by <nonce + encrypted>
                let combined = nonce + encrypted
                let sealedBox = try AES.GCM.SealedBox(combined: combined)
                let decrypted = try AES.GCM.open(sealedBox, using: key)
                return decrypted
            }
        } catch {
            fatalError("\(error)")
        }
    }
}

extension AES256Crypter {
    
    func encrypt(with data: Data) throws -> Data? {
        return try seal(with: data)
    }
    
    func decrypt(with encrypted: Data) throws -> Data {
        return try open(with: encrypted)
    }
}
