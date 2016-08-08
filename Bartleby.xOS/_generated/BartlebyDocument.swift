//
//  BartlebyDocument.swift
//
//  The is the central piece of the Document oriented architecture.
//  We provide a universal implementation with conditionnal compilation
//
//  The document stores references to Bartleby's style CollectionControllers.
//  This allow to use intensively bindings and distributed data automation.
//  With the mediation of standard Bindings approach with NSArrayControler
//
//  We prefer to centralize the complexity of data handling in the document.
//  Thats why for example we implement projectBindingsArrayController.didSet with an CGD dispatching
//  We could have set the binding programmatically in the WindowController
//  But we consider for clarity that the Storyboarded Bindings Settings should be as exhaustive as possible.
//  And the potential complexity masked.
//
//  Generated by flexions
//

import Foundation

#if os(OSX)
import AppKit
#else
import UIKit
#endif



public class BartlebyDocument : JDocument {

    // MARK - Universal Type Support

    override public class func declareTypes() {
        super.declareTypes()
    }

    private var _KVOContext: Int = 0

    // Collection Controller
    // The initial instances are proxies
    // On document deserialization the collection are populated.

	public var tasks=TasksCollectionController(){
		didSet{
			tasks.registry=self
		}
	}
	
	public var tasksGroups=TasksGroupsCollectionController(){
		didSet{
			tasksGroups.registry=self
		}
	}
	
	public var users=UsersCollectionController(){
		didSet{
			users.registry=self
		}
	}
	
	public var lockers=LockersCollectionController(){
		didSet{
			lockers.registry=self
		}
	}
	
	public var groups=GroupsCollectionController(){
		didSet{
			groups.registry=self
		}
	}
	
	public var operations=OperationsCollectionController(){
		didSet{
			operations.registry=self
		}
	}
	
	public var permissions=PermissionsCollectionController(){
		didSet{
			permissions.registry=self
		}
	}
	

    // MARK: - OSX
 #if os(OSX) && !USE_EMBEDDED_MODULES


    // KVO
    // Those array controllers are Owned by their respective ViewControllers
    // Those view Controller are observed here to insure a consistent persitency


    public var tasksArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            tasksArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.tasks.arrayController=tasksArrayController
            // Add observer
            tasksArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.tasksArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var tasksGroupsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            tasksGroupsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.tasksGroups.arrayController=tasksGroupsArrayController
            // Add observer
            tasksGroupsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksGroupsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.tasksGroupsArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var usersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            usersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.users.arrayController=usersArrayController
            // Add observer
            usersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.usersArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var lockersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            lockersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.lockers.arrayController=lockersArrayController
            // Add observer
            lockersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.lockersArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var groupsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            groupsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.groups.arrayController=groupsArrayController
            // Add observer
            groupsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedGroupsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.groupsArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var operationsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            operationsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.operations.arrayController=operationsArrayController
            // Add observer
            operationsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedOperationsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.operationsArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        

    public var permissionsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            permissionsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &self._KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.permissions.arrayController=permissionsArrayController
            // Add observer
            permissionsArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let indexes=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPermissionsIndexesKey] as? [Int]{
                let indexesSet = NSMutableIndexSet()
                indexes.forEach{indexesSet.addIndex($0)}
                self.permissionsArrayController?.setSelectionIndexes(indexesSet)
             }
        }
    }
        



