# Barteby's CLI
Is a commandline tool that allow to create and update bartleby's apps. It is written in Swift 2.X and php.

# Commands

```shell
bartleby install -m <Manifest FilePath>
bartleby create <Manifest FilePath>
bartleby generate <Manifest FilePath>
bartleby update <Manifest FilePath>
```

## bartleby install
The create-app command creates generates and deploys a configured app nutshell.

## bartleby generate 
The flexions command invoke's bartleby generator, and deploys the generated resources.

## bartleby update 
The update command, checks if bartleby's core and dependencies are up to date, proceed to core and modules updates/


# Manifest specification

A manifest is a simple JSON file

```js
{	
	"application": {
	 
	  		"name":"myApp",
	  	 	"nameSpace:"SuperApp",
	  	 	"url":"https://<superapp>.com",
	  	 	"bundle":"../../BartlebyBundle1.0"
	 },
	 
	"Author" : {
	
		"firsname":"Benoit",
		"lastname":"Pereira da Silva",
		"company":"Chaosmos SAS",
		"url":"https://chaosmos.fr"
	
	},
	
	"deployments" : {
	
		"www.local" : {
				"use":"fs",
			 	"www":"../folderA/xxx/www"
		},
			 	 
		"xOS.local": {
				"use":"fs",
			 	"xOS":"../../superProject/xOS/src"
			
		},
		"android.local": {
				"use":"fs",
			 	"android":"../../superProject/android/src"
			
		},
		"www.distant" : {
				"use":"ftp",
			 	"server":"jonctions.com",
			 	"user":"bpds",
			 	"password":"heyhey",
			 	"path":"home/superapp/public_html/b"
		}	
		
	}
	
} 
	
```
