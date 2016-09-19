# Principles

1. THE LAST OPERATION PRIMES AND DETERMINES THE VALID STATE.
2. AN UPDATE OF A DELETED ITEM RECREATES THE ITEM (UPSERT).
3. IF AN ITEM IS CREATED TWICE (WITH THE SAME UID) THE FIRST STATE IS UPDATED WITH THE SECOND.
4. CONSTRUCTION PREVAILS ON DEMOLITION
 
# Normal operations

*Upstream changes* are operated by the Client Supervision Loop. `BartlebyDocument+Operations.swift` 
generally at 1Hz (once per second) + data upload + trigger index consignation. Operations are grouped by bunch in a FIFO sequential stack.

*Downstream Changes* are operated by the SSE server side refresh  1hz (once per second) + transmission of the trigger + loading of the data + integration.

In normal conditions Upstream synchronization is a little bit faster than DownStream.
 
## Let's suppose that User A & B are online
 
- A creates X1.0 ==>  B reads X1.0
- A deletes X1.0 ==>  B deletes X1
- A creates X2.0 ==>  B reads X2.0
- A updates X2.1 ==>  B reads X2.1
- B updates X2.2 ==>  A reads X2.2
- ... 

# Conflicts

## Deletion conflicts

- A creates Y1.0 ==> B reads Y1.0  
- A deletes Y1 ==> B has not read the trigger
+ B updates Y1.1 before reading trigger => A reads Y1.1' *A IS VALID*
+ B will receive the Delete of Y1 ==> B **B IS NOT VALID** should have Y1.1

**Principle 4 =>  Y1.1 is Valid**

## Concurrent updates conflicts

- A create Y2.0 ==> B reads Y2.0
- A update Y2.1 ==> B has not read the trigger
+ B update Y2.0->Y2.2 ==> A reads B Y2.2 *A IS VALID* 
+ B reads Y2.1 ==> **B IS NOT VALID**

**Principle 1 =>  infers that Y2.2 is Valid**

## Resolution of conflicts

In any case if A or B re-updates the conflicted entity A and B will be aligned and the "conflict" resolved. So the real question how to presume there is a conflict and proceed to a forced Upsert?


#Transitions off-line -> on-line  

##Operations compression

### A is offline B is online

- A creates X2.0  ==> *operation could be deleted*
- A deletes X2 ==> *operation could be deleted* **create + delete offline == nothing**
- A creates X3.0  ==> *operation could be deleted*
- A updates X3.1 ==> *operation could be deleted*
- A updates X3.2 ==> *operation could be deleted*
- A updates X3.3 ==> **Could send ONE Creation with the Final State X3.3**


### B is online A will go online

- B creates X4.0 ==> A (should not Read )
- B updates X4.1 ==> A (should not Read )
- B updates X4.2 ==> A *ONLY ONE READ COULD BE NECESSARY* (previous trigger should be automatically integrated) 
- B creates Z1.0
- B creates Z2.0
- B creates Zn.0 ===> *OPTIONAL* A could compress Z(1,2,n) and integrate automatically the previous triggers)

## Conflicts mitigation during transitions

