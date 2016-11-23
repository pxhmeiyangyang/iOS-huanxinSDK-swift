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
    
    var mainController : MainViewController?
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white

        //设置navi相关界面
        UINavigationBar.appearance().barTintColor = UIColor.blue
        UINavigationBar.appearance().tintColor = UIColor.init(red: 30, green: 167, blue: 252, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red]
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
        self.easemobApplication(application,
                                didFinishLaunchingWithOptions: launchOptions,
                                appkey: appKey!,
                                apnsCertName: apnsCertName,
                                otherConfig: [kSDKConfigEnableConsoleLogger:NSNumber.init(value: true)])
        
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
    //MARK:- EaseMob 初始化和推送等操作
    func easemobApplication(_ application : UIApplication, didFinishLaunchingWithOptions : [UIApplicationLaunchOptionsKey: Any]?, appkey: String, apnsCertName : String, otherConfig: NSDictionary){
        //注册登录状态监听
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange), name: NSNotification.Name(rawValue: KNOTIFICATION_LOGINCHANGE), object: nil)
        let value : Bool = self.isSpecifyServer()
        EaseSDKHelper.share().hyphenateApplication(application,
                                                   didFinishLaunchingWithOptions: didFinishLaunchingWithOptions,
                                                   appkey: appkey,
                                                   apnsCertName: apnsCertName,
                                                   otherConfig: [kSDKConfigEnableConsoleLogger : NSNumber.init(booleanLiteral: true),"easeSandBox" : NSNumber.init(value: value)])
        ChatDemoHelper.share()
        let isAutoLogin = EMClient.shared().isAutoLogin
        if isAutoLogin{
            NotificationCenter.default.post(name: NSNotification.Name(KNOTIFICATION_LOGINCHANGE), object: true)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(KNOTIFICATION_LOGINCHANGE), object: false)
        }
    }
    //将deviToken传给SSDK
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    // 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        let alert = UIAlertView.init(title: NSLocalizedString("apns.failToRegisterApns", Fail to register apns),
//                                     message: error.description,
//                                     delegate: nil,
//                                     cancelButtonTitle: NSLocalizedString("ok", "OK"))
//        alert.show()
    }
    //MARK:- login changed
    func loginStateChange(_ notification : Notification){
        let loginSuccess : Bool = notification.object as! Bool
        var navigationController : EMNavigationController?
        if loginSuccess{ //登录成功加载主控制窗口
        //加载申请通知的数据
            ApplyViewController.share().loadDataSourceFromLocalDB()
            if self.mainController == nil{
                self.mainController = MainViewController()
                navigationController = EMNavigationController.init(rootViewController: self.mainController!)
            }else{
                navigationController = self.mainController?.navigationController as? EMNavigationController
            }
            ChatDemoHelper.share().mainVC = self.mainController
            ChatDemoHelper.share().asyncGroupFromServer()
            ChatDemoHelper.share().asyncConversationFromDB()
            ChatDemoHelper.share().asyncPushOptions()
            
        }else{//登录失败加载登录页面控制器
            if self.mainController != nil{
                self.mainController?.navigationController?.popToRootViewController(animated: false)
            }
            self.mainController = nil
            ChatDemoHelper.share().mainVC = nil
            let loginController : LoginViewController = LoginViewController()
            navigationController = EMNavigationController.init(rootViewController: loginController)
        }
        navigationController?.navigationBar.accessibilityIdentifier = "navigationbar"
        self.window?.rootViewController = navigationController
    }
    
    func isSpecifyServer()->Bool{
        let ud = UserDefaults.standard
        
        let specifyServer : Bool = ud.bool(forKey: "identifier_enable")

        if specifyServer as Bool{

            var apnsCertName = ""
            
            #if DEBUG
                apnsCertName = "chatdemoui_dev";
            #else
                apnsCertName = "chatdemoui";
            #endif
            
            var appkey = ud.string(forKey: "identifier_appkey")

            if appkey == nil{
                appkey = "easemob-demo#no1"
                ud.set(appkey, forKey: "identifier_appkey")
            }
            
            var imServer = ud.string(forKey: "identifier_imserver")
            if imServer == nil{
                imServer = "120.26.12.158"
                ud.set(imServer, forKey: "identifier_imserver")
            }
            var imPort = ud.string(forKey: "identifier_import")
            if imPort == nil{
                imPort = "6717"
                ud.set(imPort, forKey: "identifier_import")
            }
            
            var restServer = ud.string(forKey: "identifier_restserver")
            if restServer == nil{
                restServer = "42.121.255.137"
                ud.set(restServer, forKey: "identifier_restserver")
            }
            
            let options = EMOptions.init(appkey: appkey)
            
            if !ud.bool(forKey: "enable_dns"){
                options?.enableDnsConfig = false
                options?.chatPort = Int32(ud.string(forKey: "identifier_import")!)!
                options?.chatServer = ud.string(forKey: "identifier_imserver")
                options?.restServer = ud.string(forKey: "identifier_restserver")
            }
            options?.apnsCertName = "chatdemoui_dev";
            options?.enableConsoleLog = true;
            EMClient.shared().initializeSDK(with: options)
            return true;
        }
        
        return false;
    }
    
}

