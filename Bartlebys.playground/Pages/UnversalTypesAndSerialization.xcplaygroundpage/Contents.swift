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


let userAlias:Alias<User>=Alias(from:user)
let aliasDictionary=userAlias.dictionaryRepresentation()
print(aliasDictionary)

// Update the instance
user.email="nobody@nowhere.com"

// Verify the alias Resolution
let userReference=userAlias.toLocalInstance()
if userReference?.UID==user.UID{
    print("OK! Matching UID")
    // Verify that it points to the good reference.
    print("\(userReference!.email!)")
}else{
    print("Not Matching UID")
}
do {
    // Alias serialization
    let serializedAlias=userAlias.serialize()
    if let deserializedAlias = try JSerializer.deserialize(serializedAlias) as? Alias<User>{
        print("OK!")
    }else{
        print("NOT OK!")
    }
}catch {
    print(error)
}

/*
var counter=1
for (k,v) in Registry.universalMapping{
    print("\(counter) \(v)=>\(k)")
    counter += 1
}
*/


//: [Next](@next)