#endif

    // indexes persistency

    
    static public let kSelectedTasksIndexesKey="selectedTasksIndexesKey"
    static public let TASKS_SELECTED_INDEXES_CHANGED_NOTIFICATION="TASKS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedTasks:[Task]?{
        didSet{
            if let tasks = selectedTasks {
                 let indexes:[Int]=tasks.map({ (task) -> Int in
                    return self.tasks.indexOf( { return $0.UID == task.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.TASKS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedTask:Task? { return self.selectedTasks?.first }
        
        

    
    static public let kSelectedTasksGroupsIndexesKey="selectedTasksGroupsIndexesKey"
    static public let TASKSGROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION="TASKSGROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedTasksGroups:[TasksGroup]?{
        didSet{
            if let tasksGroups = selectedTasksGroups {
                 let indexes:[Int]=tasksGroups.map({ (tasksGroup) -> Int in
                    return self.tasksGroups.indexOf( { return $0.UID == tasksGroup.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksGroupsIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.TASKSGROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedTasksGroup:TasksGroup? { return self.selectedTasksGroups?.first }
        
        

    
    static public let kSelectedUsersIndexesKey="selectedUsersIndexesKey"
    static public let USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedUsers:[User]?{
        didSet{
            if let users = selectedUsers {
                 let indexes:[Int]=users.map({ (user) -> Int in
                    return self.users.indexOf( { return $0.UID == user.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUsersIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.USERS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedUser:User? { return self.selectedUsers?.first }
        
        

    
    static public let kSelectedLockersIndexesKey="selectedLockersIndexesKey"
    static public let LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION="LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedLockers:[Locker]?{
        didSet{
            if let lockers = selectedLockers {
                 let indexes:[Int]=lockers.map({ (locker) -> Int in
                    return self.lockers.indexOf( { return $0.UID == locker.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockersIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.LOCKERS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedLocker:Locker? { return self.selectedLockers?.first }
        
        

    
    static public let kSelectedGroupsIndexesKey="selectedGroupsIndexesKey"
    static public let GROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION="GROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedGroups:[Group]?{
        didSet{
            if let groups = selectedGroups {
                 let indexes:[Int]=groups.map({ (group) -> Int in
                    return self.groups.indexOf( { return $0.UID == group.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedGroupsIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.GROUPS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedGroup:Group? { return self.selectedGroups?.first }
        
        

    
    static public let kSelectedOperationsIndexesKey="selectedOperationsIndexesKey"
    static public let OPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION="OPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedOperations:[Operation]?{
        didSet{
            if let operations = selectedOperations {
                 let indexes:[Int]=operations.map({ (operation) -> Int in
                    return self.operations.indexOf( { return $0.UID == operation.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedOperationsIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.OPERATIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedOperation:Operation? { return self.selectedOperations?.first }
        
        

    
    static public let kSelectedPermissionsIndexesKey="selectedPermissionsIndexesKey"
    static public let PERMISSIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION="PERMISSIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION"
    dynamic public var selectedPermissions:[Permission]?{
        didSet{
            if let permissions = selectedPermissions {
                 let indexes:[Int]=permissions.map({ (permission) -> Int in
                    return self.permissions.indexOf( { return $0.UID == permission.UID })!
                })
                self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPermissionsIndexesKey]=indexes
                NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.PERMISSIONS_SELECTED_INDEXES_CHANGED_NOTIFICATION, object: nil)
            }
        }
    }
    var firstSelectedPermission:Permission? { return self.selectedPermissions?.first }
        
        




    // MARK: - DATA life cycle

    /**

    In this func you should :

    #1  Define the Schema
    #2  Register the collections

    */
    override public func configureSchema(){

        // #1  Defines the Schema
        super.configureSchema()

        let taskDefinition = CollectionMetadatum()
        taskDefinition.proxy = self.tasks
        // By default we group the observation via the rootObjectUID
        taskDefinition.collectionName = Task.collectionName
        taskDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        taskDefinition.allowDistantPersistency = false
        taskDefinition.inMemory = false
        

        let tasksGroupDefinition = CollectionMetadatum()
        tasksGroupDefinition.proxy = self.tasksGroups
        // By default we group the observation via the rootObjectUID
        tasksGroupDefinition.collectionName = TasksGroup.collectionName
        tasksGroupDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        tasksGroupDefinition.allowDistantPersistency = false
        tasksGroupDefinition.inMemory = false
        

        let userDefinition = CollectionMetadatum()
        userDefinition.proxy = self.users
        // By default we group the observation via the rootObjectUID
        userDefinition.collectionName = User.collectionName
        userDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        userDefinition.allowDistantPersistency = true
        userDefinition.inMemory = false
        

        let lockerDefinition = CollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        // By default we group the observation via the rootObjectUID
        lockerDefinition.collectionName = Locker.collectionName
        lockerDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        lockerDefinition.allowDistantPersistency = true
        lockerDefinition.inMemory = false
        

        let groupDefinition = CollectionMetadatum()
        groupDefinition.proxy = self.groups
        // By default we group the observation via the rootObjectUID
        groupDefinition.collectionName = Group.collectionName
        groupDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        groupDefinition.allowDistantPersistency = true
        groupDefinition.inMemory = false
        

        let operationDefinition = CollectionMetadatum()
        operationDefinition.proxy = self.operations
        // By default we group the observation via the rootObjectUID
        operationDefinition.collectionName = Operation.collectionName
        operationDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        operationDefinition.allowDistantPersistency = false
        operationDefinition.inMemory = false
        

        let permissionDefinition = CollectionMetadatum()
        permissionDefinition.proxy = self.permissions
        // By default we group the observation via the rootObjectUID
        permissionDefinition.collectionName = Permission.collectionName
        permissionDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        permissionDefinition.allowDistantPersistency = true
        permissionDefinition.inMemory = false
        


        // Proceed to configuration
        do{

			try self.registryMetadata.configureSchema(taskDefinition)
			try self.registryMetadata.configureSchema(tasksGroupDefinition)
			try self.registryMetadata.configureSchema(userDefinition)
			try self.registryMetadata.configureSchema(lockerDefinition)
			try self.registryMetadata.configureSchema(groupDefinition)
			try self.registryMetadata.configureSchema(operationDefinition)
			try self.registryMetadata.configureSchema(permissionDefinition)

        }catch RegistryError.DuplicatedCollectionName(let collectionName){
            bprint("Multiple Attempt to add the Collection named \(collectionName)",file:#file,function:#function,line:#line)
        }catch {
            bprint("\(error)",file:#file,function:#function,line:#line)
        }

        // #2 Registers the collections
        do{
            try self.registerCollections()
        }catch{
        }
    }

    // MARK: - OSX specific

 #if os(OSX) && !USE_EMBEDDED_MODULES

    // MARK: KVO

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &_KVOContext else {
            // If the context does not match, this message
            // must be intended for our superclass.
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }

        // We prefer to centralize the KVO for selection indexes at the top level
        if let keyPath = keyPath, object = object {

                    
            if keyPath=="selectionIndexes" && self.tasksArrayController == object as? NSArrayController {
                if let tasks=self.tasksArrayController?.selectedObjects as? [Task] {
                    self.selectedTasks=tasks
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.tasksGroupsArrayController == object as? NSArrayController {
                if let tasksGroups=self.tasksGroupsArrayController?.selectedObjects as? [TasksGroup] {
                    self.selectedTasksGroups=tasksGroups
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.usersArrayController == object as? NSArrayController {
                if let users=self.usersArrayController?.selectedObjects as? [User] {
                    self.selectedUsers=users
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.lockersArrayController == object as? NSArrayController {
                if let lockers=self.lockersArrayController?.selectedObjects as? [Locker] {
                    self.selectedLockers=lockers
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.groupsArrayController == object as? NSArrayController {
                if let groups=self.groupsArrayController?.selectedObjects as? [Group] {
                    self.selectedGroups=groups
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.operationsArrayController == object as? NSArrayController {
                if let operations=self.operationsArrayController?.selectedObjects as? [Operation] {
                    self.selectedOperations=operations
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.permissionsArrayController == object as? NSArrayController {
                if let permissions=self.permissionsArrayController?.selectedObjects as? [Permission] {
                    self.selectedPermissions=permissions
                    return
                }
            }
            

        }

    }

    // MARK:  Delete currently selected items
    
    public func deleteSelectedTasks() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTasks{
            for item in selected{
                 self.tasks.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedTasksGroups() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTasksGroups{
            for item in selected{
                 self.tasksGroups.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedUsers() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedUsers{
            for item in selected{
                 self.users.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedLockers() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedLockers{
            for item in selected{
                 self.lockers.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedGroups() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedGroups{
            for item in selected{
                 self.groups.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedOperations() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedOperations{
            for item in selected{
                 self.operations.removeObject(item, commit:true)
            }
        }
    }
        

    public func deleteSelectedPermissions() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedPermissions{
            for item in selected{
                 self.permissions.removeObject(item, commit:true)
            }
        }
    }
        


    #else


    #endif
    
    #if os(OSX)

    required public init() {
        super.init()
        BartlebyDocument.declareTypes()    }
    #else

    public required init(fileURL url: NSURL) {
        super.init(fileURL: url)
        BartlebyDocument.declareTypes()    }

    #endif

    
    // MARK : new User facility 
    
    /**
    * Creates a new user
    * 
    * you should override this method to customize default (name, email, ...)
    * and call before returning :
    *   if(user.creatorUID != user.UID){
    *       // We don't want to add the current user to user list
    *       self.users.add(user, commit:true)
    *   }
    */
    public func newUser() -> User {
        let user=User()
        if let creator=self.registryMetadata.currentUser {
            user.creatorUID = creator.UID
        }else{
            // Autopoiesis.
            user.creatorUID = user.UID
        }
        user.spaceUID = self.registryMetadata.spaceUID
        user.document = self // Very important for the  document registry metadata current User
        return user
    }
        
      
        

}