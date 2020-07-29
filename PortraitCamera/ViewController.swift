//
//  ViewController.swift
//  Portrait
//
//  Created by Rina Kotake on 2018/12/01.
//  Copyright © 2018年 koooootake. All rights reserved.
//

import UIKit
import CropViewController
import AVFoundation
import DKImagePickerController
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    let kGradientLayerName = "Gradient"
    
    var viewModel: ViewModel = ViewModel()
    
    //フラグ　0:加工　1:コラージュ
    var retouchFlug: Int = 0
    
    //スタンプ画像を配置するUIView
    @IBOutlet var canvasView: UIView!
    //AppDelegateを使うための変数
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //base
    @IBOutlet weak var imageSizeLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var sampleImageView: UIImageView!
    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var retouchSegment: UISegmentedControl!
    
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var collageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerButton: UIBarButtonItem!
    
    
    //collage
    var imageArray:[UIImage] = []
    @IBOutlet weak var collageBackView: UIImageView!
    @IBOutlet weak var collageImageView1: UIImageView!
    @IBOutlet weak var collageImageView2: UIImageView!
    @IBOutlet weak var collageImageView3: UIImageView!
    @IBOutlet weak var collageImageView4: UIImageView!
    @IBOutlet weak var collageImageView5: UIImageView!
    @IBOutlet weak var collageBKImageView1: UIImageView!
    @IBOutlet weak var collageBKImageView2: UIImageView!
    @IBOutlet weak var collageBKImageView3: UIImageView!
    @IBOutlet weak var collageBKImageView4: UIImageView!
    @IBOutlet weak var collageBKImageView5: UIImageView!
    private var myBoundSize: CGSize?
    private var upperLeftRect: CGRect?
    private var upperRightRect: CGRect?
    private var lowerLeftRect: CGRect?
    private var lowerRightRect: CGRect?
    private var upperRect: CGRect?
    
    //camera
    
    //segment
    private var selectedRect: CGRect?
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var drawPenSizeSlider: UISlider!
    
    //result
    private var resultImage: UIImage?
    private var blurWithoutGradientImage: UIImage?
    private var inpaintingImage: UIImage?
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var comparesourceButton: UIButton!
    @IBOutlet weak var brightnessValueSlider: UISlider!
    @IBOutlet weak var contrastValueSlider: UISlider!
    @IBOutlet weak var saturationValueSlider: UISlider!
    
    //dof
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var gradientAdjustView: UIView!
    private var startPoint: CGPoint?
    private var endPoint: CGPoint?
    private var startView: GradientAdjustPointView?
    private var endView: GradientAdjustPointView?
    private let pointSize = CGSize(width: 50, height: 50)
    
    //editView
    @IBOutlet weak var indicatorBaseView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet var segmentEditView: UIView!
    @IBOutlet var collageEditView: UIView!
    @IBOutlet var resultEditView: UIView!
    @IBOutlet var collageResultEditView: UIView!
    @IBOutlet var dofEditView: UIView!
    @IBOutlet weak var safeAreaView: UIView!
    
    private lazy var tapFeedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()
    
    //画面表示の直前に呼ばれるメソッド
    override func viewWillAppear(_ animated: Bool) {
        //viewWillAppearを上書きするときに必要な処理
        super.viewWillAppear(animated)
        //新規スタンプ画像フラグがtrueの場合、実行する処理
        if appDelegate.isNewStampAdded == true {
            //imageArrayの最後に入っている要素を取得
            let stamp = appDelegate.stampArray.last!
            //スタンプのフレームを設定
            stamp.frame = CGRectMake(0, 0, 200, 100)
            //スタンプの設置座標を写真画像の中心に設定
            stamp.center = resultImageView.center
            //スタンプのタッチ操作を許可
            stamp.isUserInteractionEnabled = true
            //スタンプを自分で配置したViewに設置
            canvasView.addSubview(stamp)
            //新規スタンプ画像フラグをfalseに設定
            appDelegate.isNewStampAdded = false
        }
    }
    //CGRectMake関数
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload(status: .load)
        setupIndicatorBaseView()
    }
    
    private func setupIndicatorBaseView() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = indicatorBaseView.bounds
        indicatorBaseView.addSubview(visualEffectView)
        indicatorBaseView.layer.cornerRadius = 4
        indicatorBaseView.layer.masksToBounds = true
        indicatorBaseView.bringSubviewToFront(indicatorView)
        indicatorBaseView.alpha = 0
        
        //コラージュ用の画面位置を設定
        myBoundSize = self.view.bounds.size
        upperLeftRect = CGRect(x:0,y:88,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        upperRightRect =  CGRect(x:(myBoundSize!.width)/2,y:88,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        lowerLeftRect = CGRect(x:0,y:88+(myBoundSize!.width)/2,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        lowerRightRect = CGRect(x:(myBoundSize!.width)/2,y:88+(myBoundSize!.width)/2,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        upperRect = CGRect(x:0,y:88,width:myBoundSize!.width,height:(myBoundSize!.width)/2)
        
        
        collageBackView.frame = CGRect(x:0,y:0,width:myBoundSize!.width,height:myBoundSize!.width)
        
        
        collageImageView1.frame = upperLeftRect!
        collageImageView2.frame = upperRightRect!
        collageImageView3.frame = lowerLeftRect!
        collageImageView4.frame = lowerRightRect!
        collageImageView5.frame = upperRect!
        
        collageBKImageView1.frame = CGRect(x:0,y:24,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        collageBKImageView2.frame = CGRect(x:(myBoundSize!.width)/2,y:24,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        collageBKImageView3.frame = CGRect(x:0,y:24+(myBoundSize!.width)/2,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        collageBKImageView4.frame = CGRect(x:(myBoundSize!.width)/2,y:24+(myBoundSize!.width)/2,width:(myBoundSize!.width)/2,height:(myBoundSize!.width)/2)
        collageBKImageView5.frame = CGRect(x:0,y:24,width:myBoundSize!.width,height:(myBoundSize!.width)/2)
        
        // タッチ操作を enable
        collageImageView1.isUserInteractionEnabled = true
        self.view.addSubview(collageImageView1)
        collageImageView2.isUserInteractionEnabled = true
        self.view.addSubview(collageImageView2)
        collageImageView3.isUserInteractionEnabled = true
        self.view.addSubview(collageImageView3)
        collageImageView4.isUserInteractionEnabled = true
        self.view.addSubview(collageImageView4)
        collageImageView5.isUserInteractionEnabled = true
        self.view.addSubview(collageImageView5)
        
    }
    
    private func reload(status: ViewModel.Status) {
        viewModel.reload(status: status)
        sourceImageView.isHidden = viewModel.isHiddenSourceImageView
        maskImageView.isHidden = viewModel.isHiddenSegmentView
        retouchSegment.isHidden = viewModel.isHiddenRetouchSegment
        collageBackView.isHidden = viewModel.isHiddenCollageBackView
        collageImageView1.isHidden = viewModel.isHiddenCollageImageView1
        collageImageView2.isHidden = viewModel.isHiddenCollageImageView2
        collageImageView3.isHidden = viewModel.isHiddenCollageImageView3
        collageImageView4.isHidden = viewModel.isHiddenCollageImageView4
        collageImageView5.isHidden = viewModel.isHiddenCollageImageView5
        collageBKImageView1.isHidden = viewModel.isHiddenCollageBKImageView1
        collageBKImageView2.isHidden = viewModel.isHiddenCollageBKImageView2
        collageBKImageView3.isHidden = viewModel.isHiddenCollageBKImageView3
        collageBKImageView4.isHidden = viewModel.isHiddenCollageBKImageView4
        collageBKImageView5.isHidden = viewModel.isHiddenCollageBKImageView5
        cropImageView.isHidden = viewModel.isHiddenCropImageView
        resultImageView.isHidden = viewModel.isHiddenResultImageView
        gradientAdjustView.isHidden = viewModel.isHiddenGradientView
        gradientView.isHidden = viewModel.isHiddenGradientView
        navigationItem.title = viewModel.navigationTitle
        safeAreaView.backgroundColor = viewModel.viewBackgroundColor
        
        for view in editView.subviews {
            view.removeFromSuperview()
        }
        
        let editContentView: UIView
        switch status {
        case .load:
            //バーボタン系を表示
            homeButton.isEnabled = true
            homeButton.tintColor = UIColor.init(red: 0/255, green: 151/255, blue: 219/255, alpha: 255/255)
            collageButton.isEnabled = true
            collageButton.tintColor = nil
            cameraButton.isEnabled = true
            cameraButton.tintColor = nil
            imagePickerButton.isEnabled = true
            imagePickerButton.tintColor = nil
            return
        case .segment:
            editContentView = segmentEditView
            //バーボタン系は非表示
            homeButton.isEnabled = false
            homeButton.tintColor = UIColor.clear
            collageButton.isEnabled = false
            collageButton.tintColor = UIColor.clear
            cameraButton.isEnabled = false
            cameraButton.tintColor = UIColor.clear
            imagePickerButton.isEnabled = false
            imagePickerButton.tintColor = UIColor.clear
        case .collageFor3:
            editContentView = collageEditView
            //バーボタン系は非表示
            homeButton.isEnabled = false
            homeButton.tintColor = UIColor.clear
            collageButton.isEnabled = false
            collageButton.tintColor = UIColor.clear
            cameraButton.isEnabled = false
            cameraButton.tintColor = UIColor.clear
            imagePickerButton.isEnabled = false
            imagePickerButton.tintColor = UIColor.clear
            //使用しないviewのタッチ操作を無効にする
            collageImageView1.isUserInteractionEnabled = false
            collageImageView2.isUserInteractionEnabled = false
        case .collageFor4:
            editContentView = collageEditView
            //バーボタン系は非表示
            homeButton.isEnabled = false
            homeButton.tintColor = UIColor.clear
            collageButton.isEnabled = false
            collageButton.tintColor = UIColor.clear
            cameraButton.isEnabled = false
            cameraButton.tintColor = UIColor.clear
            imagePickerButton.isEnabled = false
            imagePickerButton.tintColor = UIColor.clear
            //使用しないviewのタッチ操作を無効にする
            collageImageView5.isUserInteractionEnabled = false
        case .result:
            editContentView = resultEditView
            //ホームボタンは表示
            homeButton.isEnabled = true
            homeButton.tintColor = UIColor.init(red: 0/255, green: 151/255, blue: 219/255, alpha: 255/255)
            collageButton.isEnabled = false
            collageButton.tintColor = UIColor.clear
            cameraButton.isEnabled = false
            cameraButton.tintColor = UIColor.clear
            imagePickerButton.isEnabled = false
            imagePickerButton.tintColor = UIColor.clear
        case .collageResult:
            editContentView = collageResultEditView
            //ホームボタンは表示
            homeButton.isEnabled = true
            homeButton.tintColor = UIColor.init(red: 0/255, green: 151/255, blue: 219/255, alpha: 255/255)
            collageButton.isEnabled = false
            collageButton.tintColor = UIColor.clear
            cameraButton.isEnabled = false
            cameraButton.tintColor = UIColor.clear
            imagePickerButton.isEnabled = false
            imagePickerButton.tintColor = UIColor.clear
            //配列は空にする
            self.imageArray.removeAll()
        case .dof:
            editContentView = dofEditView
        }
        
        editView.addSubview(editContentView)
        editView.addConstraintsFitParentView(editContentView)
    }
    
    private func reset() {
        resetDraw()
        gradientView.layer.sublayers = nil
        reload(status: .load)
    }
    
    private func resetDraw() {
        //drawImageView.reset()
        OpenCVManager.shared()?.resetManager()
    }
    
    private func startLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        indicatorView.startAnimating()
        indicatorBaseView.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.indicatorBaseView.alpha = 1
        })
    }
    
    private func stopLoading() {
        UIApplication.shared.endIgnoringInteractionEvents()
        UIView.animate(withDuration: 0.3, animations: {
            self.indicatorBaseView.alpha = 0
        }, completion: { _ in
            self.indicatorView.stopAnimating()
            self.indicatorBaseView.isHidden = true
        })
    }
}

///1. 画像取得
extension ViewController {
    
    @IBAction func CameraButtonDidTap(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //フラグを0に
            self.retouchFlug = 0
            //加工調節スライダーを初期値（5）に設定
            brightnessValueSlider.value = 5
            contrastValueSlider.value = 5
            saturationValueSlider.value = 5
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            UIAlertController.show(title: "カメラの利用が許可されていません🌃", message: nil)
        }
    }
    
    
    @IBAction func imagePickerButtonDidTap(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //フラグを0に
            self.retouchFlug = 0
            //加工調節スライダーを初期値（5）に設定
            brightnessValueSlider.value = 5
            contrastValueSlider.value = 5
            saturationValueSlider.value = 5
            let pickerC = UIImagePickerController()
            pickerC.sourceType = .photoLibrary
            pickerC.delegate = self
            present(pickerC, animated: true, completion: nil)
        } else {
            UIAlertController.show(title: "フォトライブラリの利用が許可されていません🌃", message: nil)
        }
    }
    
    @IBAction func homeButtonDidTap(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //加工調節スライダーを初期値（5）に設定
            brightnessValueSlider.value = 5
            contrastValueSlider.value = 5
            saturationValueSlider.value = 5
            
            //タイトルへ戻る
            super.viewDidLoad()
            self.reload(status: .load)
            self.setupIndicatorBaseView()
            self.sourceImageView.image = UIImage(named:"title")
        }
            
            
    }
    
    private func showCropViewController(image: UIImage) {
        let cropVC = CropViewController(image: image)
        cropVC.rotateButtonsHidden = true
        cropVC.title = "Rough outline of the subject"
        cropVC.delegate = self
        if let selectedRect = selectedRect {
            cropVC.imageCropFrame = selectedRect
        } else {
            cropVC.aspectRatioPreset = .presetSquare
        }
        present(cropVC, animated: true, completion: nil)
    }
    
    //コラージュボタンを押下したときの処理
    @IBAction func collageButtonDidtap(sender: AnyObject) {
        //フラグを1に
        self.retouchFlug = 1
        self.pickImages()
        
        // 要素を3つ取得するまで待ちます
        wait( { self.imageArray.count < 3 } ) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // 0.2秒後に実行したい処理
                if self.imageArray.count == 3 {
                    self.collageImageView5.image = self.imageArray[0]
                    self.collageImageView3.image = self.imageArray[1]
                    self.collageImageView4.image = self.imageArray[2]
                    self.reload(status: .collageFor3)
                } else {
                    self.collageImageView1.image = self.imageArray[0]
                    self.collageImageView2.image = self.imageArray[1]
                    self.collageImageView3.image = self.imageArray[2]
                    self.collageImageView4.image = self.imageArray[3]
                    self.reload(status: .collageFor4)
                }
            }
        }
        
