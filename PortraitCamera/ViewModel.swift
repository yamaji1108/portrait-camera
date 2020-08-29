//
//  ViewModel.swift
//  Portrait
//
//  Created by Rina Kotake on 2019/03/10.
//  Copyright © 2019 koooootake. All rights reserved.
//

import UIKit

class ViewModel {
    var status: Status
    enum Status {
        case load
        case segment
        case collageFor3
        case collageFor4
        case result
        case collageResult
        case dof
    }

    var isHiddenHomeButton = false
    var isHiddenCollageButton = false
    var isHiddenCameraButton = false
    var isHiddenImagePickerButton = false
    var isHiddenSourceImageView = false
    var isHiddenRetouchSegment = false
    var isHiddenSegmentView = true
    var isHiddenCollageBackView = true
    var isHiddenCollageImageView1 = true
    var isHiddenCollageImageView2 = true
    var isHiddenCollageImageView3 = true
    var isHiddenCollageImageView4 = true
    var isHiddenCollageImageView5 = true
    var isHiddenCollageBKImageView1 = true
    var isHiddenCollageBKImageView2 = true
    var isHiddenCollageBKImageView3 = true
    var isHiddenCollageBKImageView4 = true
    var isHiddenCollageBKImageView5 = true
    var isHiddenCropImageView = false
    var isHiddenResultImageView = true
    var isHiddenGradientView = true
    var isHiddenLogoDeleteButton = true
    var navigationTitle = ""
    var viewBackgroundColor = UIColor(named: "GGray")!

    init() {
        status = .load
    }

    func reload(status: Status) {
        switch status {
        case .load:
            isHiddenSourceImageView = false
            isHiddenSegmentView = true
            isHiddenResultImageView = true
            isHiddenGradientView = true
            isHiddenRetouchSegment = false
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GGray")!
        
        case .collageFor3:
            isHiddenHomeButton = true
            isHiddenCollageButton = true
            isHiddenCameraButton = true
            isHiddenImagePickerButton = true
            isHiddenSourceImageView = true
            isHiddenSegmentView = true
            isHiddenResultImageView = true
            isHiddenGradientView = true
            isHiddenRetouchSegment = true
            isHiddenCollageBackView = true
            isHiddenCollageImageView1 = true
            isHiddenCollageImageView2 = true
            isHiddenCollageImageView3 = false
            isHiddenCollageImageView4 = false
            isHiddenCollageImageView5 = false
            isHiddenCollageBKImageView1 = true
            isHiddenCollageBKImageView2 = true
            isHiddenCollageBKImageView3 = false
            isHiddenCollageBKImageView4 = false
            isHiddenCollageBKImageView5 = false
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GGray")!
        
        case .collageFor4:
            isHiddenHomeButton = true
            isHiddenCollageButton = true
            isHiddenCameraButton = true
            isHiddenImagePickerButton = true
            isHiddenSourceImageView = true
            isHiddenSegmentView = true
            isHiddenResultImageView = true
            isHiddenGradientView = true
            isHiddenRetouchSegment = true
            isHiddenCollageBackView = true
            isHiddenCollageImageView1 = false
            isHiddenCollageImageView2 = false
            isHiddenCollageImageView3 = false
            isHiddenCollageImageView4 = false
            isHiddenCollageImageView5 = true
            isHiddenCollageBKImageView1 = false
            isHiddenCollageBKImageView2 = false
            isHiddenCollageBKImageView3 = false
            isHiddenCollageBKImageView4 = false
            isHiddenCollageBKImageView5 = true
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GGray")!
            
        case .segment:
            isHiddenHomeButton = true
            isHiddenCollageButton = true
            isHiddenCameraButton = true
            isHiddenImagePickerButton = true
            isHiddenSegmentView = false
            isHiddenResultImageView = true
            isHiddenGradientView = true
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GBlue")!

        case .result:
            isHiddenHomeButton = false
            isHiddenCollageButton = true
            isHiddenCameraButton = true
            isHiddenImagePickerButton = true
            isHiddenSourceImageView = true
            isHiddenSegmentView = true
            isHiddenResultImageView = false
            isHiddenGradientView = true
            isHiddenRetouchSegment = true
            isHiddenCollageBackView = true
            isHiddenCollageImageView1 = true
            isHiddenCollageImageView2 = true
            isHiddenCollageImageView3 = true
            isHiddenCollageImageView4 = true
            isHiddenCollageImageView5 = true
            isHiddenCollageBKImageView1 = true
            isHiddenCollageBKImageView2 = true
            isHiddenCollageBKImageView3 = true
            isHiddenCollageBKImageView4 = true
            isHiddenCollageBKImageView5 = true
            isHiddenCropImageView = true
            isHiddenLogoDeleteButton = false
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GGray")!
            
        case .collageResult:
            isHiddenHomeButton = false
            isHiddenSegmentView = true
            isHiddenResultImageView = false
            isHiddenGradientView = true
            isHiddenCollageBackView = true
            isHiddenCollageImageView1 = true
            isHiddenCollageImageView2 = true
            isHiddenCollageImageView3 = true
            isHiddenCollageImageView4 = true
            isHiddenCollageImageView5 = true
            isHiddenCollageBKImageView1 = true
            isHiddenCollageBKImageView2 = true
            isHiddenCollageBKImageView3 = true
            isHiddenCollageBKImageView4 = true
            isHiddenCollageBKImageView5 = true
            isHiddenLogoDeleteButton = false
            navigationTitle = ""
            viewBackgroundColor = UIColor(named: "GGray")!

        case .dof:
            isHiddenSegmentView = true
            isHiddenResultImageView = true
            isHiddenGradientView = false
            navigationTitle = "DOF"
            viewBackgroundColor = UIColor(named: "GYellow")!
        }
    }
}
