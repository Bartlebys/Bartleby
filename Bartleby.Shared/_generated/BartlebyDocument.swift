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

	public var tasks=TasksCollectionController()
	public var tasksGroups=TasksGroupsCollectionController()
	public var users=UsersCollectionController()
	public var lockers=LockersCollectionController()
	public var groups=GroupsCollectionController()
	public var operations=OperationsCollectionController()
	public var permissions=PermissionsCollectionController()

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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTaskIndexKey] as? Int{
               if self.tasks.items.count > index{
                   let selection=self.tasks.items[index]
                   self.tasksArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksGroupIndexKey] as? Int{
               if self.tasksGroups.items.count > index{
                   let selection=self.tasksGroups.items[index]
                   self.tasksGroupsArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUserIndexKey] as? Int{
               if self.users.items.count > index{
                   let selection=self.users.items[index]
                   self.usersArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockerIndexKey] as? Int{
               if self.lockers.items.count > index{
                   let selection=self.lockers.items[index]
                   self.lockersArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedGroupIndexKey] as? Int{
               if self.groups.items.count > index{
                   let selection=self.groups.items[index]
                   self.groupsArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedOperationIndexKey] as? Int{
               if self.operations.items.count > index{
                   let selection=self.operations.items[index]
                   self.operationsArrayController?.setSelectedObjects([selection])
                }
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
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPermissionIndexKey] as? Int{
               if self.permissions.items.count > index{
                   let selection=self.permissions.items[index]
                   self.permissionsArrayController?.setSelectedObjects([selection])
                }
             }
        }
    }
        



#endif

//Focus indexes persistency

    static public let kSelectedTaskIndexKey="selectedTaskIndexKey"
    static public let TASK_SELECTED_INDEX_CHANGED_NOTIFICATION="TASK_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedTask:Task?{
        didSet{
            if let task = selectedTask {
                if let index=tasks.items.indexOf(task){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTaskIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.TASK_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedTasksGroupIndexKey="selectedTasksGroupIndexKey"
    static public let TASKSGROUP_SELECTED_INDEX_CHANGED_NOTIFICATION="TASKSGROUP_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedTasksGroup:TasksGroup?{
        didSet{
            if let tasksGroup = selectedTasksGroup {
                if let index=tasksGroups.items.indexOf(tasksGroup){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTasksGroupIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.TASKSGROUP_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedUserIndexKey="selectedUserIndexKey"
    static public let USER_SELECTED_INDEX_CHANGED_NOTIFICATION="USER_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedUser:User?{
        didSet{
            if let user = selectedUser {
                if let index=users.items.indexOf(user){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedUserIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.USER_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedLockerIndexKey="selectedLockerIndexKey"
    static public let LOCKER_SELECTED_INDEX_CHANGED_NOTIFICATION="LOCKER_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedLocker:Locker?{
        didSet{
            if let locker = selectedLocker {
                if let index=lockers.items.indexOf(locker){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedLockerIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.LOCKER_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedGroupIndexKey="selectedGroupIndexKey"
    static public let GROUP_SELECTED_INDEX_CHANGED_NOTIFICATION="GROUP_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedGroup:Group?{
        didSet{
            if let group = selectedGroup {
                if let index=groups.items.indexOf(group){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedGroupIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.GROUP_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedOperationIndexKey="selectedOperationIndexKey"
    static public let OPERATION_SELECTED_INDEX_CHANGED_NOTIFICATION="OPERATION_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedOperation:Operation?{
        didSet{
            if let operation = selectedOperation {
                if let index=operations.items.indexOf(operation){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedOperationIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.OPERATION_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        

    static public let kSelectedPermissionIndexKey="selectedPermissionIndexKey"
    static public let PERMISSION_SELECTED_INDEX_CHANGED_NOTIFICATION="PERMISSION_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedPermission:Permission?{
        didSet{
            if let permission = selectedPermission {
                if let index=permissions.items.indexOf(permission){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedPermissionIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.PERMISSION_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
                }
            }
        }
    }
        




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
        taskDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        taskDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        taskDefinition.allowDistantPersistency = false
        taskDefinition.inMemory = false
        

        let tasksGroupDefinition = CollectionMetadatum()
        tasksGroupDefinition.proxy = self.tasksGroups
        // By default we group the observation via the rootObjectUID
        tasksGroupDefinition.collectionName = TasksGroup.collectionName
        tasksGroupDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        tasksGroupDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        tasksGroupDefinition.allowDistantPersistency = false
        tasksGroupDefinition.inMemory = false
        

        let userDefinition = CollectionMetadatum()
        userDefinition.proxy = self.users
        // By default we group the observation via the rootObjectUID
        userDefinition.collectionName = User.collectionName
        userDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        userDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        userDefinition.allowDistantPersistency = true
        userDefinition.inMemory = false
        

        let lockerDefinition = CollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        // By default we group the observation via the rootObjectUID
        lockerDefinition.collectionName = Locker.collectionName
        lockerDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        lockerDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        lockerDefinition.allowDistantPersistency = true
        lockerDefinition.inMemory = false
        

        let groupDefinition = CollectionMetadatum()
        groupDefinition.proxy = self.groups
        // By default we group the observation via the rootObjectUID
        groupDefinition.collectionName = Group.collectionName
        groupDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        groupDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        groupDefinition.allowDistantPersistency = true
        groupDefinition.inMemory = false
        

        let operationDefinition = CollectionMetadatum()
        operationDefinition.proxy = self.operations
        // By default we group the observation via the rootObjectUID
        operationDefinition.collectionName = Operation.collectionName
        operationDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        operationDefinition.storage = CollectionMetadatum.Storage.MonolithicFileStorage
        operationDefinition.allowDistantPersistency = false
        operationDefinition.inMemory = false
        

        let permissionDefinition = CollectionMetadatum()
        permissionDefinition.proxy = self.permissions
        // By default we group the observation via the rootObjectUID
        permissionDefinition.collectionName = Permission.collectionName
        permissionDefinition.observableViaUID = self.registryMetadata.rootObjectUID
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
                if let task=self.tasksArrayController?.selectedObjects.first as? Task{
                    self.selectedTask=task
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.tasksGroupsArrayController == object as? NSArrayController {
                if let tasksGroup=self.tasksGroupsArrayController?.selectedObjects.first as? TasksGroup{
                    self.selectedTasksGroup=tasksGroup
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.usersArrayController == object as? NSArrayController {
                if let user=self.usersArrayController?.selectedObjects.first as? User{
                    self.selectedUser=user
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.lockersArrayController == object as? NSArrayController {
                if let locker=self.lockersArrayController?.selectedObjects.first as? Locker{
                    self.selectedLocker=locker
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.groupsArrayController == object as? NSArrayController {
                if let group=self.groupsArrayController?.selectedObjects.first as? Group{
                    self.selectedGroup=group
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.operationsArrayController == object as? NSArrayController {
                if let operation=self.operationsArrayController?.selectedObjects.first as? Operation{
                    self.selectedOperation=operation
                    return
                }
            }
            

            
            if keyPath=="selectionIndexes" && self.permissionsArrayController == object as? NSArrayController {
                if let permission=self.permissionsArrayController?.selectedObjects.first as? Permission{
                    self.selectedPermission=permission
                    return
                }
            }
            

        }

    }

    // MARK:  Delete currently selected items
    
    public func deleteSelectedTask() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTask{
            self.tasks.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedTasksGroup() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTasksGroup{
            self.tasksGroups.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedUser() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedUser{
            self.users.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedLocker() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedLocker{
            self.lockers.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedGroup() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedGroup{
            self.groups.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedOperation() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedOperation{
            self.operations.removeObject(selected, commit:true)
        }
    }
        

    public func deleteSelectedPermission() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedPermission{
            self.permissions.removeObject(selected, commit:true)
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
    
    public func newUser() -> User {
        let user=User()
        if let creator=self.registryMetadata.currentUser {
            user.creatorUID = creator.UID
            user.spaceUID = creator.spaceUID
        }
        self.users.add(user, commit:true)
        return user
    }
        
      
        

}
