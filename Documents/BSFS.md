#BSFS

Bartleby's Synchronized File system (BFS) a synchronized file system. You can locate synchronized entry point node anywhere. It will create a .bsfs folder.

#.bsfs folder

	.bsfs/
			config.json // The destination info
			blocks/
				...
			transactions.json
			nodes.json
			blocks.json
				
# Models 

## Node

- UID
- externalID
- relativePath
- blocksMaxSize
- blocks[Block] ordered
- inclusiveAuthorization[UserUID] with public=false
- public=true
- alias?< relative nodeUID>
- size?
- folder:Bool
 
## Block 

- UID
- crc32
- holders[File.UID]
- addresses[positionInFile]  
- size in Bytes.
- zipped:Bool (1)
- crypted:Bool(2)

## FSTransaction

- UID
- Operations[BartlebyOperation]
- Status: committed,pushed

Each transaction in the local FS returns a transactionUID.
You can cancel any non completed Transactions

# Block files 

+ Raw block files.
+ filename = Block.UID
+ block are stored per folders the Uppercased 2 first components of the UID. (e.G = NkJFMTIyOEQtNTJDOC00MDMyLTkzRTctNDVDRDdCOUM1MkZC would be in /N/K/J/) locally in F/.bsfs/blocks/N/K/J


# Operation BartlebyOperation

## Generative

+ Node CRUD 
+ Block CRUD

## New Client TPL generative Operation

+ UploadBlock Creation and Update -> Triggers the BlockDescriptor on completion) 
+ DownloadBlock

UploadBlock and Download block should be ideally interruptible [PassThru?](http://php.net/manual/en/function.fpassthru.php)

# FS local API

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

## OpMode : 

- preserveBlocks
- useCache 


# FS delegate

Receives :

- fileShouldChange
- fileShouldBeDeleted

And respond when appropriate:

- proceed()

# Files Data

## In the document we have the Two Managed Collections that reflect the distant node:

- Nodes
- Blocks


## In Document.metadata we have : 

- localNodes:[Node]
- localBlock:[Block]


## BSFS Daemon 

Converts File system action to Api calls.



