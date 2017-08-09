# Relationships

There are three types of relationships :

1. "owns": A owns B
2. "ownedBy": B is owned by A
3. "free": C is freely related to D 


```Swift
public enum Relationship:String{

    /// Serialized into the Object
    case free = "free"
    case ownedBy = "ownedBy"

    /// "owns" is Computed at runtime during registration to determine the the Subject
    /// Ownership is computed asynchronously for better resilience to distributed pressure
    /// Check ManagedCollection.propagate()
    case owns = "owns"

}
```

## Creator

Each object has a unique creator. It gives ACL privileges but is not related to Bartleby Relationships mechanism!



# Erasure rules

When a piece of code call `erase()` on a ManagedModel it is deleted (and it owners relationships are cleaned) 

# Erasure Cascading rules

`if A owns B that owns C, deleting A would delete B and C.`

1. When an owner is deleted all its owned entities are erased (if no other co-owner is alive)
2. When an owned entity is deleted its owner survives.
3. When two entities are freely related deletion of one has no impact on this other.


## Notes

Check: `BartlebyKit/Bartleby.xOS/Core/extensions/ManagedModel+Erasure.swift` for implementation details.


# CleanUp "procedures"

You can override document.willErase method to cleanup external dependencies on erasure

## The BSFS case

- Box Owns Nodes
- Node Owns Blocks

When deleting a Box `document.willErase(self)` is called to allow destroy associated files.

```Swift
    open func willErase(_ instance:Collectible){
        if let o = instance as? Box {
            self.bsfs.unMount(boxUID: o.UID, completed: { (completed) in })
        }else if let _ = instance as? Node{
            // Cancel any pending operation
        }else if let o = instance as? Block {
            self.bsfs.deleteBlockFile(o)
        }
    }

```

This mechanism allows to run procedures on deletion.