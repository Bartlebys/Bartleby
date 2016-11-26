//
//  UniversalType.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/05/2016.
//
//

/*

 Bartleby 1.0 Universal type approach relies on Classes with @objc("Classname") prefix.
 Class name are constant but can not be flexed for generic context.
 NSClassFromString(ClassName) is constant in any target.
 Multiple Apps can interchange and consume Bartleby's Dynamic / Distributed Object

 E.g `class MyClass<T:AnyProtocol> ` is not possible to keep the support of NSSecureCoding

 */
public protocol UniversalType {

    // The class or struct universal name is used to serialize the instance
    static func typeName() -> String

    // The run time type name used to deserialize an instance
    func runTimeTypeName() -> String


}
