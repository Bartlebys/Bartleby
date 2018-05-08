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
//  tasks.taskHandler = { box,index,taskSequence in
//      print("Mounting box#\(index): \(box.UID)")
//      document.bsfs.mount(boxUID: box.UID, progressed: { (progression) in
//          print(progression.message)
//      }, completed: { (completion) in
//          completion.success ? taskSequence.runTask(at:index+1) : taskSequence.end(completion)
//       })
//  }
//
//  tasks.start()

public struct SequenceOfTasks<T: Any> {
    fileprivate var _items: [T]

    public var taskHandler: (_ item: T, _ index: Int, _ sequence: SequenceOfTasks) -> Void = { _, index, sequence in sequence.runTask(at: index + 1) }

    public var end: CompletionHandler

    fileprivate var _index: Int = 0

    public init(items: [T], end: @escaping CompletionHandler) {
        _items = items
        self.end = end
    }

    public func start() {
        runTask(at: 0)
    }

    public func runTask(at index: Int) {
        if index == _items.count {
            end(Completion.successState())
        } else {
            let item = _items[index]
            taskHandler(item, index, self)
        }
    }
}
