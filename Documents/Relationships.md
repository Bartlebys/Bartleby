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

Each object has a unique creator. It gives ACL privileges but is not related to Bartleby Relationships mechanism.

# Deletion rules

1. when an owner is delete all its owned entities are erased.
2. when an owned entity is deleted its owner survives.
3. when two entities are freely related deletion of one has no impact on this other.

Deletions are cascaded : `if A owns B that owns C, deleting A would delete B and C.`


## BSFS

- Box Owns Nodes
- Node Owns Blocks