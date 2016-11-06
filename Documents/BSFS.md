# How Bartleby's Synchronized File system Works?

Bartleby's Synchronized File system, synchronises automatically "boxed" set of files. It is built on the top of Bartleby core mechanisms (managedCollections, triggers,...) and provides an efficient way to synchronize and distribute files to be consumed by an app.

## KeyPoints:

### BSFS is Fast

- Synchronization is automatic as soon as node is available it synchronization starts
- When a file upload is in progress clients blocks downloads can start.
- Copies and Moves are done in real time.
- Repetitive blocks are reused (if you have multiple file with large shared part, they can share their blocks)
- Blocks can be zipped if relevant (for exemple JSON file) 

### BSFS is Secured

- BSFS supports Bartleby ACL + fine ACL additions (per UserUID) even when using a `.flk`
- "blocks" on the servers are AES128/256 encrypted on the client side 	- Hacked server files are secure
	- You can opt out 

### BSFS is Versatile

- Blocks sizes can be adapted to context (you can apply different strategies for small pieces to large video files)
- You can decide when to apply the local change (for example if you are playing a sound file of a synchronized playlist, the playlist file update may occur when you reach the end when the BSFS delegate validate the change)



# BSFS Models 

+ Node - Refers to A file , a folder or an Alias, and stores startAddress and length of its Blocks
+ Block - The model that reference a block file (the raw bytes chunks)
+ Box - A box reference sets of Nodes and Blocks

# Block Raw files 

The raw blocks (crypted or not) are stored in an App group container directory on the client, and on the server.

## Preservation 

All the raw block data including local file, and sync in progress blocks are preserved.
It mean you need at least twice the size of the synchronized files.
On node deletion the Blocks are erased.

## The block are grouped per folders 

We use the Uppercased 3 first components of the UID. 

```
The block "NkJFMTIyOEQtNTJDOC00MDMyLTkzRTctNDVDRDdCOUM1MkZC"
Would be in <container>/blocks/N/K/J
```

# Operations

+ CRUD Node(s)
+ CRUD Block(s)
+ UploadBlock - Creation and Update -
+ DownloadBlock 