//        // dataを取得するまで待ちます
//        wait( { self.imageArray.count < 4 } ) {
//            self.collageImageView1.image = self.imageArray[0]
//            self.collageImageView2.image = self.imageArray[1]
//            self.collageImageView3.image = self.imageArray[2]
//            self.collageImageView4.image = self.imageArray[3]
//            self.reload(status: .collage)
//        }
    }
    
    // 写真を選択する
    func pickImages() {
        let picker = DKImagePickerController()
        //選択できる写真の最大数を指定
        picker.maxSelectableCount = 4
        //カメラモード、写真モードの選択
        picker.sourceType = .photo
        //キャンセルボタンの有効化
        picker.showsCancelButton = true
        //UIのカスタマイズ
        picker.UIDelegate = CustomUIDelegate()
        picker.didSelectAssets = { (assets: [DKAsset]) in
            for asset in assets {
                asset.fetchFullScreenImage(completeBlock: { (image, info) in
                    self.imageArray.append(image!)
                })
            }
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    /// 条件をクリアするまで待つ関数
    ///
    /// - Parameters:
    ///   - waitContinuation: 待機条件
    ///   - compleation: 通過後の処理
    private func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            assertionFailure()
            return
        }
//        //画像サイズ縮小
//        let maxSize: CGFloat = 1280
//        let imageMaxSize = max(image.size.width, image.size.height)
//        let scale = imageMaxSize > maxSize ? maxSize / imageMaxSize : 1
//        let resizeImg = image.scale(ratio: scale)
        sourceImageView.image = image
        imageSizeLabel.text = "\(Int(image.size.width)) x \(Int(image.size.height))"
        selectedRect = nil
        reset()
        self.dismiss(animated: true, completion: {
            self.showCropViewController(image: image)
        })
    }
}

