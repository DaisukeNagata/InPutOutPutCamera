//
//  UserDefaultsFile.swift
//  InPutOutPutCamera
//
//  Created by 永田大祐 on 2018/06/15.
//  Copyright © 2018年 永田大祐. All rights reserved.
//

import UIKit

class UserDefaultsFile {
    
    var defo = UserDefaults.standard

    func saveMethod(url: URL, picker: UIImagePickerController) {
        guard defo.object(forKey: "pathFileNameOne") != nil else {
            defo.set(url, forKey: "pathFileNameOne")
            return  picker.dismiss(animated: true, completion: nil)

        }
        defo.set(url, forKey: "pathFileNameSecound")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func loadMethod(st: String) -> URL! {
        guard defo.object(forKey:st) != nil else { return nil }
        return defo.url(forKey: st)!
    }
    
    func removeMethod(st: String) {  defo.removeObject(forKey: st) }
}
