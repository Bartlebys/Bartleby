//: [Previous](@previous)

import Foundation
import Alamofire
import ObjectMapper
import BartlebyKit


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument() // Required to declare the universal types

let user=User()
user.email="bartleby@bartlebys.org"

let dictionary=user.dictionaryRepresentation()
let data=user.serialize()
user.dynamicType.typeName()
user.runTimeTypeName()

do{
    let deserializedObject=try JSerializer.deserialize(data)
}catch{
    print(error)
}


let userExternalReference=ExternalReference(from:user)
let aliasDictionary=userExternalReference.dictionaryRepresentation()
print(aliasDictionary)

// Update the instance
user.email="nobody@nowhere.com"

// Verify the alias Resolution
if let userReference:User=userExternalReference.toLocalInstance(){
    if userReference.UID==user.UID{
        print("OK! Matching UID")
        // Verify that it points to the good reference.
        print("\(userReference.email!)")
    }else{
        print("Not Matching UID")
    }

}
do {
    // ExternalReference serialization
    let serializedExternalReference=userExternalReference.serialize()
    if let deserializedExternalReference:ExternalReference = try JSerializer.deserialize(serializedExternalReference) as?ExternalReference{
        print("OK!")
    }else{
        print("NOT OK!")
    }
}catch {
    print(error)
}

/*
var counter=1
for (k,v) in Registry