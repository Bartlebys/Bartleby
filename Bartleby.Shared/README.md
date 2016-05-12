# Concepts
This document summarizes BartlebyKit essential concepts. 

## Bartleby

Bartleby orchestrates the access to registries ... 

## registries / registry

+ One NSDocument == One Registry 
+ One registry == N x collections of entities grouped in a unique dataspace.

### registry.registryMetadata

### registry.rootObject

## dataspace

A dataspace is defined by a "spaceUID" 
1. Its a server side grouping identifier that allows to discriminate sub collection of Objects. 
2. the spaceUID is also used locally by Bartleby.swift to resolve the collaboration server URL.
3. A user is located in a Single "dataspace" characterized by in a unique spaceUID
4. Only one User is the spaceUID creator.

## Locker 

A locker is a piece of data that allows to deliver data securely to one targeted user

- Owner = locker.creatorUID
- What ? = locker.subjectUID
- Who can unlock ? = locker.userUID
- When ? = locker.startDate > < locker.endDate (Local or distant)
- How ? = ciphered(locker.code) == proposedCode

### Locker Security policy 

#### Api Server side ACL Policy (first level)

1# A distant locker can be accessed only by Authenticated users.
2# A Locker can be "Created Updated Deleted" only by its creator. Locker.creatorUID
3# A locker cannot be read distantly but only verifyed
4# On successful verification the locker is returned with its cake :)

The cake can be used : 
+ as a part of a crypto key chain for crypto operation
+ to deliver securely any sensistive string encoded data.

#### Verification of the locker (second level)

Business Access Control
The user UID is controlled and the code is verifyed

-----

# TO BE MOVED IN ANOTHER DOCUMENT 

# Models #

```swift 
// This flag should be set to true when a collaborative server has acknowledge the object creation
var distributed:Bool=false
```

## Validation ##

Let's imagine a Project model

```swift
class Project : JObject{
    ...
    var score:Float=0
}
```

You can create 

```swift
extension Project{

// MARK : validation

func validateScore(raiseNumberPointer: AutoreleasingUnsafeMutablePointer<NSNumber?>,
                    error outError: NSErrorPointer) -> Bool {
    let raiseNumber = raiseNumberPointer.memory
    if raiseNumber == nil {
        let domain = "UserInputValidationErrorDomain"
        let code = 0
        let userInfo =
        [NSLocalizedDescriptionKey : "A project raise must be a number."]
        outError.memory = NSError(domain: domain,
            code: code,
        userInfo: userInfo)
        return false
    } else {
        return true
    }
}

```

# Consignation #

```
    
```

# Packages # 

1. *\_generated* some foundational models, endpoints, and collection controllers
2. *adapters* adapted sources (we currently support JSON)
3. *components* some secondary components
4. *core* contains Bartleby's core
5. *tools* some generic tools like Pluralization
7. *ui* minimal UI compatibility layer