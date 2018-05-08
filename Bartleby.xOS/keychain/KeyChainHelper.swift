//
//  KeyChainHelper.swift
//  BartlebyKit

//
//  Derived from https://github.com/marketplacer/keychain-swift
//  by Benoit Pereira da silva on 22/01/2017.
//

import Security
import Foundation

open class KeyChainHelper {

    // The shared app access group e.g:
    open var accessGroup: String

    var lastQueryParameters: [String: Any]? // Used by the unit tests

    /// Contains result code from the last operation. Value is noErr (0) for a successful result.
    open var lastResultCode: OSStatus = noErr

    var keyPrefix = "" // Can be useful in test.

    /// Instantiate a KeyChainHelper object
    public init(accessGroup:String) {
        self.accessGroup=accessGroup
    }


    /**

     Specifies whether the items can be synchronized with other devices through iCloud. Setting this property to true will
     add the item to other devices with the `set` method and obtain synchronizable items with the `get` command. Deleting synchronizable items will remove them from all devices. In order for keychain synchronization to work the user must enable "Keychain" in iCloud settings.

     Does not work on macOS?

     */
    open var synchronizable: Bool = false


    /**

     Stores the text value in the keychain item under the given key.

     - parameter key: Key under which the text value is stored in the keychain.
     - parameter value: Text string to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.

     - returns: True if the text was successfully written to the keychain.

     */
    @discardableResult
    open func set(_ value: String, forKey key: String,
                  withAccess access: KeyChainHelperAccessOptions? = nil) -> Bool {

        if let value = value.data(using: String.Encoding.utf8) {
            return set(value, forKey: key, withAccess: access)
        }

        return false
    }

    /**

     Stores the data in the keychain item under the given key.

     - parameter key: Key under which the data is stored in the keychain.
     - parameter value: Data to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.

     - returns: True if the text was successfully written to the keychain.

     */
    @discardableResult
    open func set(_ value: Data, forKey key: String,
                  withAccess access: KeyChainHelperAccessOptions? = nil) -> Bool {

        delete(key) // Delete any existing key before saving it

        let accessible = access?.value ?? KeyChainHelperAccessOptions.defaultOption.value

        let prefixedKey = keyWithPrefix(key)

        var query: [String : Any] = [
            KeyChainHelperConstants.secClass    : kSecClassGenericPassword,
            KeyChainHelperConstants.attrAccount : prefixedKey,
            KeyChainHelperConstants.valueData   : value,
            KeyChainHelperConstants.accessible  : accessible
        ]

        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: true)
        lastQueryParameters = query

        lastResultCode = SecItemAdd(query as CFDictionary, nil)

        return lastResultCode == noErr
    }

    /**

     Stores the boolean value in the keychain item under the given key.

     - parameter key: Key under which the value is stored in the keychain.
     - parameter value: Boolean to be written to the keychain.
     - parameter withAccess: Value that indicates when your app needs access to the value in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.

     - returns: True if the value was successfully written to the keychain.

     */
    @discardableResult
    open func set(_ value: Bool, forKey key: String,
                  withAccess access: KeyChainHelperAccessOptions? = nil) -> Bool {

        let bytes: [UInt8] = value ? [1] : [0]
        let data = Data(bytes: bytes)

        return set(data, forKey: key, withAccess: access)
    }

    /**

     Retrieves the text value from the keychain that corresponds to the given key.

     - parameter key: The key that is used to read the keychain item.
     - returns: The text value from the keychain. Returns nil if unable to read the item.

     */
    open func get(_ key: String) -> String? {
        if let data = getData(key) {
            if let currentString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                return currentString
            }
            lastResultCode = -67853 // errSecInvalidEncoding
        }

        return nil
    }

    /**

     Retrieves the data from the keychain that corresponds to the given key.

     - parameter key: The key that is used to read the keychain item.
     - returns: The text value from the keychain. Returns nil if unable to read the item.

     */
    open func getData(_ key: String) -> Data? {
        let prefixedKey = keyWithPrefix(key)

        var query: [String: Any] = [
            KeyChainHelperConstants.secClass       : kSecClassGenericPassword,
            KeyChainHelperConstants.attrAccount : prefixedKey,
            KeyChainHelperConstants.returnData  : kCFBooleanTrue,
            KeyChainHelperConstants.matchLimit  : kSecMatchLimitOne
        ]

        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query

        var result: AnyObject?

        lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if lastResultCode == noErr { return result as? Data }

        return nil
    }

    /**

     Retrieves the boolean value from the keychain that corresponds to the given key.

     - parameter key: The key that is used to read the keychain item.
     - returns: The boolean value from the keychain. Returns nil if unable to read the item.

     */
    open func getBool(_ key: String) -> Bool? {
        guard let data = getData(key) else { return nil }
        guard let firstBit = data.first else { return nil }
        return firstBit == 1
    }

    /**

     Deletes the single keychain item specified by the key.

     - parameter key: The key that is used to delete the keychain item.
     - returns: True if the item was successfully deleted.

     */
    @discardableResult
    open func delete(_ key: String) -> Bool {
        let prefixedKey = keyWithPrefix(key)

        var query: [String: Any] = [
            KeyChainHelperConstants.secClass       : kSecClassGenericPassword,
            KeyChainHelperConstants.attrAccount : prefixedKey
        ]

        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query

        lastResultCode = SecItemDelete(query as CFDictionary)

        return lastResultCode == noErr
    }

    /**

     Deletes all Keychain items used by the app. Note that this method deletes all items regardless of the prefix settings used for initializing the class.

     - returns: True if the keychain items were successfully deleted.

     */
    @discardableResult
    open func clear() -> Bool {
        var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        lastQueryParameters = query

        lastResultCode = SecItemDelete(query as CFDictionary)

        return lastResultCode == noErr
    }

    /// Returns the key with currently set prefix.
    func keyWithPrefix(_ key: String) -> String {
        return "\(keyPrefix)\(key)"
    }

    func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        var result: [String: Any] = items
        result[KeyChainHelperConstants.accessGroup] = accessGroup
        return result
    }

    /**

     Adds kSecAttrSynchronizable: kSecAttrSynchronizableAny` item to the dictionary when the `synchronizable` property is true.

     - parameter items: The dictionary where the kSecAttrSynchronizable items will be added when requested.
     - parameter addingItems: Use `true` when the dictionary will be used with `SecItemAdd` method (adding a keychain item). For getting and deleting items, use `false`.

     - returns: the dictionary with kSecAttrSynchronizable item added if it was requested. Otherwise, it returns the original dictionary.

     */
    func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        if !synchronizable { return items }
        var result: [String: Any] = items
        result[KeyChainHelperConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
        return result
    }
}



