//
//  SymmetricKeyExtension.swift
//  Reader
//
//  Created by Suwat Saegauy on 11/24/21.
//

import Foundation
import CryptoKit

extension SymmetricKey {
    
    init(string keyString: String, size: SymmetricKeySize = .bits256) throws {
        guard var keyData = keyString.data(using: .utf8) else {
            print("Could not create base64 encoded Data from String.")
            throw CryptoKitError.incorrectParameterSize
        }
        
        /// Bytes: 256 bits / 8 bits = 32 bytes
        let keySizeBytes = size.bitCount / 8
        keyData = keyData.subdata(in: 0..<keySizeBytes)
        
        guard keyData.count >= keySizeBytes else {
            throw CryptoKitError.incorrectKeySize
        }
        
        self.init(data: keyData)
    }
}
