//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit

let separator = "------------------"


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument()


let metadata=JRegistryMetadata()
let metadataExternalReference=ExternalReference<JRegistryMetadata>()

metadata.serialize()
metadataExternalReference.serialize()

print(metadata.dictionaryRepresentation())
print(metadataExternalReference.dictionaryRepresentation())


let user=User()
user.defineUID()
user.email="bartleby@bartlebys.org"


// Synchronous syntax 
// when you are sure the alias exists and is loaded
print("# Resolution #")
let alias=ExternalReference<User>(iUID: user.UID)
if let resolved:User=alias.toLocalInstance(){
   print("\(user)")
}else{
print("**NOT RESOLVED**")
}



print(separator)

// Asynchronous
// This approach supports lazy distributed fetching
print("# Concretion #")
let _=alias.fetchInstance { (instance) in
    if let user=instance {
        print("OK! \(user)")
    }else{
        print("**NO USER!**")
    }
}

print(separator)

let tag=Tag()
tag.color="Red"
let tagExternalReference:ExternalReference<Tag>=ExternalReference(from:tag)

let tag2=Tag()
tag2.color="Black"
let tag2ExternalReference:ExternalReference<Tag>=ExternalReference(from:tag2)

print(separator)

// False ExternalReference casting Tag to user
let errorTag=Tag()
errorTag.color="Green"
let errorTagExternalReference:ExternalReference<User>=ExternalReference(from:errorTag)
print(ExternalReference<User>.typeName())
print(errorTagExternalReference.runTimeTypeName())
print(errorTagExternalReference.d_collectionName)

let resolveErrorTag=errorTagExternalReference.toLocalInstance()
let resolvetag=tagExternalReference.toLocalInstance()
let color=resolvetag?.color

print(separator)

// Serialization

print("Serialization of an ExternalReference")

let data=tagExternalReference.serialize()

do{
    let a = try JSerializer.deserialize(data)
    print(a.dynamicType)

    if let deserializedExternalReference = try JSerializer.deserialize(data) as? ExternalReference<Tag>{
     