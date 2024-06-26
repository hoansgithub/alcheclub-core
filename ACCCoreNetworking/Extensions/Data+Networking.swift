//
//  Data+Networking.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation

extension Data {
    var mimeType: String {
        switch mimeUInt {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        default:
            return "image/jpeg"
        }
    }

    var fileExtension: String {
        switch mimeUInt {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49, 0x4D:
            return "tiff"
        default:
            return "jpg"
        }
    }

    private var mimeUInt: UInt8 {
        var values = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &values, count: 1)
        return values.first ?? 0
    }
}
