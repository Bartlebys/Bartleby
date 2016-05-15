import Alamofire
import ObjectMapper
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

if let u=ext.fetchInstance(User.self, instanceCallBack: <#T##((instance: T?) -> ())##((instance: T?) -> ())##(instance: T?) -> ()#>)


// Compilable
if let u:Locker=ext.toLocalInstance(){
    u.UID // Will never occur.
}


//: [Go to aliases experiment