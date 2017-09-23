//
//  SequenceOfTasks.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2017.
//  Copyright © 2017 https://pereira-da-silva.com/ for Chaosmos SAS All rights reserved.
//

import Foundation

// Usage sample :
//
//
//  var tasks = SequenceOfTasks(items: boxes, end: { (completion) in
//    onCompletion(completion)
//  })
//
//  tasks.taskHandler = { box,index,sequence in
//      print("Mounting box#\(index): \(box.UID)")
//      document.bsfs.mount(boxUID: box.UID, progressed: { (progression) in
//          print(progression.message)
//      }, completed: { (completion) in
//          completion.success ? sequence.runTask(at:index+1) : chain.end(completion)
//       })
//  }
//
//  tasks.start()


struct SequenceOfTasks<T:Any> {

    var items:[T]

    var taskHandler:(_ item:T,_ index:Int,_ sequence:SequenceOfTasks)->() = { item,index,sequence in sequence.runTask(at:index+1) }

    var end:CompletionHandler
    
    fileprivate var _index:Int = 0
    
    init(items:[T],end:@escaping CompletionHandler ) {
        self.items = items
        self.end = end
    }
    
    func start(){
        self.runTask(at: 0)
    }
    
    func runTask(at index:Int){
        if index == items.count{
            self.end(Completion.successState())
        }else{
            let item = self.items[index]
            self.taskHandler(item,index,self)
        }
    }

}