extension ViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        selectedRect = rect
        resetDraw()
        startLoading()
        cropViewController.dismiss(animated: true, completion: {
            //self.doGrabCut()
//            self.backgroundToWhite(brightnessValue: self.brightnessValueSlider.value, contrastValue: self.contrastValueSlider.value, saturationValue: self.saturationValueSlider.value)
            self.retouch(brightnessValue: self.brightnessValueSlider.value, contrastValue: self.contrastValueSlider.value, saturationValue: self.saturationValueSlider.value)
            self.stopLoading()
        })
    }
}

//コラージュの順番を決定する
extension ViewController {
    // 画面にタッチで呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
    }
    
    //　ドラッグ時に呼ばれる
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチイベントを取得
        let touchEvent = touches.first!
        //タッチされた画像を取得
        let touchedView = touchEvent.view!
        // ドラッグ前の座標
        let preDx = touchEvent.previousLocation(in: self.view).x
        let preDy = touchEvent.previousLocation(in: self.view).y
        // ドラッグ後の座標
        let newDx = touchEvent.location(in: self.view).x
        let newDy = touchEvent.location(in: self.view).y
        
        switch touchedView {
        case collageImageView1: //左上の画像をドラッグしたときの挙動
            //指が左上にいるとき
            if (newDx < (myBoundSize!.width)/2) && (newDy <= 88 + (myBoundSize!.width)/2) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = false
                collageBKImageView1.image = nil
                collageBKImageView1.setNeedsLayout()
            }
            //指が右上にいるとき
            else if ((myBoundSize!.width)/2 < newDx) && (newDy <= 88 + (myBoundSize!.width)/2) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = true
                collageImageView3.isHidden = false
                collageImageView4.isHidden = false
                collageBKImageView1.image = collageImageView2.image
            }
            //指が左下にいるとき
            else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = true
                collageImageView4.isHidden = false
                collageBKImageView1.image = collageImageView3.image
            }
            //指が右下にいるとき
            else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = true
                collageBKImageView1.image = collageImageView4.image
            }
            
        case collageImageView2:
            //指が左上にいるとき
            if (newDx < (myBoundSize!.width)/2) && (newDy <= 88 + (myBoundSize!.width)/2) {
                collageImageView1.isHidden = true
                collageImageView2.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = false
                collageBKImageView2.image = collageImageView1.image
            }
            //指が右上にいるとき
            else if ((myBoundSize!.width)/2 < newDx) && (newDy <= 88 + (myBoundSize!.width)/2) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = false
                collageBKImageView2.image = nil
                collageBKImageView2.setNeedsLayout()
            }
            //指が左下にいるとき
            else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = true
                collageImageView4.isHidden = false
                collageBKImageView2.image = collageImageView3.image
            }
            //指が右下にいるとき
            else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView1.isHidden = false
                collageImageView2.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = true
                collageBKImageView2.image = collageImageView4.image
            }
            
        case collageImageView3:
            if (imageArray.count == 3) {
                //指が上にいるとき
                if (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageImageView5.isHidden = true
                    collageBKImageView3.image = collageImageView5.image
                }
                //指が左下にいるとき
                else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageImageView5.isHidden = false
                    collageBKImageView3.image = nil
                    collageBKImageView3.setNeedsLayout()
                }
                //指が右下にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = true
                    collageImageView5.isHidden = false
                    collageBKImageView3.image = collageImageView4.image
                }
            }
            else if (imageArray.count == 4) {
                //指が左上にいるとき
                if (newDx < (myBoundSize!.width)/2) && (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView1.isHidden = true
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView3.image = collageImageView1.image
                }
                //指が右上にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = true
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView3.image = collageImageView2.image
                }
                //指が左下にいるとき
                else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView3.image = nil
                    collageBKImageView3.setNeedsLayout()
                }
                //指が右下にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = true
                    collageBKImageView3.image = collageImageView4.image
                }
            }
            
            
        case collageImageView4:
            if (imageArray.count == 3) {
                //指が上にいるとき
                if (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView5.isHidden = true
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = collageImageView5.image
                }
                //指が左下にいるとき
                else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView5.isHidden = false
                    collageImageView3.isHidden = true
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = collageImageView3.image
                }
                //指が右下にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView5.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = nil
                    collageBKImageView4.setNeedsLayout()
                }
            }
            else if (imageArray.count == 4) {
                //指が左上にいるとき
                if (newDx < (myBoundSize!.width)/2) && (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView1.isHidden = true
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = collageImageView1.image
                }
                //指が右上にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (newDy <= 88 + (myBoundSize!.width)/2) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = true
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = collageImageView2.image
                }
                //指が左下にいるとき
                else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = true
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = collageImageView3.image
                }
                //指が右下にいるとき
                else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                    collageImageView1.isHidden = false
                    collageImageView2.isHidden = false
                    collageImageView3.isHidden = false
                    collageImageView4.isHidden = false
                    collageBKImageView4.image = nil
                    collageBKImageView4.setNeedsLayout()
                }
            }
            
        case collageImageView5:
            //指が上にいるとき
            if (newDy <= 88 + (myBoundSize!.width)/2) {
                collageImageView5.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = false
                collageBKImageView5.image = nil
                collageBKImageView5.setNeedsLayout()
            }
            //指が左下にいるとき
            else if (newDx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView5.isHidden = false
                collageImageView3.isHidden = true
                collageImageView4.isHidden = false
                collageBKImageView5.image = collageImageView3.image
            }
            //指が右下にいるとき
            else if ((myBoundSize!.width)/2 < newDx) && (88 + (myBoundSize!.width)/2 < newDy) {
                collageImageView5.isHidden = false
                collageImageView3.isHidden = false
                collageImageView4.isHidden = true
                collageBKImageView5.image = collageImageView4.image
            }
            
        default:
            print("取得画像の対象外")
        }
        
        // ドラッグしたx座標の移動距離
        let dx = newDx - preDx
        //print("x:\(dx)")
        // ドラッグしたy座標の移動距離
        let dy = newDy - preDy
        //print("y:\(dy)")
        // 画像のフレーム
        var viewFrame: CGRect = touchedView.frame
        // 移動分を反映させる
        viewFrame.origin.x += dx
        viewFrame.origin.y += dy
        
        touchedView.frame = viewFrame
        
        self.view.addSubview(touchedView)
        
    }
    
    //画面タッチ後に呼ばれる
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //背景に格納されている画像は一旦全て削除
        collageBKImageView1.image = nil
        collageBKImageView1.setNeedsLayout()
        collageBKImageView2.image = nil
        collageBKImageView2.setNeedsLayout()
        collageBKImageView3.image = nil
        collageBKImageView3.setNeedsLayout()
        collageBKImageView4.image = nil
        collageBKImageView4.setNeedsLayout()
        collageBKImageView5.image = nil
        collageBKImageView5.setNeedsLayout()
        
        // タッチイベントを取得
        let touchEvent = touches.first!
        
        //タッチしてた画像を取得
        let touchedView = touchEvent.view!
        
        let Dx = touchEvent.location(in: self.view).x
        let Dy = touchEvent.location(in: self.view).y
        
        switch touchedView {
            case collageImageView1:
                //左上で指を離したとき
                if (Dx < (myBoundSize!.width)/2) && (Dy < 88 + (myBoundSize!.width)/2) {
                    collageImageView1.frame = upperLeftRect!
                }
                //右上で指を離したとき
                else if ((myBoundSize!.width)/2 < Dx) && (Dy < 88 + (myBoundSize!.width)/2) {
                    collageImageView1.frame = upperLeftRect!
                    let img1 = collageImageView1.image
                    let img2 = collageImageView2.image
                    collageImageView1.image = img2
                    collageImageView2.image = img1
                    collageImageView2.isHidden = false
                }
                //左下で指を離したとき
                else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView1.frame = upperLeftRect!
                    let img1 = collageImageView1.image
                    let img3 = collageImageView3.image
                    collageImageView1.image = img3
                    collageImageView3.image = img1
                    collageImageView3.isHidden = false
                }
                //右下で指を離したとき
                else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView1.frame = upperLeftRect!
                    let img1 = collageImageView1.image
                    let img4 = collageImageView4.image
                    collageImageView1.image = img4
                    collageImageView4.image = img1
                    collageImageView4.isHidden = false
                }
            case collageImageView2:
                //左上で指を離したとき
                if (Dx < (myBoundSize!.width)/2) && (Dy < 88 + (myBoundSize!.width)/2) {
                    collageImageView2.frame = upperRightRect!
                    let img2 = collageImageView2.image
                    let img1 = collageImageView1.image
                    collageImageView2.image = img1
                    collageImageView1.image = img2
                    collageImageView1.isHidden = false
                }
                //右上で指を離したとき
                else if ((myBoundSize!.width)/2 < Dx) && (Dy < 88 + (myBoundSize!.width)/2) {
                    collageImageView2.frame = upperRightRect!
                }
                //左下で指を離したとき
                else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView2.frame = upperRightRect!
                    let img2 = collageImageView2.image
                    let img3 = collageImageView3.image
                    collageImageView2.image = img3
                    collageImageView3.image = img2
                    collageImageView3.isHidden = false
                }
                //右下で指を離したとき
                else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView2.frame = upperRightRect!
                    let img2 = collageImageView2.image
                    let img4 = collageImageView4.image
                    collageImageView2.image = img4
                    collageImageView4.image = img2
                    collageImageView4.isHidden = false
                }
            case collageImageView3:
                if (imageArray.count == 3) {
                    //上で指を離したとき
                    if (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView3.frame = lowerLeftRect!
                        let img3 = collageImageView3.image
                        let img5 = collageImageView5.image
                        collageImageView3.image = img5
                        collageImageView5.image = img3
                        collageImageView5.isHidden = false
                    }
                    //左下で指を離したとき
                    else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView3.frame = lowerLeftRect!
                    }
                    //右下で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView3.frame = lowerLeftRect!
                        let img3 = collageImageView3.image
                        let img4 = collageImageView4.image
                        collageImageView3.image = img4
                        collageImageView4.image = img3
                        collageImageView4.isHidden = false
                    }
                }
                else if (imageArray.count == 4){
                    //左上で指を離したとき
                    if (Dx < (myBoundSize!.width)/2) && (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView3.frame = lowerLeftRect!
                        let img3 = collageImageView3.image
                        let img1 = collageImageView1.image
                        collageImageView3.image = img1
                        collageImageView1.image = img3
                        collageImageView1.isHidden = false
                    }
                    //右上で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView3.frame = lowerLeftRect!
                        let img3 = collageImageView3.image
                        let img2 = collageImageView2.image
                        collageImageView3.image = img2
                        collageImageView2.image = img3
                        collageImageView2.isHidden = false
                    }
                    //左下で指を離したとき
                    else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView3.frame = lowerLeftRect!
                    }
                    //右下で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView3.frame = lowerLeftRect!
                        let img3 = collageImageView3.image
                        let img4 = collageImageView4.image
                        collageImageView3.image = img4
                        collageImageView4.image = img3
                        collageImageView4.isHidden = false
                    }
                }
                
            case collageImageView4:
                if(imageArray.count == 3) {
                    //上で指を離したとき
                    if (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView4.frame = lowerRightRect!
                        let img4 = collageImageView4.image
                        let img5 = collageImageView5.image
                        collageImageView4.image = img5
                        collageImageView5.image = img4
                        collageImageView5.isHidden = false
                    }
                    //左下で指を離したとき
                    else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView4.frame = lowerRightRect!
                        let img4 = collageImageView4.image
                        let img3 = collageImageView3.image
                        collageImageView4.image = img3
                        collageImageView3.image = img4
                        collageImageView3.isHidden = false
                    }
                    //右下で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView4.frame = lowerRightRect!
                    }
                }
                else if (imageArray.count == 4) {
                    //左上で指を離したとき
                    if (Dx < (myBoundSize!.width)/2) && (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView4.frame = lowerRightRect!
                        let img4 = collageImageView4.image
                        let img1 = collageImageView1.image
                        collageImageView4.image = img1
                        collageImageView1.image = img4
                        collageImageView1.isHidden = false
                    }
                    //右上で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (Dy < 88 + (myBoundSize!.width)/2) {
                        collageImageView4.frame = lowerRightRect!
                        let img4 = collageImageView4.image
                        let img2 = collageImageView2.image
                        collageImageView4.image = img2
                        collageImageView2.image = img4
                        collageImageView2.isHidden = false
                    }
                    //左下で指を離したとき
                    else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView4.frame = lowerRightRect!
                        let img4 = collageImageView4.image
                        let img3 = collageImageView3.image
                        collageImageView4.image = img3
                        collageImageView3.image = img4
                        collageImageView3.isHidden = false
                    }
                    //右下で指を離したとき
                    else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                        collageImageView4.frame = lowerRightRect!
                    }
            }
            
            case collageImageView5:
                //上で指を離したとき
                if (Dy < 88 + (myBoundSize!.width)/2) {
                    collageImageView5.frame = upperRect!
                }
                //左下で指を離したとき
                else if (Dx < (myBoundSize!.width)/2) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView5.frame = upperRect!
                    let img5 = collageImageView5.image
                    let img3 = collageImageView3.image
                    collageImageView5.image = img3
                    collageImageView3.image = img5
                    collageImageView3.isHidden = false
                }
                //右下で指を離したとき
                else if ((myBoundSize!.width)/2 < Dx) && (88 + (myBoundSize!.width)/2 < Dy) {
                    collageImageView5.frame = upperRect!
                    let img5 = collageImageView5.image
                    let img4 = collageImageView4.image
                    collageImageView5.image = img4
                    collageImageView4.image = img5
                    collageImageView4.isHidden = false
                }
            
            default:
                print("取得画像の対象外")
        }
    }
    
    //ペケボタンを押下した時に呼び出される
    @IBAction func collageButtonDidTap(_ sender: Any) {
        let collageImage1 = self.collageImageView1.image
        let collageImage2 = self.collageImageView2.image
        let collageImage3 = self.collageImageView3.image
        let collageImage4 = self.collageImageView4.image
        let collageImage5 = self.collageImageView5.image
        
        if (imageArray.count == 3) {
            DispatchQueue.global(qos: .default).async {
                let resultImg = OpenCVManager.shared()?.collageImageFor3(collageImage5, image3: collageImage3, image4: collageImage4)
                DispatchQueue.main.async {
                    self.doneRetouch(image: resultImg)
                }
            }
        }
        else if (imageArray.count == 4) {
            DispatchQueue.global(qos: .default).async {
                let resultImg = OpenCVManager.shared()?.collageImageFor4(collageImage1, image2: collageImage2, image3: collageImage3, image4: collageImage4)
                DispatchQueue.main.async {
                    self.doneRetouch(image: resultImg)
                }
            }
        }
        
    }
    
}


