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


@objc(BartlebyDocument) public class BartlebyDocument : JDocument {

    // MARK - Aliases Universal Type Support

     public class func addUniversalTypesForAliases() {
		Registry.addUniversalTypeForAlias(Alias<BaseCollectionMetadatum>())
		Registry.addUniversalTypeForAlias(Alias<Task>())
		Registry.addUniversalTypeForAlias(Alias<TasksGroup>())
		Registry.addUniversalTypeForAlias(Alias<Progression>())
		Registry.addUniversalTypeForAlias(Alias<Completion>())
		Registry.addUniversalTypeForAlias(Alias<BaseRegistryMetadata>())
		Registry.addUniversalTypeForAlias(Alias<ObjectError>())
		Registry.addUniversalTypeForAlias(Alias<User>())
		Registry.addUniversalTypeForAlias(Alias<Locker>())
		Registry.addUniversalTypeForAlias(Alias<Group>())
		Registry.addUniversalTypeForAlias(Alias<Permission>())
		Registry.addUniversalTypeForAlias(Alias<Operation>())
		Registry.addUniversalTypeForAlias(Alias<Trigger>())
		Registry.addUniversalTypeForAlias(Alias<Tag>())
    }

    private var _KVOContext: Int = 0

    // Collection Controller
    // The initial instances are proxies
    // On document deserialization the collection are populated.

	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var tasksGroups=TasksGroupsCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var users=UsersCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var lockers=LockersCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var groups=GroupsCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var permissions=PermissionsCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var operations=OperationsCollectionController(enableKVO:true)
	// We enable KVO in Document context enabling discreet auto-commit)
	dynamic lazy public var triggers=TriggersCollectionController(enableKVO:true)

    // MARK: - OSX
 #if os(OSX) && !USE_EMBEDDED_MODULES


    // KVO
    // Those array controllers are Owned by their respective ViewControllers
    // Those view Controller are observed here to insure a consistent persitency


    weak public var tasksGroupsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            tasksGroupsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var usersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            usersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var lockersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            lockersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var groupsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            groupsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var permissionsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            permissionsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var operationsArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            operationsArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
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
        

    weak public var triggersArrayController: NSArrayController?{
        willSet{
            // Remove observer on previous array Controller
            triggersArrayController?.removeObserver(self, forKeyPath: "selectionIndexes", context: &_KVOContext)
        }
        didSet{
            // Setup the Array Controller in the CollectionController
            self.triggers.arrayController=triggersArrayController
            // Add observer
            triggersArrayController?.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &self._KVOContext)
            if let index=self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTriggerIndexKey] as? Int{
               if self.triggers.items.count > index{
                   let selection=self.triggers.items[index]
                   self.triggersArrayController?.setSelectedObjects([selection])
                }
             }
        }
    }
        



#endif

