//
//  PickerView.swift
//  InPutOutPutCamera
//
//  Created by 永田大祐 on 2018/06/17.
//  Copyright © 2018年 永田大祐. All rights reserved.
//

import UIKit



class PickerView:UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    var list = [3,4,5,10,15,20,25,30]
    var indexList = Int()
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
        self.dataSource = self
        self.frame = CGRect(x: 0,
                            y: UIScreen.main.bounds.height - 300,
                            width: UIScreen.main.bounds.width,
                            height: 300)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        get { self.indexList = self.list[row] }
        return  list[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row: \(row)")
    }

    func get(callBackClosure:@escaping () -> Void) -> Void { callBackClosure() }
}