///2. 矩形でGrabCutする
extension ViewController {
    private func doGrabCut() {
        maskImageView.image = doGrabCutWithRect()
        reload(status: .segment)
    }
    
    private func doGrabCutWithRect() -> UIImage? {
        guard let img = sourceImageView.image else {
            assertionFailure()
            return nil
        }
        
        //矩形取得
        let rect: CGRect
        if let selectedR = selectedRect {
            if selectedR.size == img.size {//矩形が画像と同じサイズのとき僅かに小さくして入力
                rect = CGRect(origin: CGPoint(x: selectedR.origin.x + 1, y: selectedR.origin.y + 1), size: CGSize(width: selectedR.size.width - 2, height: selectedR.size.height - 2))
            } else {
                rect = selectedR
            }
        } else {
            rect = CGRect(origin: CGPoint(x: 1, y: 1), size: CGSize(width: img.size.width - 2, height: img.size.height - 2))
        }
        
        return OpenCVManager.shared()?.doGrabCut(img, foregroundRect: rect, iterationCount: 1)
    }
}

///3.マスクでGrabCutする
extension ViewController {
//    private func doGrabCutWithMask() {
//        guard let img = sourceImageView.image else {
//            assertionFailure()
//            return
//        }
//        startLoading()
//
//        if let drawImg = drawImageView.image, let markersImg = cropInsideRectAndResize(image: drawImg, size: img.size) {
//            DispatchQueue.global(qos: .default).async {
//                let mask = OpenCVManager.shared()?.doGrabCut(img, markersImage: markersImg, iterationCount: 1)
//                DispatchQueue.main.async {
//                    self.stopLoading()
//                    self.maskImageView.image = mask
//                }
//            }
//        } else {
//            stopLoading()
//        }
//    }
    
