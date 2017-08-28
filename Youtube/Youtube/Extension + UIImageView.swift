//
//  Extension + UIImageView.swift
//  Youtube
//
//  Created by MAC on 8/25/17.
//  Copyright © 2017 example.com. All rights reserved.


import UIKit
import Kingfisher

extension UIImageView {
    func tmSetImage(url: String, placeHolder: UIImage? = UIImage(color: UIColor(hexString: "D2FFFF")!) ) {
        if url.isEmpty {
            image = placeHolder
            return
        }
        
        if let urlString = url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed), let urlResource = URL(string: urlString) {
            kf.setImage(with: urlResource, placeholder: placeHolder, options: [.transition(.fade(0.5)), .onlyLoadFirstFrame], progressBlock: nil, completionHandler: nil)
        } else {
            debugPrint("LOAD IMAGE FAIL: \(url)")
        }
    }
    
    
}
extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
