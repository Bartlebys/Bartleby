import Alamofire
import ObjectMapper
import BartlebyKit


Bartleby.please("Could you print \"hello world\" for me?")


let user=User()
user.defineUID()
user.email="bartleby@bartlebys.org"

//It is NOT Possible not to type the Alias
//let alias=Alias(from:user)
// You must constraint 
let alias:Alias<User>=Alias(from:user)
if let userFromAlias=alias.toLocalInstance(){
    userFromAlias.email
}

// NOT compilable
//if let u:Locker=userFromAlias.toLocalInstance(){}

let ext=ExternalReference(from:user)
if let u:User=ext.toLocalInstance(){
    u.email
}

// Compilable
if let u:Locker=ext.toLocalInstance(){
    u.UID // Will never occur.
}


//: [Go to aliases experiments](@next)