    ///UIImageのSizeにクロップ & リサイズ
    private func cropInsideRectAndResize(image: UIImage, size: CGSize) -> UIImage? {
        let frame = AVMakeRect(aspectRatio: size, insideRect: sourceImageView.bounds)
        if let cropImg = image.cropping(to: frame) {
            return cropImg.resize(size: size)
        }
        return nil
    }
    
//    @IBAction func drawPenSizeSliderValueChanged(_ sender: Any) {
//        drawImageView.penSize = CGFloat(drawPenSizeSlider.value)
//    }
    
//    @IBAction func drawColorSegmentedDidChangeValue(_ sender: Any) {
//        guard let segumented = sender as? UISegmentedControl else {
//            assertionFailure()
//            return
//        }
//        switch segumented.selectedSegmentIndex {
//        case 0:
//            drawImageView.penColor = UIColor.white
//        case 1:
//            drawImageView.penColor = UIColor.black
//        default:
//            assertionFailure()
//        }
//    }
    
    @IBAction func segmentEditDoButtonDidTap(_ sender: Any) {
        //doGrabCutWithMask()
    }
    
    @IBAction func segmentEditDoneButtonDidTap(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value, isUpdatedSegmentation: true)
    }
}

///加工処理
extension ViewController {
    
    //明るさが変更された時
    @IBAction func brightnessValueSliderTouchUpInside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    @IBAction func brightnessValueSliderTouchUpOutside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    //コントラストが変更された時
    @IBAction func contrastValueSliderTouchUpInside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    @IBAction func contrastValueSliderTouchUpOutside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    //彩度が変更された時
    @IBAction func saturationValueSliderTouchUpInside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    @IBAction func saturationValueSliderTouchUpOutside(_ sender: Any) {
        retouch(brightnessValue: brightnessValueSlider.value, contrastValue: contrastValueSlider.value, saturationValue: saturationValueSlider.value)
    }
    
