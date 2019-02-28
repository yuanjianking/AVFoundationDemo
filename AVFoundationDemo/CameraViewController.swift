//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by linkage on 2019/2/25.
//  Copyright © 2019年 yuanjian. All rights reserved.
//

import UIKit
import AVFoundation

//識別された人間の顔を扱う
protocol HandleMetadataOutputDelegate {
    func handleOutput(didDetect faceObjects: [AVMetadataObject], previewLayer: AVCaptureVideoPreviewLayer)
}

class CameraViewController: UIViewController {

    fileprivate var session = AVCaptureSession()
    fileprivate var deviceInput: AVCaptureDeviceInput?
    fileprivate var previewLayer = AVCaptureVideoPreviewLayer()
    @IBOutlet weak var previewView: JunPreviewView!
    var faceDelegate: HandleMetadataOutputDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addScaningVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //停止扫描
        session.stopRunning()
    }
}

extension CameraViewController {
    fileprivate func addScaningVideo(){
        //1.入力デバイスの取得 (カメラ)
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        //2.入力デバイスに基づいて入力オブジェクトを作成する
        guard let deviceIn = try? AVCaptureDeviceInput(device: device) else { return }
        deviceInput = deviceIn
        
        //3.元のデータの出力オブジェクトを作成する
        let metadataOutput = AVCaptureMetadataOutput()
        
        //4.出力オブジェクトからのデータ出力をリッスンするようにエージェントを設定し、メインスレッドで更新します。
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        faceDelegate = previewView
        
        //5.出力品質の設定 (高画素出力)
        session.sessionPreset = .high
        
        //6.セッションへの入力と出力の追加
        if session.canAddInput(deviceInput!) {
            session.addInput(deviceInput!)
        }
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        
        //7.顔を識別します。
        metadataOutput.metadataObjectTypes = [.face]
        
        //8.プレビューレイヤーの作成
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
        
        //9.有効なスキャンエリア (デフォルトの画面領域全体) を設定します (値ごとに 0 ~ 1、座標の原点として画面の右上隅を使用)
        metadataOutput.rectOfInterest = previewView.bounds
        
        //10. スキャンの開始
        if !session.isRunning {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
    }
}


extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for face in metadataObjects {
            let faceObj = face as? AVMetadataFaceObject
            print(faceObj!)
        }
        
        faceDelegate?.handleOutput(didDetect: metadataObjects, previewLayer: previewLayer)
    }
}


