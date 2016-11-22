//
//  AppDelegate.swift
//  chat-swift
//
//  Created by pxh on 2016/11/21.
//  Copyright © 2016年 pxh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,EMChatManagerDelegate{

    let _connectionState : EMConnectionState = EMConnectionConnected
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white

        //初始化环信SDK，详细内容在APPDelegate+EaseMob.m文件中
        //SDK注册APNS文件的名字，需要与后台上传证书是时的名字--对应
        var apnsCertName  = ""
        #if DEBUG
            apnsCertName = "chatdemoui_dev"
        #else
            apnsCertName = "chatdemoui"
        #endif
        
        var appKey = UserDefaults.standard.string(forKey: "identifier_appkey")
        if appKey == nil {
            appKey = EaseMobAppKey
            UserDefaults.standard.set(appKey, forKey: "identifier_appkey")
        }
        
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

