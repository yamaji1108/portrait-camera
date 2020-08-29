//
//  LogoStamp.swift
//  PortraitCamera
//
//  Created by 山田拓也 on 2020/07/26.
//  Copyright © 2020 koooootake. All rights reserved.
//

import UIKit

class LogoStamp: UIImageView, UIGestureRecognizerDelegate {

    //メンバー変数の宣言
    var currentTrunsform:CGAffineTransform!
    var scale:CGFloat = 1.0
    var angle:CGFloat = 0
    var isMoving:Bool = false
    
    //ユーザーが画面にタッチした時に呼ばれるメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        //このクラスの親ビューを最前面に設定
        self.superview?.bringSubviewToFront(self)
    }
    
    //画面上で指が動いた時に呼ばれるメソッド
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //画面上のタッチ情報を取得
        let touch = touches.first!
        //画面上でドラッグしたx座標の移動距離
        let dx = touch.location(in: self.superview).x - touch.previousLocation(in: self.superview).x
        //画面上でドラッグしたy座標の移動距離
        let dy = touch.location(in: self.superview).y - touch.previousLocation(in: self.superview).y
        //このクラスの中心位置をドラッグした座標に設定
        self.center = CGPoint(x: self.center.x + dx, y: self.center.y + dy)
    }
    
    //複数のジェスチャを同時に認識させるために実装
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //自分(UIImageView(このアプリではStampクラス))が親(UIView(このアプリではViewController.swiftのcanvasView))にaddされた直後に呼び出されるメソッド
    override func didMoveToSuperview() {
        
        //ビューを回転する機能を持ったオブジェクトを格納するための変数「rotesionRecognizer」を作成する
        let rotesionRecognizer:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(LogoStamp.rotatonGesture(gesture:)))
        
        
        //デリゲートの設定
        rotesionRecognizer.delegate = self
        //ジェスチャー機能(rotesionRecognizer)を追加
        self.addGestureRecognizer(rotesionRecognizer)
        
        //ビューを拡大縮小する機能を持ったオブジェクトを格納するための変数「pinchRecognizer」を作成する
        let pinchRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(LogoStamp.pinchGesture(gesture:)))
        //デリゲートの設定
        pinchRecognizer.delegate = self
        //ジェスチャー機能(pinchRecognizer)を追加
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    //ビューを回転する機能
    @objc func rotatonGesture(gesture: UIRotationGestureRecognizer){
        print("Rotation detected!")
        
        if !isMoving && gesture.state == UIGestureRecognizer.State.began {
            isMoving = true
            currentTrunsform = self.transform
        }
        else if !isMoving && gesture.state == UIGestureRecognizer.State.ended{
            isMoving = false
            scale = 1.0
            angle = 0.0
        }
        
        angle = gesture.rotation
        
        let transform = currentTrunsform.concatenating(CGAffineTransform(rotationAngle: angle)).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        
        self.transform = transform
    }
    
    //ビューを拡大縮小する機能
    @objc func pinchGesture(gesture: UIPinchGestureRecognizer){
        print("Pinch detected!")
        
        if !isMoving && gesture.state == UIGestureRecognizer.State.began {
            isMoving = true
            currentTrunsform = self.transform
        }
        else if !isMoving && gesture.state == UIGestureRecognizer.State.ended{
            isMoving = false
            scale = 1.0
            angle = 0.0
        }
        
        scale = gesture.scale
        
        let transform = currentTrunsform.concatenating(CGAffineTransform(rotationAngle: angle)).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        
        self.transform = transform
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
