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
import Photos

//ジャスチャー
struct CommonStructure {
    //上スワイプ
    static var swipeGestureUP = UISwipeGestureRecognizer()
    //右スワイプ
    static var swipeGestureRight = UISwipeGestureRecognizer()
}

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let aVC = AVCinSideOutSideObject()
    var cameraView = UIImageView()
    var isRecoding = false
    var label = UILabel()
    var fileURL: URL?
    var pic = UIImagePickerController()
    lazy var pickerView : PickerView = {
        let pickerView = PickerView()
        pickerView.dataSource = pickerView
        pickerView.delegate = pickerView
        return pickerView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        label.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2, width: UIScreen.main.bounds.width, height: 100)
        label.textAlignment = .center
        label.textColor = .white
        cameraView.frame = view.frame
        view.addSubview(cameraView)
        view.addSubview(pickerView)

        //アップスワイプ
        CommonStructure.swipeGestureUP = UISwipeGestureRecognizer(target: self, action:#selector(upSwipe))
        CommonStructure.swipeGestureUP.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureUP.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer( CommonStructure.swipeGestureUP)
        //右スワイプ
        CommonStructure.swipeGestureRight = UISwipeGestureRecognizer(target: self, action:#selector(photeSegue))
        CommonStructure.swipeGestureRight.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer( CommonStructure.swipeGestureRight)

        //ビデオカメラの設定
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView, timeDuration: Int32(pickerView.indexList))
    }

    //カメラの撮影
    @objc func upSwipe(sender:UILongPressGestureRecognizer) {
         cameraView.addSubview(label)
        if isRecoding { // 録画終了
            aVC.stillImageOutput?.stopRecording()
        } else{
            self.label.text = "録画開始します"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.label.text = ""
                self.pickerView.get(callBackClosure: self.setIndex)
            }
        }
        isRecoding = !isRecoding
    }

    //フレームレートの設定
    func setIndex() {
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView, timeDuration: Int32(pickerView.indexList))
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

    //カメラロールに遷移
    @objc func photeSegue() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            self.pic.mediaTypes = [kUTTypeMovie as String]
            self.pic.allowsEditing = true
            self.pic.delegate = self
            self.present(self.pic, animated: true)
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
        print(url)
        dismiss(animated: true)
    }

}


class AVCinSideOutSideObject: NSObject {

    //キャプチャセッションに入力（オーディオやビデオなど）を提供し、ハードウェア固有のキャプチャ機能のコントロールを提供するデバイス。
    var captureDevice  = AVCaptureDevice.default(for: .video)
    var stillImageOutput: AVCaptureMovieFileOutput? //静止画、ライブ写真、その他の写真ワークフローの出力をキャプチャします。


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

    func inSideOutSideCameraSet(cameraView: UIImageView, timeDuration: Int32) -> UIImageView {

        stillImageOutput = AVCaptureMovieFileOutput()
        // キャプチャアクティビティを管理し、入力デバイスからキャプチャ出力へのデータフローを調整するオブジェクト。
        let captureSesion = AVCaptureSession()
        // 解像度の設定
        captureSesion.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            // 入力
            if  captureSesion.canAddInput(deviceInput) {
                captureSesion.addInput(deviceInput)
                // 出力
                if (captureSesion.canAddOutput(stillImageOutput!)) {
                    captureSesion.addOutput(stillImageOutput!)
                    // カメラ起動
                    captureSesion.startRunning()
                    do {
                        try captureDevice?.lockForConfiguration()
                        // フレームレートの設定
                        captureDevice?.activeVideoMinFrameDuration = CMTimeMake(1, timeDuration)
                        
                        captureDevice?.unlockForConfiguration()
                    } catch _ {
                        print("catch")
                    }
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