    private func backgroundToWhite(brightnessValue: Float, contrastValue: Float, saturationValue: Float, isUpdatedSegmentation: Bool = false) {
        guard let img = sourceImageView.image?.cropping(to: selectedRect!) else {
            assertionFailure()
            return
        }
        //cropImageViewにimgを格納しておく（比較するため）
        cropImageView.image = img
        //写真サイズの表記をトリミングされたimgのサイズに変更
        imageSizeLabel.text = "\(Int(img.size.width)) x \(Int(img.size.height))"
        
        let image = buffer(from:img)

        let model = DeepLabV3()
        guard let output = try? model.prediction(image: image!) else {
            fatalError("Error")
        }

        print(output)
//        let rep = (img.bitmapImageRepresentation(colorSpaceName: "NSDeviceRGBColorSpace"))!
//        let newImage = NSImage(size: NSSize(width: 513, height: 513))

        for y in 0..<Int(img.size.height) {
            for x in 0..<Int(img.size.width) {
                let getY = Int(img.size.width) - y - 1
                let index: [NSNumber] = [NSNumber(value: getY), NSNumber(value: x)]
                let flag = output.semanticPredictions[index]
                if flag == 0 {
                    // 背景部分を白く変えたい
                    
                }
            }
        }
        //newImage.addRepresentation(rep)
        
    }
    
    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
        return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
    