UploadBlock and Download block should be ideally interruptible [PassThru?](http://php.net/manual/en/function.fpassthru.php)

# BSFS local API

BSFS api is fully documented in [BartlebyKit/core/BSFS.swift](https://github.com/Bartlebys/Bartleby/blob/master/Bartleby.xOS/core/BSFS.swift)

# File synchronization mechanisms

## Managed Collections reflects the box state in real time

When a node or a block is created, updated or deleted, it is automatically propagated to all the connected clients. The `document.nodes` & `document.blocks` are reflecting the `Box` state in real time.

- document.nodes
- document.blocks

## Metadata 

- `document.metadata.localBox` Reflects the local state.
- `document.metadata.nodesInProgress` A collection nodes with blocks download in progress, or not still assembled (waiting for delegate) ** TO BE VERIFIED ***


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

 The footer contains a Serialized Box

 - Box.nodes
 - Box.blocks
```


# Compression  

We are using LZFSE https://developer.apple.com/reference/compression/1665429-data_compression
# CryptoGraphy

We are using CommonCrypto


----
# Details on Models

## Node

```json
{
  {
  "name": "Node",
  "definition": {
    "description": "Bartleby's Synchronized File System: a node references a collection of blocks that compose a files, or an alias or a folder",
    "properties": {
      "externalID": {
        "type": "string",
        "description": "An external ID",
        "supervisable": true
      },
      "relativePath": {
        "type": "string",
        "description": "The boxed relative path",
        "supervisable": true
      },
      "proxyPath": {
        "type": "string",
        "description": "A relative path for a proxy file.",
        "supervisable": false
      },
      "blocksMaxSize": {
        "type": "integer",
        "description": "The max size of a block (defines the average size of the block last block excluded)",
        "default":"Int.max",
        "supervisable": true
      },
      "priority": {
        "type": "integer",
        "description": "The priority level of the node (is applicated to its block)",
        "default":"0",
        "supervisable": true
      },
      "blocksUIDS": {
        "schema": {
          "type": "array",
          "items": {
            "description": "An ordered list of the Block UIDS",
            "type": "string",
            "default": "[String]()",
            "supervisable": false,
            "cryptable": true
          }
        }
      },
      "authorized": {
        "schema": {
          "type": "array",
          "items": {
            "description": "The list of the authorized User.UID,(if set to [\"*\"] the block is reputed public). Replicated in any Block to allow pre-downloading during node Upload",
            "type": "string",
            "default": "[String]()",
            "supervisable": false,
            "cryptable": true
          }
        }
      },
        "nature": {
          "type": "enum",
          "instanceOf": "string",
          "emumPreciseType": "Node.Nature",
          "description": "The node nature",
          "enum": [
            "file",
            "folder",
            "alias",
            "flock"
          ],
          "default": ".file"
        },
        "size": {
          "type": "integer",
          "description": "The size of the file",
          "default":"Int.max",
          "supervisable": true
        },
        "referentNodeUID": {
          "type": "string",
          "description": "If nature is .alias the UID of the referent node, else can be set to self.UID or not set at all",
          "supervisable": true
        },
        "compressed": {
          "type": "boolean",
          "description": "If set to true the blocks should be compressed",
          "default": "true",
          "supervisable": true
        },
        "cryptedBlocks": {
          "type": "boolean",
          "description": "If set to true the blocks will be crypted",
          "default": "true",
          "supervisable": true
        }

    },
    "metadata": {
      "urdMode": false,
      "persistsLocallyOnlyInMemory": false,
      "persistsDistantly": true,
      "undoable": false
    }
  }
}
```
 
## Block 

```json
{
  "name": "Block",
  "definition": {
    "description": "Bartleby's Synchronized File System: a block references bytes",
    "properties": {
      "digest": {
        "type": "string",
        "description": "The SHA1 digest of the block",
        "supervisable": true
      },
      "authorized": {
        "schema": {
          "type": "array",
          "items": {
            "description": "Extracted from the node - to allow pre-downloading during node upload (if set to [\"*\"] the block is reputed public)",
            "type": "string",
            "default": "[String]()",
            "supervisable": false,
            "cryptable": true
          }
        }
      },
      "nodeUID": {
        "type": "string",
        "description": "The UID of the holding node",
        "supervisable": true
      },
      "address": {
        "type": "integer",
        "description": "The starting address of the block in each Holding Node (== the position of the block in the file)",
        "type": "integer",
        "default":0,
        "supervisable": true,
        "cryptable":true
      },
      "size": {
        "type": "integer",
        "description": "The size of the Block",
        "default":"Int.max",
        "supervisable": true
      },
      "priority": {
        "type": "integer",
        "description": "The priority level of the block (higher priority produces the block to be synchronized before the lower priority blocks)",
        "default":"0",
        "supervisable": true
      },
      "compressed": {
        "type": "boolean",
        "description": "should be compressed",
        "default": "true",
        "supervisable": true
      },
      "crypted": {
        "type": "boolean",
        "description": "If set to true authorized can be void",
        "default": "true",
        "supervisable": true
      }
    },
    "metadata": {
      "urdMode": false,
      "persistsLocallyOnlyInMemory": false,
      "persistsDistantly": true,
      "undoable": false
    }
  }
}
```

## Box

```json
{
  "name": "Box",
  "definition": {
    "description": "Bartleby's Synchronized File System: A box reference sets of Nodes and Blocks",
    "properties": {
      "nodes": {
        "schema": {
          "type": "array",
          "items": {
            "description": "BSFS: A collection nodes",
            "$ref": "#/definitions/Node",
            "default": "[Node]()",
            "supervisable": true
          }
        }
      },
      "blocks": {
        "schema": {
          "type": "array",
          "items": {
            "description": "BSFS: A collection nodes",
            "$ref": "#/definitions/Block",
            "default": "[Block]()",
            "supervisable": true
          }
        }
      }
    },
    "metadata": {
      "urdMode": false,
      "persistsLocallyOnlyInMemory": false,
      "persistsDistantly": true,
      "undoable": false
    }
  }
}
```

----

# To be defined 

##1. Is it necessary to support cancelable actions? If yes, How to cancel?

##2. How to deal with the deletion of the block folder?
Initially the block folder was in the synchronized folder (like git) 
I've decided to use a dedicated folder in the app container to preserve from hazardous deletion. 

# BSFS Daemon - Currently not implemented

A future OSX Daemon that Converts File system action to Api calls.
Coupled with a finder extension...



