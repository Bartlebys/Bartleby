//
//  CreateUidCommand.swift
//  bsync
//
//  Created by Martin Delille on 08/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

class CreateUIDCommand: CommandBase {


      required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)

        do {
            try cli.parse()

            print(Bartleby.createUID())

            exit(EX_OK)
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
}