    private func retouch(brightnessValue: Float, contrastValue: Float, saturationValue: Float, isUpdatedSegmentation: Bool = false) {
        guard let img = sourceImageView.image?.cropping(to: selectedRect!) else {
            assertionFailure()
            return
        }
        //cropImageViewにimgを格納しておく（比較するため）
        cropImageView.image = img
        //写真サイズの表記をトリミングされたimgのサイズに変更
        imageSizeLabel.text = "\(Int(img.size.width)) x \(Int(img.size.height))"
        startLoading()
        //加工なし
        if (retouchSegment.selectedSegmentIndex == 1) {
            stopLoading()
            resultImageView.image = img
            resultImage = img
            reload(status: .result)
        //加工あり
        } else if(retouchSegment.selectedSegmentIndex == 0) {
                    
            DispatchQueue.global(qos: .default).async {
                let resultImg = OpenCVManager.shared()?.doRetouch(CGFloat(brightnessValue), contrastValue: CGFloat(contrastValue), saturationValue: CGFloat(saturationValue), sourceImage2: img)
                DispatchQueue.main.async {
                    self.doneRetouch(image: resultImg)
                }
            }
        }
    }
    
    private func doneRetouch(image: UIImage?) {
        stopLoading()
        resultImageView.image = image
        resultImage = image
        //inpaintingImage = OpenCVManager.shared()?.inpaintingImage()
        //blurWithoutGradientImage = OpenCVManager.shared()?.blurWithoutGradientImage()
        //フラグによって呼び出す画面（ステータス）を変える
        switch retouchFlug {
        case 0:
            reload(status: .result)
        case 1:
            reload(status: .collageResult)
        default:
            break
        }
    }
    
    
    @IBAction func compareSourceButtonTouchDown(_ sender: Any) {
        cropImageView.isHidden = false
        maskImageView.isHidden = true
        //drawImageView.isHidden = true
        resultImageView.isHidden = true
    }
    
