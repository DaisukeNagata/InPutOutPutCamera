//
//  ViewController.swift
//  InPutOutPutCamera
//
//  Created by 永田大祐 on 2018/05/19.
//  Copyright © 2018年 永田大祐. All rights reserved.
//

import UIKit
import AVFoundation

//ジャスチャー
struct CommonStructure {
    //タップ
    static var tapGesture = UITapGestureRecognizer()
    //スワイプ
    static var swipeGestureUP = UISwipeGestureRecognizer()
}

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    let aVC = AVCinSideOutSideObject()
    var cameraView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.frame = view.frame
        view.addSubview(cameraView)

        //カメラのメソッドをUIImageViewに付与
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)

        //ジャスチャー
        CommonStructure.tapGesture = UITapGestureRecognizer(target: self,
                                                            action:#selector(tapGesture))
        self.view.addGestureRecognizer( CommonStructure.tapGesture)
        //アップスワイプ
        CommonStructure.swipeGestureUP = UISwipeGestureRecognizer(target: self, action:#selector(upTappled))
        CommonStructure.swipeGestureUP.numberOfTouchesRequired = 1
        CommonStructure.swipeGestureUP.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer( CommonStructure.swipeGestureUP)
    }

    //カメラのinとoutの切り替え
    @objc func tapGesture(sender:UITapGestureRecognizer) {
        cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView)
    }

    //カメラの撮影
    @objc func upTappled(sender:UISwipeGestureRecognizer) {
        aVC.cameraAction(captureDelegate: self)
    }

    // フォトライブラリへの保存メソッド
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        let photoData = photo.fileDataRepresentation()
        guard photoData != nil else { return }
        // フォトライブラリに保存
        UIImageWriteToSavedPhotosAlbum(UIImage(data: photoData!)!, nil, nil, nil)
    }

}


class AVCinSideOutSideObject: NSObject {

    //キャプチャセッションに入力（オーディオやビデオなど）を提供し、ハードウェア固有のキャプチャ機能のコントロールを提供するデバイス。
    var captureDevice  = AVCaptureDevice.default(for: .video)
    var stillImageOutput: AVCapturePhotoOutput? //静止画、ライブ写真、その他の写真ワークフローの出力をキャプチャします。


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
        stillImageOutput = AVCapturePhotoOutput()
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

    //シャッターを撮影するメソッド
    func cameraAction (captureDelegate:AVCapturePhotoCaptureDelegate) {
        // フラッシュとかカメラの設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        // キャプチャが自動イメージ安定化を使用するかどうかを指定するブール値。
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        // アクティブなデバイスでサポートされている最高解像度で静止画像をキャプチャするかどうかを指定するブール値。
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // 撮影
        stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: captureDelegate)
    }
}
