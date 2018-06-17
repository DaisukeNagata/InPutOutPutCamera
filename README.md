# FrameRateVideoCamera
### 操作方法
1.ピッカーで値を選択

2.上スワイプで撮影を開始

#### フレームレート数が少ないとコマ送りの挙動になります。

## フレームレートの値を変更して動画を撮影しています。

pickerView.indexList の値をViewControllerから撮影時に、timeDurationの変数に付与しています。

pickerView.indexList の値は、UIPickerViewクラスでPickerの操作時の値を付与しています。

```ruby
Class ViewController
cameraView = aVC.inSideOutSideCameraSet(cameraView: cameraView, timeDuration: Int32(pickerView.indexList))
```

```ruby
Class AVCinSideOutSideObject
 do {
                        try captureDevice?.lockForConfiguration()
                        // フレームレートの設定
                        captureDevice?.activeVideoMinFrameDuration = CMTimeMake(1, timeDuration)
                        
                        captureDevice?.unlockForConfiguration()
                    } catch _ {
                        print("catch")
                    }
 ```
 
 ```ruby
 Class PickerView
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        get { self.indexList = self.list[row] }
        return  list[row].description
    }
  func get(callBackClosure:@escaping () -> Void) -> Void { callBackClosure() }
 ```
 クリックをするとフレームレート数を変更した際の挙動動画にジャンプします。
 
[![](https://github.com/daisukenagata/InPutOutPutCamera/blob/FrameRateSetVideoCamera/スクリーンショット%202018-06-17%2017.39.43.png?raw=true)](https://youtu.be/LmYCyR-JW34)
