import Cocoa
import BartlebyKit



Bartleby.please("Could you print \"hello world\" for me?")


let user=User()
user.defineUID()
user.email="bartleby@bartlebys.org"


// NOT compilable
//if let u:Locker=userFromExternalReference.toLocalInstance(){}

let ext=ExternalReference(from:user)
if let u:User=ext.toLocalInstance(){
    u.email
}

ext.fetchInstance(User.self){ (instance) in
    if let userInstance=instance{
       userInstance.email
    }
}

// User Tag ?
ext.fetchInstance(Tag.self){ (instance) in
    // WILL NEVER OCCUR
    if let instance=instance{
        instance.color
    }
}



if let u:Tag=ext.toLocalInstance(){
    u.UID // Will never occur.
}else{
    let eureka="We support types safety in external references"u
}
//: [Go to externalReferences](@next)

