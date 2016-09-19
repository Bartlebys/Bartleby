# How Data synchronization works in BartlebyKit?

## Local collections synchronization

1. *UpStream* data Synchronization is performed by calling A Restful API 
2. *DownStream* data Synchronization is mediated by 'Server Sent Event' triggers that Transmit Restful **READ** operations demands, or local **DELETION** commands. 

# Normal operations

*UpStream changes* are operated by the Client Supervision Loop. `BartlebyDocument+Operations.swift` 
generally at 1Hz (once per second) + data upload + trigger index consignation. Operations are grouped by bunch in a FIFO sequential stack.

*DownStream Changes* are operated by the SSE server side refresh  1hz (once per second) + transmission of the trigger + loading of the data + integration.

In normal conditions Upstream synchronization is a little bit faster than DownStream.

# URD/CRUD?

- U for UPSERT == CREATE == UPDATE, creation and update is done with the same Endpoint.
- R for READ, to fetch the state of an entity.
- D for DELETE. 

Most of the entities are using the URD model, with only one exception: the "users" that are relying on a classical CRUD model to provide a better ACL and Security context.(e.g: some may not have the right to UPDATE a user but can create a new One.)
  
# Principles

1. Operations are IdemPotents. (e.g **Void to Void** Already **Deleted** entity can be "re-deleted")
2. The **Last Operation Wins** and determines the state of an entity (deletion included).
3. An **Update** of a **Deleted** entity recreates the entity (because excepted for users CREATE == UPSERT).
4. If two client invoke a **Create** operation of an entity with same UID, it first state is updated by the second (because excepted for users CREATE == UPSERT).
5. **Construction prevails on demolition**

*Principle #3 and #4 do not apply to Users*

## Let's suppose that User A & B are online
 
- A **CREATES** X1.0 ->  B **READS** X1.0
- A **DELETES** X1.0 ->  B **DELETES** X1
- A **CREATES** X2.0 ->  B **READS** X2.0
- A **UPDATES** X2.1 ->  B **READS** X2.1
- B **UPDATES** X2.2 ->  A **READS** X2.2
- (A **DELETES** X2.2 || B **DELETES** X2.2)  ->  B **DELETES** X2, A **DELETES** X2 **Resilient by Principle #1** 
- ... 

# Divergences

## Divergences due to "Deletions"

- A **CREATES** Y1.0 -> B **READS** Y1.0  
- (B **UPDATES** Y1.1 || A **DELETES** Y1) 
+ A **READS** updated version Y1.1' so *A IS VALID*
+ B will receive the Deletion of Y1 -> B **DELETES** locally Y1 **B IS NOT VALID**

**Principle #4 infers that Y1 should exists and its valid state should be Y1.1**


## Divergences due to "Concurrent updates"

- A **CREATES** Y2.0 -> B **READS** Y2.0
- (B **UPDATES** Y2.0 to Y2.2 ||  A **UPDATES** Y2.0 to Y2.1)
+ A **READS** B Y2.2 *A IS VALID!* 
+ B **READS** Y2.1 -> **B IS NOT VALID!**

**Principle #1 infers that the valid state of Y2 is Y2.2**

## Divergences are temporary

+ Case Y1 if A **UPDATES** Y1.1 -> Y1.2 A & B will converge
+ Case Y2 if A **UPDATES** Y2.2 -> Y2.3 A & B will converge
+ Case Y1 if B **READS** Y1.1 A & B will converge
+ Case Y2 if B **READS** Y2.2 A & B will converge

## The server view is always convergent

If you extract part of document from the server, those parts will be at a given time convergent.

# Convergence !

In the "Divergences are temporary" section we have demonstrated that:

> In any case if A or B perform any operation on a diverging entity, it state after a full up/down stream cycle A and B will be aligned.

## How to detect and correct divergences?

Each trigger has a unique primary trigger index per observationUID.

1. "Deletions divergences" **resolution**:when receiving an owned delete trigger index if it is inferior to last received Read trigger Index for this entity, we must be READ again the entity state on the server.
2. "Concurrent updates" case **resolution**: when receiving an owned update trigger index if it is inferior to last received Read trigger Index for this entity, we must be READ again the entity state on the server.
 

#Transitions off-line -> on-line  

##Operations compression

### A is offline B is online

- A **CREATES** X2.0  -> *operation could be deleted*
- A **DELETES** X2 -> *operation could be deleted* **create + delete offline == nothing**
- A **CREATES** X3.0  -> *operation could be deleted*
- A **UPDATES** X3.1 -> *operation could be deleted*
- A **UPDATES** X3.2 -> *operation could be deleted*
- A **UPDATES** X3.3 -> **Could send ONE Creation with the Final State X3.3**


### B is offline A will go online

- B **CREATES** X4.0 -> A (should not Read )
- B **UPDATES** X4.1 -> A (should not Read )
- B **UPDATES** X4.2 -> A *ONLY ONE READ COULD BE NECESSARY* (previous trigger should be automatically integrated) 
- B **CREATES** Z1.0 -> A (should not Read )
- B **CREATES** Z2.0 -> A (should not Read )  
- B **CREATES** Zn.0 =-> *OPTIONAL* A could compress Z(1,2,n) and integrate automatically the previous triggers)

## Transition Sequence 

1. we proceed to UpStream Sync.
2. then integrate all the Triggers by calling `TriggersAfterIndex.execute(...)`
3. then we connect to SSE.

## Risks of long Off-line periods

According to Principle #2:
> The **Last Operation Wins** and determines the state of an entity (deletion included).

If You have Deleted or Updated some entity offline, let's say entity the "E1" a few day ago, and another user has updated 139 times this Entity "E1.139" since then, when you'll transition online your operation will delete his stuff.

**That's Why we should encourage Online session!**

