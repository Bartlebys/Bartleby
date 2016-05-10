//: [Previous page](@previous)
import Alamofire
import ObjectMapper
import BartlebyKit

let separator = "------------------"


Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument()


let metadata=JRegistryMetadata()
let metadataAlias=Alias<JRegistryMetadata>()

metadata.serialize()
metadataAlias.serialize()

print(metadata.dictionaryRepresentation())
print(metadataAlias.dictionaryRepresentation())


let user=User()
user.defineUID()
user.email="bartleby@bartlebys.org"

// Synchronous syntax 
// when you are sure the alias exists and is loaded
print("# Resolution #")
let alias=Alias<User>(iUID: user.UID)
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
let tagAlias:Alias<Tag>=Alias(from:tag)

let tag2=Tag()
tag2.color="Black"
let tag2Alias:Alias<Tag>=Alias(from:tag2)

print(separator)

// False Alias casting Tag to user
let errorTag=Tag()
errorTag.color="Green"
let errorTagAlias:Alias<User>=Alias(from:errorTag)
print(Alias<User>.typeName())
print(errorTagAlias.runTimeTypeName())
print(errorTagAlias.d_collectionName)

let resolveErrorTag=errorTagAlias.toLocalInstance()
let resolvetag=tagAlias.toLocalInstance()
let color=resolvetag?.color

print(separator)

// Serialization

print("Serialization of an Alias")

let data=tagAlias.serialize()

do{
    let a = try JSerializer.deserialize(data)
    print(a.dynamicType)

    if let deserializedAlias = try JSerializer.deserialize(data) as? Alias<Tag>{
        print("OK! DESERIALIZED")
        if let deserializedTag=deserializedAlias.toLocalInstance() {
            print("OK! The color of the tag is \(deserializedTag.color!)")
        }
    }else{
        print("NOT DESERIALIZED")
    }
}catch{
    print(error)
}



//: [Next page](@next)

