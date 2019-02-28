//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by linkage on 2019/2/25.
//  Copyright © 2019年 yuanjian. All rights reserved.
//

import UIKit
import AVFoundation

class JunPreviewView: UIView {
    fileprivate var overLayer = CALayer()
    fileprivate var faceLayers = [String: Any]()
    fileprivate var previewLayer = AVCaptureVideoPreviewLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    fileprivate func setupViews(){
        frame.size.height = UIScreen.main.bounds.height - 64 - 50
        backgroundColor = UIColor.black
        
        overLayer.frame = frame
        overLayer.sublayerTransform = CATransform3DMakePerspective(eyePosition: 1000)
        layer.addSublayer(overLayer)
    }
}

extension JunPreviewView: HandleMetadataOutputDelegate{
    // 各画像のトラバースと処理
    func handleOutput(didDetect faceObjects: [AVMetadataObject], previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        
        let transformFaces = transformedFaces(faceObjs: faceObjects)
        
        var lostFaces = [String]()
        for faceID in faceLayers.keys {
            lostFaces.append(faceID)
        }

        for i in 0..<transformFaces.count {
            guard let face = transformFaces[i] as? AVMetadataFaceObject  else { return }
            if lostFaces.contains("\(face.faceID)"){
                lostFaces.remove(at: i)
            }
            
            var faceLayer = faceLayers["\(face.faceID)"] as? CALayer
            if faceLayer == nil{
                faceLayer = creatFaceLayer()
                overLayer.addSublayer(faceLayer!)
                faceLayers["\(face.faceID)"] = faceLayer
            }
            
            faceLayer?.transform = CATransform3DIdentity
            faceLayer?.frame = face.bounds
            
            if face.hasYawAngle{
                let tranform3D = transformDegress(yawAngle: face.yawAngle)
                faceLayer?.transform = CATransform3DConcat(faceLayer!.transform, tranform3D)
            }
            
            if face.hasRollAngle{
                let tranform3D = transformDegress(rollAngle: face.rollAngle)
                faceLayer?.transform = CATransform3DConcat(faceLayer!.transform, tranform3D)
            }
            
            for faceIDStr in lostFaces{
                let faceIDLayer = faceLayers[faceIDStr] as? CALayer
                faceIDLayer?.removeFromSuperlayer()
                faceLayers.removeValue(forKey: faceIDStr)
            }
        }
    }
}


// 距離と偏向角度の計算
extension JunPreviewView{
    fileprivate func transformedFaces(faceObjs: [AVMetadataObject]) -> [AVMetadataObject] {
        var faceArr = [AVMetadataObject]()
        for face in faceObjs {
            if let transFace = previewLayer.transformedMetadataObject(for: face){
                faceArr.append(transFace)
            }
        }
        return faceArr
    }
    
    fileprivate func creatFaceLayer() -> CALayer{
        let layer = CALayer()
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 3
        return layer
    }
    
    fileprivate func transformDegress(yawAngle: CGFloat) -> CATransform3D {
        let yaw = degreesToRadians(degress: yawAngle)
        let yawTran = CATransform3DMakeRotation(yaw, 0, -1, 0)
        return CATransform3DConcat(yawTran, CATransform3DIdentity)
    }
    
    fileprivate func transformDegress(rollAngle: CGFloat) -> CATransform3D {
        let roll = degreesToRadians(degress: rollAngle)
        return CATransform3DMakeRotation(roll, 0, 0, 1)
    }
    
    fileprivate func degreesToRadians(degress: CGFloat) -> CGFloat{
        return degress * CGFloat(Double.pi) / 180
    }
    
    fileprivate func CATransform3DMakePerspective(eyePosition: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / eyePosition
        return transform
    }
}
