//: [Previous](@previous)

import Alamofire
import ObjectMapper
import BartlebyKit

var document=BartlebyDocument()
var userA=document.newUser()
var spy=document.newUser()

userA.addChangesObserver(spy) { (key, oldValue, newValue) in
    if let nonNilvalue=newValue{
        print("\(key) of \(userA.UID) has been set to \(nonNilvalue)")
    }else{
        print("\(key) of \(userA.UID) is nil")
    }
}

userA.firstname="Nina"
userA.firstname="Jimmy"

userA.disableSupervision()
userA.firstname="Hubert"
userA.enableSupervision()
userA.firstname="Alfred"

userA.removeChangesObserver(spy)
userA.firstname="Zorro"

//: [Next](@next)
