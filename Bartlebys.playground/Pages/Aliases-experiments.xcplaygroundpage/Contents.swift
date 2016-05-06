//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)

let user=User()
user.defineUID()
user.email="bpds@me.com"
let alias=ConcreteAlias<User>(withInstanceUID: user.UID, rn: user.referenceName)

print (user)

let _=alias.toConcrete { (instance) in
    if let user=instance {
        print(user)
    }
}
//: [Next page](@next)
