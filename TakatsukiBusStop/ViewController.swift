//
//  ViewController.swift
//  TakatsukiBusStop
//
//  Created by 仲西 渉 on 2016/04/12.
//  Copyright © 2016年 nwatabou. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var destinationLabel: UILabel!

    @IBOutlet weak var firstTimeLabel: UILabel!

    @IBOutlet weak var secondTimeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //beaconの値取得関係の変数
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    
    let hour = NSDate()
    let HdataFormatter = NSDateFormatter()
    
    
    let minute = NSDate()
    let MdataFormatter = NSDateFormatter()
    
    
    let Hour = 0
    let Minute = 1
    let Nonstop = 2
    let CoreTimeOnly = 3
    
    var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "background.png")
        self.imageView.image = img
        

        
        // ロケーションマネージャを作成する
        self.trackLocationManager = CLLocationManager();
        
        // デリゲートを自身に設定
        self.trackLocationManager.delegate = self;
        
        // BeaconのUUIDを設定
        let uuid:NSUUID? = NSUUID(UUIDString: "00000000-7DE6-1001-B000-001C4DF13E76")
        
        //Beacon領域を作成
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "net.noumenon-th")
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            self.trackLocationManager.requestAlwaysAuthorization();
        }
        
        
        HdataFormatter.dateFormat = "HH"
        MdataFormatter.dateFormat = "mm"
        
    }
    
    
    //位置認証のステータスが変更された時に呼ばれる
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        // 認証のステータス
        let statusStr = "";
        print("CLAuthorizationStatus: \(statusStr)")
        
        
        print(" CLAuthorizationStatus: \(statusStr)")
        
        //観測を開始させる
        trackLocationManager.startMonitoringForRegion(self.beaconRegion)
        
    }
    
    
    
    
    //観測の開始に成功すると呼ばれる
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        
        print("didStartMonitoringForRegion");
        
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        trackLocationManager.requestStateForRegion(self.beaconRegion);
    }
    
    
    
    
    //領域内にいるかどうかを判定する
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
        
        switch (state) {
            
        case .Inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
            
            trackLocationManager.startRangingBeaconsInRegion(beaconRegion);
            // →(didRangeBeacons)で測定をはじめる
            break
            
        case .Outside:
            break
            
        case .Unknown:
            break
            
        }
    }
    
    
    
    
    //領域に入った時
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // →(didRangeBeacons)で測定をはじめる
        self.trackLocationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    
    
    
    //領域から出た時
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        //測定を停止する
        self.trackLocationManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    
    //領域内にいるので測定をする
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion){
        let beacon = beacons[0]
        
        let beaconNo = (beacon.minor).integerValue
        
        switch beaconNo {
        case 1:
            fileName = "TakatsukiBusStop"
            self.destinationLabel.text = "関西大学行き"
        
        case 2:
            fileName = "TondaBusStop"
            self.destinationLabel.text = "関西大学行き"
            
        case 11:
            fileName = "KU_TakatsukiBusStop"
            self.destinationLabel.text = "JR高槻駅北行き"
            
        case 12:
            fileName = "KU_TondaBusStop"
            self.destinationLabel.text = "JR富田駅北行き"
            
        default:
            fileName = "error"
        }
        
        
        //以下csvファイル参照処理
    
        //csvファイルのデータを格納する変数
        var result: [[String]] = []
        
        //読み込むファイル指定
        if let csvPath = NSBundle.mainBundle().pathForResource(fileName, ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines {
                (line, stop) -> () in
                result.append(line.componentsSeparatedByString(","))
            }
            
            let nowHour = HdataFormatter.stringFromDate(hour)
            let nowMinute = MdataFormatter.stringFromDate(minute)
            
            for i in 0 ..< result.count{
                if(result[i][Hour] == nowHour){
                    if(result[i][Minute] > nowMinute){
                        self.firstTimeLabel.text = result[i][Hour]+":"+result[i][Minute]

                        //直行便
                        if(result[i][Nonstop] == "t"){

                        }
                        break
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

