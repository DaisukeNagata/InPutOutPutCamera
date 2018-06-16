//
//  ViewController.swift
//  InPutOutPutCamera
//
//  Created by 永田大祐 on 2018/05/19.
//  Copyright © 2018年 永田大祐. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import Photos
import AVKit
//ジャスチャー
struct CommonStructure {
    //タップ
    static var tapGesture = UITapGestureRecognizer()
    //上スワイプ
    static var swipeGestureUP = UISwipeGestureRecognizer()
    //下スワイプ
    static var swipeGestureDown = UISwipeGestureRecognizer()
    //右スワイプ
    static var swipeGestureRight = UISwipeGestureRecognizer()
    //左スワイプ
    static var swipeGestureLeft = UISwipeGestureRecognizer()
}

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let aVC = AVCinSideOutSideObject()
    var cameraView = UIImageView()
    var isRecoding = false
    var label = UILabel()
    var fileURL: URL?
    var defo = UserDefaultsFile()
    var pic = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2, width: UIScreen.main.bounds.width, height: 100)
        label.textAlignment = .center
        label.textColor = .white
        cameraView.frame = view.frame
        view.addSubview(cameraView)
        
        //カメラのメソッドをUIImageViewに付与
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)
        cameraView.addSubview(label)
        //タップジャスチャー
        CommonStructure.tapGesture = UITapGestureRecognizer(target: self,action:#selector(tapGesture))
        self.view.addGestureRecognizer( CommonStructure.tapGesture)
        //アップスワイプ
        CommonStructure.swipeGestureUP = UISwipeGestureRecognizer(target: self, action:#selector(upSwipe))
        CommonStructure.swipeGestureUP.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureUP.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer( CommonStructure.swipeGestureUP)
        //ダウンスワイプ
        CommonStructure.swipeGestureDown = UISwipeGestureRecognizer(target: self, action:#selector(downSwipe))
        CommonStructure.swipeGestureDown.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer( CommonStructure.swipeGestureDown)
        //右スワイプ
        CommonStructure.swipeGestureRight = UISwipeGestureRecognizer(target: self, action:#selector(photeSegue))
        CommonStructure.swipeGestureRight.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer( CommonStructure.swipeGestureRight)
        //左スワイプ
        CommonStructure.swipeGestureLeft = UISwipeGestureRecognizer(target: self, action:#selector(photeReset))
        CommonStructure.swipeGestureLeft.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer( CommonStructure.swipeGestureLeft)
        
    }
    //カメラのinとoutの切り替え
    @objc func tapGesture(sender:UITapGestureRecognizer) {
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)
        cameraView.addSubview(label)
    }
    //カメラの撮影
    @objc func upSwipe(sender:UILongPressGestureRecognizer) {
        // aVC.cameraAction(captureDelegate: self)
        if isRecoding { // 録画終了
            aVC.stillImageOutput?.stopRecording()
        } else{
            self.label.text = "録画開始します"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.label.text = ""
            }
            //ディレクトリ検索パスのリストを作成します。
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let date = dateFormatter.string(from: Date())
            let num = arc4random() % 100000000
            let url = documentDirectory.appendingPathComponent(num.description + "\(date)temp.mp4")
            fileURL = url
            aVC.stillImageOutput?.startRecording(to: (fileURL as URL?)!, recordingDelegate: self)
        }
        isRecoding = !isRecoding
    }
    //動画の結合
    @objc func downSwipe(sender:UITapGestureRecognizer) { mergeMethod() }

    //カメラロールに遷移
    @objc func photeSegue() {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                self.pic.mediaTypes = [kUTTypeMovie as String]
                self.pic.allowsEditing = true
                self.pic.delegate = self
                self.present(self.pic, animated: true)
        }
    }

    @objc func photeReset() {
        defo.removeMethod(st:"pathFileNameOne")
        defo.removeMethod(st:"pathFileNameSecound")
        
        self.label.text = "リセット"
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            self.label.text = ""
        }
    }
    //保留中のすべてのデータが出力ファイルに書き込まれたときに、デリゲートに通知します。
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                DispatchQueue.main.sync {
                    self.label.text = "録画しました"
                }
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self.label.text = ""
                }
            }
            let pickerView = UIImagePickerController()
            pickerView.mediaTypes = [kUTTypeMovie as String]
            pickerView.allowsEditing = true
            pickerView.delegate = self
            self.present(pickerView, animated: true)
        }

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL else { return }
        dismiss(animated: true) {
            self.defo.saveMethod(url:url, picker: picker)
        }
    }
    
    func mergeMethod() {
        guard let urlOne = self.defo.loadMethod(st: "pathFileNameOne") else {
            self.label.text = "編集データがありません"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.label.text = ""
            }
            return
        }
        guard let urlSecound = self.defo.loadMethod(st: "pathFileNameSecound") else {
            self.label.text = "２つ目の編集データがありません"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.label.text = ""
            }
            return
        }

        let avAsset = AVAsset(url: urlOne)
        let avAssetSecound = AVAsset(url: urlSecound)
        if avAsset.duration != kCMTimeZero && avAssetSecound.duration != kCMTimeZero {
        let mutableComposition = MutableComposition(vc: self)
            mutableComposition.aVAssetMerge(aVAsset: avAsset, aVAssetSecound: avAssetSecound, views: self)
        } else {
            self.label.text = "左スワイプでリセットしてください"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.label.text = ""
            }
        }
    }

}
    

