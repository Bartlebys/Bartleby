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


// Merge sample
var benoit=User()
benoit.firstname="Benoit"
benoit.lastname="Pereira da Silva"
var melanie=User()
melanie.firstname="Melanie"
melanie.lastname="Le Neveu"
try? benoit.mergeWith(melanie)
benoit.firstname
benoit.lastname

//: [Next](@next)
