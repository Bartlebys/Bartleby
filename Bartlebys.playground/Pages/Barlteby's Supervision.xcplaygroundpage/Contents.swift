//: [Previous](@previous)

import Alamofire
import ObjectMapper
import BartlebyKit

var document=BartlebyDocument()
var userA=document.newUser()
var spy=document.newUser()

userA.addChangesSuperviser(spy) { (key, oldValue, newValue) in
    if let nonNilvalue=newValue{
        print("\(key) of \(userA.UID) has been set to \(nonNilvalue)")
    }else{
        print("\(key) of \(userA.UID) is nil")
    }
}

userA.firstname="Nina"
userA.firstname="Jimmy"

userA.removeChangesSuperviser(spy)
userA.firstname="Zorro"

//: [Next](@ne