# How Bartleby's Synchronized File system Works?

Bartleby's Synchronized File system, synchronises automatically "boxed" set of files. It is built on the top of Bartleby core mechanisms (managedCollections, triggers,...) and provides an efficient way to synchronize and distribute files to be consumed by an app. It can replace iCloud File Management.

- BSFS has been designed to work Sandboxed environment, using a highly segmented approach.
- BSFS is focused on security, simplicity, and disk room foot print reduction.
- Boxed files are assembled on demand in a cache and destroyed when the box is not mounted.
- Those design choice have performances when opening a document and mounting a Box.

## BSFS synchronization is Fast

- Synchronization is automatic as soon as node is available it synchronization starts
- When a file upload is in progress clients blocks downloads can start.
- Copies and Moves are done in real time.
- Repetitive blocks are reused (if you have multiple file with large shared part, they can share their blocks)
- Blocks are compressed using LZ4.

## BSFS is Secured

- "blocks" on the servers are AES256 encrypted on the client side 	- Even if your server is Hacked your files are protected
- BSFS supports Bartleby ACL + fine ACL additions (per UserUID) even when using a `.flk`
- Blocks are incorruptibles (consumers always use a read copy and do not write back the data) 
 
## BSFS is Versatile

- You can decide when to apply the local change (for example if you are playing a sound file of a synchronized playlist, the playlist file update may occur when you reach the end when the BSFS delegate validate the change)
- You can synchronize ensemble of files embedding `Flocks`.
- You can serialize a full Box to a  `.flk` file (equivalent to a DMG)

# Models 

+ Box - A box is a logical unit to group Nodes (and therefore Blocks)
+ Node - Refers to A file , a folder or an Alias, and stores startAddress and length of its Blocks
+ Block - The model that reference a block file (the raw bytes chunks)


# Block Raw files 

The raw blocks are stored on the client, and on the server.

## Preservation 

All the raw block data including local file, and sync in progress blocks are preserved.
Files are uncompressed / decrypted on the fly.
On node deletion the Blocks are erased.

## The block are grouped per folders 

We use the Uppercased 3 first components of the UID. 

```
The block "NkJFMTIyOEQtNTJDOC00MDMyLTkzRTctNDVDRDdCOUM1MkZC"
is in <container>/blocks/N/K/J
```

# Operations

+ CRUD Box(es)
+ CRUD Node(s)
+ CRUD Block(s)
+ UploadBlock - Creation and Update -
+ DownloadBlock 

UploadBlock and Download block should be ideally interruptible [PassThru?](http://php.net/manual/en/function.fpassthru.php)

# BSFS local API

BSFS api is fully documented in [BartlebyKit/core/BSFS.swift](https://github.com/Bartlebys/Bartleby/blob/master/Bartleby.xOS/core/BSFS.swift)

# File synchronization mechanisms

## Managed Collections reflects the distributed Box state in real time

When a node or a block is created, updated or deleted, it is automatically propagated to all the connected clients. The `document.nodes` & `document.blocks` are reflecting the `Box` state in real time.

- document.nodes
- document.blocks
- document.boxes

## Current Local State

The current Local State Is encapsulated in BSFS' FSShadowContainer. The Shadows are the local projections of a given Entity and are not managed (not synchronized). The collections of `NodeShadow` and `BlockShadow` reflects the local state. **When the local boxes are up to date shadows and managed entities are bijective.**



## Uploads

1. when a node is created or updated it is dissassembled
2. Before to upload we Upsert & delete the blocks. The blocks are uploaded. Each upload operation *stores the blockUID and the SHA1 digest*. 
3. when a block upload is completed - the uploader triggers a `triggered_download` event

Notes: 
- Upload order depends on blocks priority.
- Uploads can be parallelized

## Downloads

1. On `triggered_download` event if the block exists in `document.blocks` the client starts to download the block. The download operation is *stores the blockUID and its SHA1 digest*.
2. At the end of any block download BSFS tries to assemble the node `_tryToAssembleNodesInProgress`

Before to apply any change in the box BSFS call its `BoxDelegate` that decides when to proceed. e.g:`blocksAreReady(node: Node, proceed: () -> ())`

## Interruption of uploads or downloads for expired blocks

When we receive a `BlockUpsert` Trigger, a `BlockDelete` trigger, a local Block Deletion, a local Block Upsert **we cancel all the uploads or downloads operations marked with that blockUID**. 


# Compression  

## Sample Data:

- mp4: 1,56 Go
- lzma: 773,7 Mo
- lzfse: 790,8 Mo
- lz4: 786,6 Mo

**We use "lz4+AES256+SHA1" by default.**

## Benchmarks on my mac book: 


+ Without SHA1:
	+ Encrypt Duration : 5.44316899776459 286.342087052614MB/s
	+ Decrypt Duration : 3.76625001430511 413.835609712588MB/s

+ With SHA1:
	+ Encrypt Duration : 6.39563596248627 243.698731469716MB/s
	+ Decrypt Duration : 4.78430503606796 325.775292179313MB/s

Memory footprint : < 50Mb

----
# Flocks

- bartleby's boxed archive format
- extension : .flk
- You can flock a Box image for a given user, it will extract all the files that user can acceded.

## Flocks usages 

### 1. archive a box for offline or separate canal transmission

Such an archive is :

- Integrated temporarily in a Document Wrapper
- Or transmitted has a separate file.

### 2. a flocked box that contains a grouped set of files. 

- Those `.flk` are include in a box.
- By default such `.flk` file are *unflocked* each time we access is parent box.

## Flocks Binary Format specs
 
```
 --------
 8Bytes for one Int -> footer size
 --------
 data
 --------
 footer
 --------

 The footer contains a Serialized Container
```

----
# Extended Models

- Chunk: a struct used by the chunker decoupled from Bartleby
- FSShadowContainer : A container used to serialize a local Shadowed container


# Tools

## Chunker

Is a high performance file *Chunker*, with a reduced memory foot print

In Real mode: 

- It cuts files to chunks and merge chunks into files efficiently.
- Is not coupled to higher level concept (uses its own struct Chunk)
 
In `.digestOnly` mode the Chunker 5 times faster and does not consume Disk Room:

- Is a high performance tools to compute the Chunk Model including its Digest.
- It can digest GB/s with a reduced memory foot print on an utility queue. 


### Benchmarks:

On a Robust Mac the Chunker performance may vary from dozens of MB/s to 2GB/s depending on the nature of the nodes.

```
Chunker . digestOnly on small files Duration 7.15675497055054 seconds
Number of files:33727
For 34077 blocks
1852 MB
258 MB/s
```

```
Chunker . digestOnly on large and little  files Duration 10.5638520121574 seconds
Number of files:12476
For 13950 blocks
15379 MB
1455 MB/s
Program ended with exit code: 0
```

```
Chunker . digestOnly on large files Duration 7.70704996585846 seconds
Number of files:33
For 1488 blocks
14665 MB
1902 MB/s
Program ended with exit code: 0
```



## DeltaAnalyzer

The goal of the DeltaAnalyzer is to compare and determine difference between a file and node.

- File to Block `deltaBlocks(fromFileAt path:String, to node:Node ...)`

 


# BSFS Daemon - Currently not implemented

A future OSX Daemon that Converts File system action to Api calls.
Coupled with a finder extension...



