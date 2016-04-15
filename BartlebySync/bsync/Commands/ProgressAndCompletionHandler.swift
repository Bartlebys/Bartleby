
//
//  ProgressAndCompletionHandler.swift
//  BsyncXPC
//
//  Created by Benoit Pereira da silva on 22/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation



@objc(ProgressAndCompletionHandler) public class ProgressAndCompletionHandler:NSObject{
    
    // MARK: Versatile completion
    
    var progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?)->())?
    
    func addProgressBlock(progressBlock:((taskIndex:Int,totalTaskCount:Int,taskProgress:Double,message:String?)->())){
        self.progressBlock=progressBlock
    }
    
    // MARK: Versatile completion
    
    /// This completion block is used when not running as a commandline
    var completionBlock:((success:Bool,message:String?)->())
    
    init(completionBlock:((success:Bool,message:String?)->())){
        self.completionBlock=completionBlock
    }
    
}