//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit

//:
var message = ""
let separator = "------------------"


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
 // Important
BartlebyDocument.addUniversalTypesForAliases()


let metadata=JRegistryMetadata()
let metadataAlias=Alias<JRegistryMetadata>()

metadata.serialize()
metadataAlias.serialize()

print(metadata.dictionaryRepresentation())
print(metadataAlias.dictionaryRepresentation())


let user=User()
user.defineUID()
user.email="bpds@me.com"

// Synchronous syntax 
// when you are sure the alias exists and is loaded
message="# Resolution #"
let alias=Alias<User>(iUID: user.UID)
if let resolved:User=alias.toLocalInstance(){
    message="\(user)"
}else{
    message="**NOT RESOLVED**"
}


separator

// Asynchronous
// This approach supports lazy distributed fetching
message="# Concretion #"
let _=alias.fetchInstance { (instance) in
    if let user=instance {
        message="\(user)"
    }else{
        message="**NO USER!**"
    }
}

separator

let tag=Tag()
tag.color="Red"
let tagAlias:Alias<Tag>=Alias(from:tag)

let tag2=Tag()
tag2.color="Black"
let tag2Alias:Alias<Tag>=Alias(from:tag2)

NSStringFromClass(user.dynamicType)
NSStringFromClass(tag.dynamicType)
NSStringFromClass(tag2.dynamicType)
NSStringFromClass(alias.dynamicType)
NSStringFromClass(tagAlias.dynamicType)
NSStringFromClass(tag2Alias.dynamicType)

tag.dynamicType
tag.typeName()
tagAlias.dynamicType
tagAlias.typeName()


separator

// False Alias casting Tag to user
let errorTag=Tag()
errorTag.color="Green"
let errorTagAlias:Alias<User>=Alias(from:errorTag)
errorTagAlias.dynamicType
NSStringFromClass(errorTagAlias.dynamicType)
errorTagAlias.typeName()
errorTagAlias.d_collectionName

let resolveErrorTag=errorTagAlias.toLocalInstance()
let resolvetag=tagAlias.toLocalInstance()
let color=resolvetag?.color

//let errorColor=resolveErrorTag.color // <= Produces an error.

separator


NSStringFromClass(tagAlias.dynamicType)
tagAlias.typeName()


separator

// Serialization

message="Serialization of an Alias"

let data=tagAlias.serialize()

let a=JSerializer.sharedInstance.deserialize(data)
a.dynamicType

if let deserializedAlias=JSerializer.sharedInstance.deserialize(data) as? Alias<Tag>{
    message="DESERIALIZED"
    if let deserializedTag=deserializedAlias.toLocalInstance() {
        message="The color of the tag is \(deserializedTag.color!)"
    }
}else{
    message="NOT DESERIALIZED"
}

separator
//: [Next page](@next)