//Focus indexes persistency

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
        

    static public let kSelectedTriggerIndexKey="selectedTriggerIndexKey"
    static public let TRIGGER_SELECTED_INDEX_CHANGED_NOTIFICATION="TRIGGER_SELECTED_INDEX_CHANGED_NOTIFICATION"
    dynamic public var selectedTrigger:Trigger?{
        didSet{
            if let trigger = selectedTrigger {
                if let index=triggers.items.indexOf(trigger){
                    self.registryMetadata.stateDictionary[BartlebyDocument.kSelectedTriggerIndexKey]=index
                     NSNotificationCenter.defaultCenter().postNotificationName(BartlebyDocument.TRIGGER_SELECTED_INDEX_CHANGED_NOTIFICATION, object: nil)
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

        let tasksGroupDefinition = JCollectionMetadatum()
        tasksGroupDefinition.proxy = self.tasksGroups
        // By default we group the observation via the rootObjectUID
        tasksGroupDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        tasksGroupDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        tasksGroupDefinition.allowDistantPersistency = true
        tasksGroupDefinition.inMemory = false
        

        let userDefinition = JCollectionMetadatum()
        userDefinition.proxy = self.users
        // By default we group the observation via the rootObjectUID
        userDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        userDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        userDefinition.allowDistantPersistency = true
        userDefinition.inMemory = false
        

        let lockerDefinition = JCollectionMetadatum()
        lockerDefinition.proxy = self.lockers
        // By default we group the observation via the rootObjectUID
        lockerDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        lockerDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        lockerDefinition.allowDistantPersistency = true
        lockerDefinition.inMemory = false
        

        let groupDefinition = JCollectionMetadatum()
        groupDefinition.proxy = self.groups
        // By default we group the observation via the rootObjectUID
        groupDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        groupDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        groupDefinition.allowDistantPersistency = true
        groupDefinition.inMemory = false
        

        let permissionDefinition = JCollectionMetadatum()
        permissionDefinition.proxy = self.permissions
        // By default we group the observation via the rootObjectUID
        permissionDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        permissionDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        permissionDefinition.allowDistantPersistency = true
        permissionDefinition.inMemory = false
        

        let operationDefinition = JCollectionMetadatum()
        operationDefinition.proxy = self.operations
        // By default we group the observation via the rootObjectUID
        operationDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        operationDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        operationDefinition.allowDistantPersistency = false
        operationDefinition.inMemory = false
        

        let triggerDefinition = JCollectionMetadatum()
        triggerDefinition.proxy = self.triggers
        // By default we group the observation via the rootObjectUID
        triggerDefinition.observableViaUID = self.registryMetadata.rootObjectUID
        triggerDefinition.storage = BaseCollectionMetadatum.Storage.MonolithicFileStorage
        triggerDefinition.allowDistantPersistency = true
        triggerDefinition.inMemory = false
        


        // Proceed to configuration
        do{

			try self.registryMetadata.configureSchema(tasksGroupDefinition)
			try self.registryMetadata.configureSchema(userDefinition)
			try self.registryMetadata.configureSchema(lockerDefinition)
			try self.registryMetadata.configureSchema(groupDefinition)
			try self.registryMetadata.configureSchema(permissionDefinition)
			try self.registryMetadata.configureSchema(operationDefinition)
			try self.registryMetadata.configureSchema(triggerDefinition)

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
        

         if keyPath=="selectionIndexes" && self.permissionsArrayController == object as? NSArrayController {
            if let permission=self.permissionsArrayController?.selectedObjects.first as? Permission{
                self.selectedPermission=permission
                return
            }
        }
        

         if keyPath=="selectionIndexes" && self.operationsArrayController == object as? NSArrayController {
            if let operation=self.operationsArrayController?.selectedObjects.first as? Operation{
                self.selectedOperation=operation
                return
            }
        }
        

         if keyPath=="selectionIndexes" && self.triggersArrayController == object as? NSArrayController {
            if let trigger=self.triggersArrayController?.selectedObjects.first as? Trigger{
                self.selectedTrigger=trigger
                return
            }
        }
        



    }

    }

    // MARK:  Delete currently selected items
    
    public func deleteSelectedTasksGroup() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTasksGroup{
            self.tasksGroups.removeObject(selected)
        }
    }
        

    public func deleteSelectedUser() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedUser{
            self.users.removeObject(selected)
        }
    }
        

    public func deleteSelectedLocker() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedLocker{
            self.lockers.removeObject(selected)
        }
    }
        

    public func deleteSelectedGroup() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedGroup{
            self.groups.removeObject(selected)
        }
    }
        

    public func deleteSelectedPermission() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedPermission{
            self.permissions.removeObject(selected)
        }
    }
        

    public func deleteSelectedOperation() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedOperation{
            self.operations.removeObject(selected)
        }
    }
        

    public func deleteSelectedTrigger() {
        // you should override this method if you want to cascade the deletion(s)
        if let selected=self.selectedTrigger{
            self.triggers.removeObject(selected)
        }
    }
        


    #else


    #endif


    // MARK: - Actions

     public func pushOperations(handlers: Handlers)throws{
        try self.pushOperations(self.operations.items, handlers:handlers)
    }


     public func synchronize(handlers: Handlers){
        if let currentUser=self.registryMetadata.currentUser{
            currentUser.login(withPassword: currentUser.password, sucessHandler: {
                self.optimizeOperations()
                do {
                    try self.pushOperations(handlers)
                } catch {
                    handlers.on(Completion.failureState("Push operations has failed", statusCode: CompletionStatus.Expectation_Failed))
                }
                }, failureHandler: { (context) in
                handlers.on(Completion.failureStateFromJHTTPResponse(context))
            })
        }
    }

     public func optimizeOperations() {
        self.optimizeOperations(self.operations.items)
    }

    #if os(OSX)

    required public init() {
        super.init()
        BartlebyDocument.addUniversalTypesForAliases()    }
    #else

    public required init(fileURL url: NSURL) {
        super.init(fileURL: url)
        BartlebyDocument.addUniversalTypesForAliases()    }

    #endif

}
