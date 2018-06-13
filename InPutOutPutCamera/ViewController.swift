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
    //タップ
    static var tapGesture = UITapGestureRecognizer()
    //スワイプ
    static var swipeGestureUP = UISwipeGestureRecognizer()
}

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIVideoEditorControllerDelegate, UINavigationControllerDelegate {

    let aVC = AVCinSideOutSideObject()
    var cameraView = UIImageView()
    var isRecoding = false
    var label = UILabel()
    var fileURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        label.frame = CGRect(x: UIScreen.main.bounds.width/2 - 50, y: UIScreen.main.bounds.height/2, width: UIScreen.main.bounds.width, height: 100)
        label.textColor = .white
        cameraView.frame = view.frame
        view.addSubview(cameraView)

        //カメラのメソッドをUIImageViewに付与
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)
        cameraView.addSubview(label)
        //ジャスチャー
        CommonStructure.tapGesture = UITapGestureRecognizer(target: self,
                                                            action:#selector(tapGesture))
        self.view.addGestureRecognizer( CommonStructure.tapGesture)
        //アップスワイプ
        CommonStructure.swipeGestureUP = UISwipeGestureRecognizer(target: self, action:#selector(tappled))
        CommonStructure.swipeGestureUP.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureUP.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer( CommonStructure.swipeGestureUP)
        
    }

    //カメラのinとoutの切り替え
    @objc func tapGesture(sender:UITapGestureRecognizer) {
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)
        cameraView.addSubview(label)
    }

    //カメラの撮影
    @objc func tappled(sender:UILongPressGestureRecognizer) {
       // aVC.cameraAction(captureDelegate: self)
        if isRecoding { // 録画終了
            aVC.stillImageOutput?.stopRecording()
        } else{
            self.label.text = "録画開始します"
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            self.label.text = ""
            }
            //ディレクトリ検索パスのリストを作成します。
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let videDirectory = paths[0] as String
            let filePath : String? = "\(videDirectory)/temp.mp4"
            fileURL = URL(fileURLWithPath: filePath!)
            aVC.stillImageOutput?.startRecording(to: (fileURL as URL?)!, recordingDelegate: self)
        }
        isRecoding = !isRecoding
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
                if UIVideoEditorController.canEditVideo(atPath: (self.fileURL?.path)!) {
                    let editController = UIVideoEditorController()
                    editController.videoPath = (self.fileURL?.path)!
                    editController.videoQuality = .typeIFrame1280x720
                    editController.delegate = self
                    self.present(editController, animated: true)
                }
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