    @IBAction func compareSourceButtonTouchUpInside(_ sender: Any) {
        reload(status: .result)
    }
    
    @IBAction func compareSourceButtonTouchUpOutside(_ sender: Any) {
        reload(status: .result)
    }
    
    //ロゴスタンプ選択画面に遷移
    @IBAction func logoButtonTapped(){
        //SegueのIdentifierを設定
        self.performSegue(withIdentifier: "ToLogoList", sender: self)
    }
    
    //ロゴスタンプ削除
    @IBAction func logoDeleteButtonDidTap(_ sender: Any) {
        //canvasViewのサブビューの数が1より大きかったら実行
        if (canvasView.subviews.count > 0) {
            //canvasViewの子ビューの最後のものを取り出す
            let lastStamp = canvasView.subviews.last! as! LogoStamp
            //canvasViewからlastStampを削除する
            lastStamp.removeFromSuperview()
            //lastStampが格納されているstampArrayのインデックス番号を取得
            if let index = appDelegate.stampArray.index(of: lastStamp){
                //stampArrayからlastStampを削除
                appDelegate.stampArray.remove(at: index)
            }
        }
    }
    
    //保存ボタンを押下した時の処理（今回追加分）
    @IBAction func saveButtonDidTap(_ sender: Any) {
        var img : UIImage
        
        if (appDelegate.stampArray.isEmpty == false) {
            //画像コンテキストをサイズ、透過の有無、スケールを指定して作成
            UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, canvasView.isOpaque, 0.0)
            //canvasViewのレイヤーをレンダリング
            canvasView.layer.render(in: UIGraphicsGetCurrentContext()!)
            //レンダリングした画像を取得
            img = UIGraphicsGetImageFromCurrentImageContext()!
            //画像コンテキストを破棄
            UIGraphicsEndImageContext()
        } else {
            img = resultImageView.image!
        }
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        let title: String
        if let error = error {
            title = "保存に失敗しました\n\(error.description)"
        } else {
            title = "保存完了！"
        }
        showAlertEX(title: title, message: nil)
    }
    
    //アラート表示をして、OKを押したらTOP画面に遷移させる関数
    private func showAlertEX(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in

        //アラートが消えるのと画面遷移が重ならないように0.3秒後に画面遷移するようにしてる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 0.3秒後に実行したい処理
            //canvasViewのサブビューを削除
            while (self.canvasView.subviews.count > 0) {
                //canvasViewの子ビューの最後のものを取り出す
                let lastStamp = self.canvasView.subviews.last! as! LogoStamp
                //canvasViewからlastStampを削除する
                lastStamp.removeFromSuperview()
            }
            //ロゴ画像を破棄
            self.appDelegate.stampArray.removeAll()
            super.viewDidLoad()
            self.reload(status: .load)
            self.setupIndicatorBaseView()
            self.sourceImageView.image = UIImage(named:"title")
        }
        })
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return baseView
    }
    
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        drawImageView.beginZooming()
//    }
}
