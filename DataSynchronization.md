# How Data Synchronization Works?

`BartlebyKit` stores objects or entities in **collections**. Each entity is distinct by an absolutely unique identifier `UID`. Each collection is serialized in a file into a file wrapper. A group of collection forms a **Document**. Each document "lives" in a **DataSpace**. Some **Documents** may be grouped in the same **DataSpace** -they share the same users base and may cross-reference some entities. The Access Control Layer (ACL) is managed per **DataSpace**. **DataSpaces** are logically isolated by the **spaceUID** that is attached to each operation.

# Up and Down Streams

1. *UpStream* data Synchronization is performed by calling A Restful API (the collaboration server) 
2. *DownStream* data Synchronization is mediated by 'Server Sent Event' triggers that Transmit the operations **payloads** to the concerned members. 

*UpStream changes* are operated by the Client Supervision Loop `BartlebyDocument+Operations.swift` generally at 1Hz (total duration = 1 second + data upload + trigger index consignation. Operations are grouped by bunch in a FIFO sequential stack)

*DownStream Changes* are operated by the SSE server side and refreshed at 1hz (total duration : 1 second + transmission of the trigger + local integration)

Frequency can be changed client side and server side if necessary.

# CRUD/URD?

- C for **CREATE**, creation of a unique entity.
- U for **UPSERT**, creation and update is done with the same Endpoint.
- R for **READ**, to fetch the state of an entity.
- D for **DELETE**. 

Most of the entities are using the **URD** model, with only one exception: the "users" that are relying on a classical **CRUD** model for fine grained ACL (e.g: some may not have the right to UPDATE a user but can create a new One.)
  
# Principles

1. Operations are IdemPotents. (e.g: Already **Deleted** entity can be "re-deleted" **Void to Void**)
2. "The last who spoke is right" **Last Operation Wins** and determines the state of an entity deletion included.
3. UPSERT == CREATE == UPDATE. We use **UPSERT** for **CREATE** and **UPDATE** (excepted for users) 
	- An **Update** of a **Deleted** entity recreates the entity
	- If two client invoke a **Create** operation of an entity with same UID, it first state is updated by the second.
4. **Construction prevails on demolition**

*Principle #3 do not apply to Users*

## Let's suppose that User A & B are online
 
- A **CREATES** X1.0 ->  B **READS** X1.0
- A **DELETES** X1.0 ->  B **DELETES** X1
- A **CREATES** X2.0 ->  B **READS** X2.0
- A **UPDATES** X2.1 ->  B **READS** X2.1
- B **UPDATES** X2.2 ->  A **READS** X2.2
- (A **DELETES** X2.2 || B **DELETES** X2.2)  ->  B **DELETES** X2, A **DELETES** X2 **Resilient by Principle #1** 
- ... 


# Faults 

## Faults related to Reachability 

### time out or NetworkReachabilityManager listener call back