class AVCinSideOutSideObject: NSObject {
    
    //キャプチャセッションに入力（オーディオやビデオなど）を提供し、ハードウェア固有のキャプチャ機能のコントロールを提供するデバイス。
    var captureDevice  = AVCaptureDevice.default(for: .video)
    var stillImageOutput: AVCaptureMovieFileOutput?//静止画、ライブ写真、その他の写真ワークフローの出力をキャプチャします。
    
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession =
            
            AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                  mediaType: AVMediaType.video,
                                                  position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func inSideOutSideCameraSet(cameraView: UIImageView ) -> UIImageView {
        
        //キャプチャデバイスからキャプチャセッションにメディアを提供するキャプチャ入力。
        var input: AVCaptureDeviceInput!
        stillImageOutput = AVCaptureMovieFileOutput()
        // キャプチャアクティビティを管理し、入力デバイスからキャプチャ出力へのデータフローを調整するオブジェクト。
        let captureSesion = AVCaptureSession()
        // 解像度の設定
        captureSesion.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        if cameraView.frame.width != 0 {
            //一連の構成変更の開始を示します。
            captureSesion.beginConfiguration()
            //一連の構成変更をコミットします。
            captureSesion.commitConfiguration()
        }
        
        if captureDevice?.position == .front {
            UIView.transition(with: cameraView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.captureDevice = self.cameraWithPosition(.back)!
            }, completion: nil)
        } else {
            UIView.transition(with: cameraView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.captureDevice = self.cameraWithPosition(.front)!
            }, completion: nil)
        }
        
        var deviceInput: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            // 入力
            if  captureSesion.canAddInput(deviceInput) {
                captureSesion.removeInput(input)
                captureSesion.addInput(deviceInput)
                // 出力
                if (captureSesion.canAddOutput(stillImageOutput!)) {
                    captureSesion.addOutput(stillImageOutput!)
                    // カメラ起動
                    captureSesion.startRunning()
                    
                    //キャプチャされているときにビデオを表示できるコアアニメーションレイヤ-
                    var previewLayer: AVCaptureVideoPreviewLayer?
                    //キャプチャされているときにビデオを表示できるコアアニメーションレイヤ-
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion)
                    // アスペクトフィット
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    // カメラの向き
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    previewLayer?.frame =  cameraView.frame
                    return cameraView
                }
            }
        } catch {
            print(error)
            
        }
        return cameraView
    }
}

//https://www.raywenderlich.com/188034/how-to-play-record-and-merge-videos-in-ios-and-swift
class VideoHelper {
    
    static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerControllerSourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    static func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    static func videoCompositionInstruction(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor), at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
                .concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }
    
}