/**

 These options are used to determine when a keychain item should be readable. The default value is AccessibleWhenUnlocked.

 */
public enum KeyChainHelperAccessOptions {

    /**

     The data in the keychain item can be accessed only while the device is unlocked by the user.

     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.

     This is the default value for keychain items added without explicitly setting an accessibility constant.

     */
    case accessibleWhenUnlocked

    /**

     The data in the keychain item can be accessed only while the device is unlocked by the user.

     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.

     */
    case accessibleWhenUnlockedThisDeviceOnly

    /**

     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.

     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.

     */
    case accessibleAfterFirstUnlock

    /**

     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.

     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.

     */
    case accessibleAfterFirstUnlockThisDeviceOnly

    /**

     The data in the keychain item can always be accessed regardless of whether the device is locked.

     This is not recommended for application use. Items with this attribute migrate to a new device when using encrypted backups.

     */
    case accessibleAlways

    /**

     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.

     This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.

     */
    case accessibleWhenPasscodeSetThisDeviceOnly

    /**

     The data in the keychain item can always be accessed regardless of whether the device is locked.

     This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.

     */
    case accessibleAlwaysThisDeviceOnly

    static var defaultOption: KeyChainHelperAccessOptions {
        return .accessibleWhenUnlocked
    }

    var value: String {
        switch self {
        case .accessibleWhenUnlocked:
            return toString(kSecAttrAccessibleWhenUnlocked)

        case .accessibleWhenUnlockedThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)

        case .accessibleAfterFirstUnlock:
            return toString(kSecAttrAccessibleAfterFirstUnlock)

        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

        case .accessibleAlways:
            return toString(kSecAttrAccessibleAlways)

        case .accessibleWhenPasscodeSetThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)

        case .accessibleAlwaysThisDeviceOnly:
            return toString(kSecAttrAccessibleAlwaysThisDeviceOnly)
        }
    }

    func toString(_ value: CFString) -> String {
        return KeyChainHelperConstants.toString(value)
    }
}

/// Constants used by the library
public struct KeyChainHelperConstants {
    /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
    public static var accessGroup: String { return toString(kSecAttrAccessGroup) }

    /// A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeyChainHelperAccessOptions.
    public static var accessible: String { return toString(kSecAttrAccessible) }

    /// Used for specifying a String key when setting/getting a Keychain value.
    public static var attrAccount: String { return toString(kSecAttrAccount) }

    /// Used for specifying synchronization of keychain items between devices.
    public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }

    /// An item class key used to construct a Keychain search dictionary.
    public static var secClass: String { return toString(kSecClass) }

    /// Specifies the number of values returned from the keychain. The library only supports single values.
    public static var matchLimit: String { return toString(kSecMatchLimit) }

    /// A return data type used to get the data from the Keychain.
    public static var returnData: String { return toString(kSecReturnData) }

    /// Used for specifying a value when setting a Keychain value.
    public static var valueData: String { return toString(kSecValueData) }

    static func toString(_ value: CFString) -> String {
        return value as String
    }
}

