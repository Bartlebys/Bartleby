//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit

Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)

let user=User()
user.defineUID()
user.email="bpds@me.com"


// Synchronous syntax 
// when you are sure the alias exists and is loaded
let alias=Alias<User>(iUID: user.UID, iReferenceName: user.referenceName)
if let resolved:User=alias.toLocalInstance(){
    print("# Resolution #")
    print (resolved)
}else{
    print("**NOT RESOLVED**")
}


// Asynchronous
// This approach supports lazy distributed fetching
print("# Concretion #")
let _=alias.fetchInstance { (instance) in
    if let user=instance {
        print(user)
    }else{
        print("**NO USER!**")
    }
}
//: [Next page](@next)