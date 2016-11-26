//: [Previous](@previous)

import Foundation
import Alamofire
import ObjectMapper
import BartlebyKit


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument()

let user=User()
user.email="bartleby@bartlebys.org"

let dictionary=user.dictionaryRepresentation()
let data=user.serialize()
user.dynamicType.typeName()
user.runTimeTypeName()

do{
    let deserializedObject:User=try JSerializer.deserialize(data) as! User

    print(deserializedObject.UID == user.UID)
    print(deserializedObject == user )

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
    if userReference==user{
        print("OK! USER UID")
        // Verify that it points to the good reference.
        print("\(userReference.email!)")
    }else{
        print("Not USER UID")
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

