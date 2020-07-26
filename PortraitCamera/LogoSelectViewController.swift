//
//  LogoSelectViewController.swift
//  PortraitCamera
//
//  Created by 山田拓也 on 2020/07/19.
//  Copyright © 2020 koooootake. All rights reserved.
//

import UIKit

class LogoSelectViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate {
    
    var imageArray:[UIImage] = []
    @IBOutlet weak var CollectionView1: UICollectionView!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        let cellWidth = floor(self.view.frame.width * 0.8)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth/2)
        CollectionView1.collectionViewLayout = layout
        collectionViewWidthConstraint.constant = cellWidth + 30
        collectionViewHeightConstraint.constant = cellWidth * 4 + 40
        
        //配列imageArrayに1〜6.pngの画像データを格納
        for i in 1...3{
            imageArray.append(UIImage(named: "logoImage\(i).png")!)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //戻り値にimageArrayの要素数を設定
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //UICollectionViewCellを使うための変数を作成
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        //セルのなかの画像を表示するImageViewのタグを指定
        let imageView = cell.viewWithTag(1) as! UIImageView
        //セルの中のImage Viewに配列の中の画像データを表示
        imageView.image = imageArray[indexPath.row]
        //設定したセルを戻り値にする
        return cell
    }
    
    //コレクションビューのセルが選択された時のメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Stampインスタンスを作成
        let stamp = LogoStamp()
        //stampにインデックスパスからスタンプ画像を設定
        stamp.image = imageArray[indexPath.row]
        //AppDelegateのインスタンスを取得
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //配列stampArrayにstampを追加
        appDelegate.stampArray.append(stamp)
        //新規スタンプ追加フラグをtrueに設定
        appDelegate.isNewStampAdded = true
        //スタンプ選択画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    //スタンプ選択画面を閉じるメソッド
    @IBAction func closeTapped(){
        //モーダルで表示した画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
