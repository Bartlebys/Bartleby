# Bartleby ?

Bartleby is a robust framework that enables to build Fault Tolerant Natives Distributed Desktop & Mobile Apps. It provides an integrated full stack  (client & server sides)
Server are written in PHP and uses MongoDB as document store.

It offers a unique distributed execution strategy and a solid permission and security model that enables to build complex collaborative tools efficiently. 

It has been developed to be used in and is fully integrated with a code generator called 'Flexions'.

Bartleby 1.0 has been developed by Benoit Pereira da Silva [Benoit Pereira da Silva](https://pereira-da-silva.com) for [Chaosmos SAS](http://chaosmos.fr).
Bartleby is licensed  

# Bartleby's stack

1. BartlebyKit: the core framework for clients.
2. Bartleby Server: the core server 
3. Bartleby Client generated Classes: specific set of generated classes 
4. Bartleby Server generated Resources
5. Flexions 3.0 the code generator used to generate the parts.

# BartlebyKit 

1. **Model** or an entity is an atom of structured data.
2. **ManagedCollection** insure the local and distributed persistency of Models
3. **Operations** are client RESTful request to Bartleby's server
4. **Documents** insure the local persistency of collection + Document oriented app feature. 
5. **Bartleby** orchestrates the access to the documents.


+ One NSDocument == One Registry 
+ One registry == N x collections of entities grouped in a unique dataspace.

## BartlebyObject supervision
The change provisioning is related to multiple essential notions.

### **Supervision** is a local  "observation" mecanism
We use supervision to determine if an object has changed.Properties that are declared `supervisable` provision their changes using this method.

### **Commit**

Supervision determine if the change should be committed. 
Commit is the first phase of the **distribution** mecanism (the second is **Push**, and the Third Trigger and integration on another node) If auto-commit is enabled on any supervised change an object is marked  to be committed `_shouldBeCommitted=true`

### You can add **supervisers** to any BartlebyObject.
On supervised change the closure of the supervisers will be invoked.

### **Inspection** 
During debbuging or when  Bartleby's inspector is opened we record and analyse the changesIf document.changesAreInspectables we store in memory the changes changed Keys to allow  Bartleby's runtime inspections (we use  `KeyedChanges` objects)


# registry.registryMetadata
# registry.rootObject
# dataspace

A dataspace is defined by a "spaceUID" 
1. Its a server side grouping identifier that allows to discriminate sub collection of Objects. 
2. A user is located in a Single "dataspace" characterized by in a unique spaceUID

## Locker 

A locker is a piece of data that allows to deliver data securely to one targeted user
&
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
4# On successful verification the locker is returned with its data gems :)

The gems can be used : 
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
class Project : BartlebyObject{
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
