//
//  UIView+EX.swift
//  PortraitCamera
//
//  Created by 山田拓也 on 2020/05/08.
//  Copyright © 2020 koooootake. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(false)
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let png = image.pngData()!
        let pngImage = UIImage.init(data: png)!
        return pngImage
    }
}
