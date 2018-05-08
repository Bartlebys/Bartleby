//: [Previous](@previous)

import Alamofire
import BartlebyKit

var document = BartlebyDocument()
var userA = document.newObject() as User
var spy = document.newObject() as User

userA.addChangesSuperviser(spy) { key, _, newValue in
    if let nonNilvalue = newValue {
        print("\(key) of \(userA.UID) has been set to \(nonNilvalue)")
    } else {
        print("\(key) of \(userA.UID) is nil")
    }
}

userA.firstname = "Nina"
userA.firstname = "Jimmy"

userA.removeChangesSuperviser(spy)
userA.firstname = "Zorro"

// Merge sample
var benoit = User()
benoit.firstname = "Benoit"
benoit.lastname = "Pereira da Silva"
var melanie = User()
melanie.firstname = "Melanie"
melanie.lastname = "Le Neveu"
try? benoit.mergeWith(melanie)
benoit.firstname
benoit.lastname
