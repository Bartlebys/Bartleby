//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit

let separator = "------------------"


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument()


let metadata=RegistryMetadata()
let metadataExternalReference=ExternalReference(from:metadata)

metadata.serialize()
metadataExternalReference.serialize()

print(metadata.dictionaryRepresentation())
print(metadataExternalReference.dictionaryRepresentation())


let user=User()
user.defineUID()
user.email="bartleby@bartlebys.org"


// Synchronous syntax 
// when you are sure the external exists and is loaded
print("# Resolution #")
let ref=ExternalReference(iUID: user.UID,iTypeName: User.typeName())
if let resolved:User==.toLocalInstance(){
   print("\(user)")
}else{
print("**NOT RESOLVED**")
}



print(separator)

// Asynchronous
// This approach supports lazy distributed fetching
print("# Concretion #")
ref.fetchInstance { (instance) in
    if let user=instance {
        print("OK! \(user)")
    }else{
        print("**NO USER!**")
    }
}

print(separator)

let tag=Tag()
tag.color="Red"
let tagExternalReference=ExternalReference(from:tag)

let tag2=Tag()
tag2.color="Black"
let tag2ExternalReference=ExternalReference(from:tag2)

print(separator)

// False ExternalReference casting Tag to user
let errorTag=Tag()
errorTag.color="Green"
let errorTagExternalReference=ExternalReference(from:errorTag)
print(errorTagExternalReference.runTimeTypeName())
print(errorTagExternalReference.d_collectionName)

if let resolvedTag:Tag=tagExternalReference.toLocalInstance(){
    let color=resolvedTag.color
}


print(separator)

// Serialization

print("Serialization of an ExternalReference")

let data=tagExternalReference.serialize()

do{
    let a = try JSerializer.deserialize(data)
    print(a.dynamicType)

    if let deserializedExternalReference = try JSerializer.deserialize(data) as? ExternalReference{
    }
}