To be implemented in [issue #15] (https://github.com/Bartlebys/Bartleby/issues/15)
- In case of Reachability issue transition on -> off (and then possibly back off->on) 

## Divergences due to "Deletion during update"

- A **CREATES** Y1.0 -> B **READS** Y1.0  
- (B **UPDATES** Y1.1 || A **DELETES** Y1) 
+ A **READS** updated version Y1.1' so *A IS VALID*
+ B will receive the Deletion of Y1 -> B **DELETES** locally Y1 **B IS NOT VALID**

**Principle #4 infers that Y1 should exists and its valid state should be Y1.1**

## Divergences due to "Concurrent updates"

- A **CREATES** Y2.0 -> B **READS** Y2.0
- (B **UPDATES** Y2.0 to Y2.2 ||  A **UPDATES** Y2.0 to Y2.1)
+ A **READS** B Y2.2 *A IS VALID!* 
+ B **READS** Y2.1 -> **B IS NOT VALID!** B is divergent.

**Principle #1 infers that the valid state of Y2 is Y2.2**

## Divergences are temporary

+ Case Y1 if A **UPDATES** Y1.1 -> Y1.2 A & B will converge
+ Case Y2 if A **UPDATES** Y2.2 -> Y2.3 A & B will converge
+ Case Y1 if B **READS** Y1.1 A & B will converge
+ Case Y2 if B **READS** Y2.2 A & B will converge

## The server view is always convergent

If you extract part of document from the server, those parts will be at a given time convergent.

In the "Divergences are temporary" section we have demonstrated that:
> In any case if A or B perform any operation on a diverging entity, it state after a full up/down stream cycle A and B will be aligned.

## "Convergent" does not mean "up to date"

If a user stays offline its data is not synchronized. **Q.E.D.**

## How to detect and correct Divergences?

Each trigger has a unique primary trigger index per observationUID.
1. "Deletions divergences" **resolution**:when receiving an owned delete trigger index if it is inferior to last received Read trigger Index for this entity, we must be READ again the entity state on the server.
2. "Concurrent updates" case **resolution**: when receiving an owned update trigger index if it is inferior to last received Read trigger Index for this entity, we must be READ again the entity state on the server.


## Faults related to ACL 

### Status Code 403 on UPSERT and DELETE (extension possible to 406,412,417)

On ACL related fault we do not propagate the *blocked changes*, so the problem is always confined locally.
 
On Status code 403 we could cancel automatically the action because *If the user is not authorized to do something we could reflect the ACL locally.* But we prefer currently to put the operation in Quarantine and give the user a chance to resolve a conflict with other users or arbitrate what to do.


## Operations Quarantines (Non automatic fault resolution)

We want to reduce as much as possible the Quarantine cases!
An ACL Faults Operations are placed in Quarantine.

### Interactive Quarantine clean up procedure

To be implemented [Issue #22](https://github.com/Bartlebys/Bartleby/issues/22)

When an operation is in quarantine we should present a Synthesis to the user and Ask what to do.

A synthesis will explain the problem with the operation (Deletion of part of A Bunch Update, ACL issue).
The system will offer solutions candidats like : "Delete entity X locally."
The user must arbitrate or defer the Arbitration


# Trigger Continuity issues.

Trigger continuity issues are not real faults, but should remain rare. If this mecanism is used at high frequency it means there is a systemic problem that needs to be analyzed. 

We integrating a trigger if there is a *trigger index hole* bartleby tries to fill the gap. 
E.g : `BartlebyDocument+Triggers.swift grabMissingTriggerIndexes()` Continuity issues are logged via `bprint` under `TriggerContinuity` category.



#Transitions off-line/on-line and vice versa 

##Operations compression 

To be implemented [Issue #21](https://github.com/Bartlebys/Bartleby/issues/21)

### A is offline B is online

- A **CREATES** X2.0  -> *operation could be deleted*
- A **DELETES** X2 -> *operation could be deleted* **create + delete offline == nothing**
- A **CREATES** X3.0  -> *operation could be deleted*
- A **UPDATES** X3.1 -> *operation could be deleted*
- A **UPDATES** X3.2 -> *operation could be deleted*
- A **UPDATES** X3.3 -> **Could send ONE Creation with the Final State X3.3**

### B is online A will go online

- B **CREATES** X4.0 -> A (should not Read )
- B **UPDATES** X4.1 -> A (should not Read )
- B **UPDATES** X4.2 -> A *ONLY ONE READ COULD BE NECESSARY* (previous trigger should be automatically integrated) 

### Rejected compression proposal 

- B **CREATES** Z1.0 -> A (should not Read )
- B **CREATES** Z2.0 -> A (should not Read )  
- B **CREATES** Zn.0 =-> We could compress Z(1,2,n) and integrate automatically the previous triggers)

We could but, it will make the system less resilient to fault and could but more triggers in quarantine. 


## Transition Sequence 

1. *apply available Compression algorithm to reduce faults* and proceed to UpStream Sync.
2. *apply available Compression algorithm to reduce faults* then integrate all the Triggers by calling `TriggersAfterIndex.execute(...)` +
3. Connect to SSE.


# Risks of long Off-line periods

According to Principle #2 "The last who spoke is right", If You have Deleted or Updated some entity offline, let's say entity the "E1" a few day ago, and another user has updated 139 times this Entity "E1.139" since then, when you'll transition online your operation will delete his stuff.

Faults related to ACL may produce local deletions.

**We should encourage Online session!**

# Off line policies

You are free to enforce the ACL by a client side policy that reduce off-line impact.