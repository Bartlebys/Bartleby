# BSFS

Bartleby's Synchronized File system, synchronises automatically "boxed" set of files. It is built on the top of Bartleby core mechanisms (managedCollections, triggers,...) and provides an efficient way to synchronize and distribute files in a network of clients.

## KeyPoints:

### BSFS is Fast

- Synchronization is automatic as soon as node is available it synchronization starts
- When a file upload is in progress clients blocks downloads can start.
- Copies and Moves are done in real time.
- Repetitive blocks are reused (if you have multiple file with large shared part, they can share their blocks)
- Blocks can be zipped if relevant (for exemple JSON file) 

### BSFS is Securized

- BSFS supports Bartleby ACL plus, fine ACL additions (per UserUID
- "blocks" on the servers are AES128/256 encrypted on the client side 	- Hacked server files are secure
	- You can opt out 

### BSFS is Versatile

- Blocks sizes can be adapted to context (you can apply different strategies for small pieces to large video files)
- You can decide when to apply the local change (for example if you are playing a sound file of a synchronized playlist, the playlist file update may occur when you reach the end when the BSFS delegate validate the change)



# Models 

+ Box - The root folder node that contains all the nodes
+ Node - A file , a folder or an Alias that refers to its Blocks
+ Block - The model that reference a block file (the raw bytes chunks)
+ Transaction - A serialized BSFS operation with a comment


# Block files 

+ Raw block files.
+ filename = Block.UID
+ block are stored per folders the Uppercased 2 first components of the UID. (e.G = NkJFMTIyOEQtNTJDOC00MDMyLTkzRTctNDVDRDdCOUM1MkZC would be in /N/K/J/) locally in F/.bsfs/blocks/N/K/J


# Operation BartlebyOperation

## Generative

+ CRUD Box(es)
+ CRUD Node(s)
+ CRUD Block(s)


## New Client TPL generative Operation

+ UploadBlock Creation and Update -> 
+ DownloadBlock

UploadBlock and Download block should be ideally interruptible [PassThru?](http://php.net/manual/en/function.fpassthru.php)

# BSFS local API

## Mandatory: 

+ addFile(originalPath:String, relativePath:String, public:Bool, authorized:[String]?)
	+ copies the file to the FS 
	+ generates temp blocks
		+ upload each block 

+ remove(relativePath)
	+ removes the local node 
	+ call DeleteFile()
+ createAlias()
+ createFolder()
+ copy(sourceRelativePath:String,destinationRelativePath) copies + send CreateNode (no block need to be created)
+ move(sourceRelativePath:String,destinationRelativePath) moves + send UpdateNode (no block need to be created)

# BSFS delegate

Receives :

- fileShouldChange
- fileShouldBeDeleted

And respond when appropriate:

- proceed()
- 
# Data

## In the document we have Managed Collections that reflect the distant data

- Boxes
- Nodes
- Blocks

## in The ".bsfs" folder


###1 We have got of Boxes, Nodes, Blocks that reflect the current file system data

```
	.bsfs/
			transactions.json
			nodes.json
			blocks.json
			...
```

- transactions.json contains "[Transaction]"
- nodes.json contains "[Node]"
- blocks contains "[Block]"


###2 And the configuration 
  
```	
	.bsfs/
			...
			configuration.json 
			...
```

###3 the block data
  
```	
	.bsfs/
			...
			blocks/
					<block>
					<block>
					....
```


## Optional APi

If the files are manipulated out of the app, the local data may become outdated. 

+ scanBox(box:Box) 
	+ refreshes the local Boxes, Nodes, Blocks infos (CPU very intensive) 




----

# BSFS Daemon 

A future OSX Daemon that Converts File system action to Api calls.
Coupled with a finder extension...

----
# Details on Models

# Box

The box is the root of a synchronized folder it is a special Node

- You can locate synchronized Box node anywhere. It will create a ".bsfs" folder at its root.
- Boxes cannot be located in a Box.

```json
{
  "name": "Box",
  "definition": {
    "explicitType":"Node",
    "description": "Bartleby's Synchronized File System: the root of a synchronized folder (special Node)",
    "properties": {
      "serverURL": {
        "type": "URL",
        "description": "The server URL",
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

## Node

```json
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
      "boxUID": {
        "type": "string",
        "description": "The UID of the Box",
        "supervisable": true
      },
      "relativePath": {
        "type": "string",
        "description": "The boxed relative path",
        "supervisable": true
      },
      "blocksMaxSize": {
        "type": "integer",
        "description": "The max size of a block (defines the average size of the block last block excluded)",
        "default":"Int.max",
        "supervisable": true
      },
      "blocksUIDS": {
        "schema": {
          "type": "array",
          "items": {
            "description": "The ordered list of the Block UIDS",
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
            "description": "Used for ACL The authorized user UIDS ( can be void if noRestriction is set to true)",
            "type": "string",
            "default": "[String]()",
            "supervisable": false,
            "cryptable": true
          }
        }
      },
        "noRestriction": {
          "type": "boolean",
          "description": "If set to true authorized can be void",
          "default": "true",
          "supervisable": true
        },
        "nature": {
          "type": "enum",
          "instanceOf": "string",
          "emumPreciseType": "Node.Nature",
          "description": "The node nature",
          "enum": [
            "file",
            "folder",
            "alias"
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
        "zippedBlocks": {
          "type": "boolean",
          "description": "If set to true the blocks will be zipped",
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
      "holders": {
        "schema": {
          "type": "array",
          "items": {
            "description": "The Nodes' Holders UIDS",
            "type": "string",
            "default":"[String]()",
            "supervisable": false,
            "cryptable":true
          }
        }
      },
      "addresses": {
        "schema": {
          "type": "array",
          "items": {
            "description": "The starting address of the block in each Holding Node (== the position of the block in the file)",
            "type": "integer",
            "default":"[integer]()",
            "supervisable": false,
            "cryptable":true
          }
        }
      },
      "size": {
        "type": "integer",
        "description": "The size of the Block",
        "default":"Int.max",
        "supervisable": true
      },
      "zipped": {
        "type": "boolean",
        "description": "If set to true authorized can be void",
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

## Transaction

- Each transaction in the local FS returns a transactionUID.
- You can cancel any non completed Transactions

```json
{
  "name": "Transaction",
  "definition": {
    "description": "Bartleby's Synchronized File System: a transaction is an operation",
    "properties": {
      "comment": {
        "type": "string",
        "description": "the comment",
        "supervisable": true
      },
      "operations": {
        "schema": {
          "type": "array",
          "items": {
            "description": "The serialized operations (without the data)",
            "type": "string",
            "default":"[String]()",
            "supervisable": false,
            "cryptable":true
          }
        }
      },
      "status": {
        "type": "enum",
        "instanceOf": "string",
        "emumPreciseType": "Transaction.Status",
        "description": "Transaction Status",
        "enum": [
          "committed",
          "pushed"
        ],
        "default": ".committed"
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





