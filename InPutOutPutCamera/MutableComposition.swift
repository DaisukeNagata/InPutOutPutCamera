//
//  MutableComposition.swift
//  InPutOutPutCamera
//
//  Created by 永田大祐 on 2018/06/15.
//  Copyright © 2018年 永田大祐. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import Photos

class MutableComposition: NSObject, UINavigationControllerDelegate {

    let mixComposition = AVMutableComposition()
    var uiView: UIViewController


    init(vc: UIViewController) {
        uiView = vc
       super.init()
    }
    

    func aVAsset(aVAsset: AVAsset,views: ViewController) {
       
        
        //https://www.raywenderlich.com/188034/how-to-play-record-and-merge-videos-in-ios-and-swift  ---->
        guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                              preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVAsset.duration),
                                           of: aVAsset.tracks(withMediaType: .video)[0],
                                           at: kCMTimeZero)
        } catch {
            print("Failed to load first track")
            return
        }
        
//        guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video,
//                                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
//        do {
//            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVAssetSecound.duration),
//                                            of: aVAssetSecound.tracks(withMediaType: .video)[0],
//                                            at: aVAsset.duration)
//        } catch {
//            print("Failed to load second track")
//            return
//        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd (aVAsset.duration, kCMTimeZero))
        
        let firstInstruction = VideoHelper.videoCompositionInstruction(firstTrack, asset: aVAsset)
        firstInstruction.setOpacity(0.0, at: aVAsset.duration)
//        let secondInstruction = VideoHelper.videoCompositionInstruction(secondTrack, asset: aVAssetSecound)
        
        mainInstruction.layerInstructions = [firstInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let num = arc4random() % 100000000
        let url = documentDirectory.appendingPathComponent(num.description+"\(date).mov")
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition

        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter,aVAsset: aVAsset,url: url, views: views)
            }
        }
    //-------------------------------------------------------------------------------------------------------->
    }
    
    func exportDidFinish(_ session: AVAssetExportSession,aVAsset: AVAsset, url: URL, views:ViewController) {

        guard session.status == AVAssetExportSessionStatus.completed,
            let outputURL = session.outputURL else { return }
        
        let saveVideoToPhotos = {
            PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL) }) { saved, error in
                if UIVideoEditorController.canEditVideo(atPath: url.path) {
                    let pickerView = UIImagePickerController()
                    pickerView.mediaTypes = [kUTTypeMovie as String]
                    pickerView.allowsEditing = true
                    pickerView.delegate = views
                    views.defo.saveMethod(url: url, picker: views.pic)
                    views.present(pickerView, animated: true)
                }
            }
        }

        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            })
        } else {
            saveVideoToPhotos()
        }
    }
    
    func exportDidFinish2(_ session: AVAssetExportSession,aVAsset: AVAsset, aVAssetSecound: AVAsset, url: URL, views:ViewController) {
        
        guard session.status == AVAssetExportSessionStatus.completed,
            let outputURL = session.outputURL else { return }
        
        let saveVideoToPhotos = {
            PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL) }) { saved, error in
               print("ok")
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            })
        } else {
            saveVideoToPhotos()
        }
    }
}
