//
//  BartlebysDynamicDeserializer.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation

// We only use this dynamic deserializer when dynamism is absolutely required
// For example:
//  - to handle trigger from Server Sent Event (to deserialize the payload)
//  - to deal with operation provisionning
// Everywhere else we use the standard Serializer !
// We currently support Managed And UnmanagedModel
// Remember that the DynamciDeserializers are generated by Flexions.
// Usage sample :
// ` if let deserializedTimedText = try d.deserialize(className: TimedText.typeName(), data: data, document: nil) as? TimedText{
//      ...
// }`
open class BartlebysDynamicDeserializer:DynamicDeserializer{

    public init(){
        
    }

    /// Deserializes dynamically an entity based on its Class name.
    ///
    /// - Parameters:
    ///   - className: the className
    ///   - data: the encoded data
    ///   - document: the document to register In the instance (if set to nil the instance will not be registred
    /// - Returns: the dynamic instance that you cast..?
    open func deserialize(className:String,data:Data,document:BartlebyDocument?)throws->Any{

        var instance : Decodable!

        if let document = document{
            defer{
                if let managedModel = instance as? ManagedModel{
                    if (managedModel is BartlebyCollection) || (managedModel is BartlebyOperation){
                        // Add the document reference
                        managedModel.referentDocument=document
                    }else{
                        // Add the collection reference
                        // Calls the Bartleby.register(self)
                        managedModel.collection=document.collectionByName(managedModel.d_collectionName)
                    }
                }
            }
        }
        if className == "Acknowledgment"{ instance = try JSON.decoder.decode(Acknowledgment.self, from: data); return instance }
        if className == "Block"{ instance = try JSON.decoder.decode(Block.self, from: data); return instance }
        if className == "Box"{ instance = try JSON.decoder.decode(Box.self, from: data); return instance }
        if className == "CollectionMetadatum"{ instance = try JSON.decoder.decode(CollectionMetadatum.self, from: data); return instance }
        if className == "Completion"{ instance = try JSON.decoder.decode(Completion.self, from: data); return instance }
        if className == "Container"{ instance = try JSON.decoder.decode(Container.self, from: data); return instance }
        if className == "DataValue"{ instance = try JSON.decoder.decode(DataValue.self, from: data); return instance }
        if className == "DocumentMetadata"{ instance = try JSON.decoder.decode(DocumentMetadata.self, from: data); return instance }
        if className == "HTTPContext"{ instance = try JSON.decoder.decode(HTTPContext.self, from: data); return instance }
        if className == "HTTPRequest"{ instance = try JSON.decoder.decode(HTTPRequest.self, from: data); return instance }
        if className == "KeyedChanges"{ instance = try JSON.decoder.decode(KeyedChanges.self, from: data); return instance }
        if className == "KeyedData"{ instance = try JSON.decoder.decode(KeyedData.self, from: data); return instance }
        if className == "Locker"{ instance = try JSON.decoder.decode(Locker.self, from: data); return instance }
        if className == "LogEntry"{ instance = try JSON.decoder.decode(LogEntry.self, from: data); return instance }
        if className == "ManagedModel"{ instance = try JSON.decoder.decode(ManagedModel.self, from: data); return instance }
        if className == "Metrics"{ instance = try JSON.decoder.decode(Metrics.self, from: data); return instance }
        if className == "Node"{ instance = try JSON.decoder.decode(Node.self, from: data); return instance }
        if className == "Progression"{ instance = try JSON.decoder.decode(Progression.self, from: data); return instance }
        if className == "PushOperation"{ instance = try JSON.decoder.decode(PushOperation.self, from: data); return instance }
        if className == "Report"{ instance = try JSON.decoder.decode(Report.self, from: data); return instance }
        if className == "StringValue"{ instance = try JSON.decoder.decode(StringValue.self, from: data); return instance }
        if className == "Tag"{ instance = try JSON.decoder.decode(Tag.self, from: data); return instance }
        if className == "Trigger"{ instance = try JSON.decoder.decode(Trigger.self, from: data); return instance }
        if className == "User"{ instance = try JSON.decoder.decode(User.self, from: data); return instance }
        if className == "ReadBlockById"{ instance = try JSON.decoder.decode(ReadBlockById.self, from: data); return instance }
        if className == "CreateBlock"{ instance = try JSON.decoder.decode(CreateBlock.self, from: data); return instance }
        if className == "UpdateBlock"{ instance = try JSON.decoder.decode(UpdateBlock.self, from: data); return instance }
        if className == "DeleteBlock"{ instance = try JSON.decoder.decode(DeleteBlock.self, from: data); return instance }
        if className == "CreateBlocks"{ instance = try JSON.decoder.decode(CreateBlocks.self, from: data); return instance }
        if className == "ReadBlocksByIds"{ instance = try JSON.decoder.decode(ReadBlocksByIds.self, from: data); return instance }
        if className == "UpdateBlocks"{ instance = try JSON.decoder.decode(UpdateBlocks.self, from: data); return instance }
        if className == "DeleteBlocks"{ instance = try JSON.decoder.decode(DeleteBlocks.self, from: data); return instance }
        if className == "ReadBlocksByQuery"{ instance = try JSON.decoder.decode(ReadBlocksByQuery.self, from: data); return instance }
        if className == "ReadBoxById"{ instance = try JSON.decoder.decode(ReadBoxById.self, from: data); return instance }
        if className == "CreateBox"{ instance = try JSON.decoder.decode(CreateBox.self, from: data); return instance }
        if className == "UpdateBox"{ instance = try JSON.decoder.decode(UpdateBox.self, from: data); return instance }
        if className == "DeleteBox"{ instance = try JSON.decoder.decode(DeleteBox.self, from: data); return instance }
        if className == "CreateBoxes"{ instance = try JSON.decoder.decode(CreateBoxes.self, from: data); return instance }
        if className == "ReadBoxesByIds"{ instance = try JSON.decoder.decode(ReadBoxesByIds.self, from: data); return instance }
        if className == "UpdateBoxes"{ instance = try JSON.decoder.decode(UpdateBoxes.self, from: data); return instance }
        if className == "DeleteBoxes"{ instance = try JSON.decoder.decode(DeleteBoxes.self, from: data); return instance }
        if className == "ReadBoxesByQuery"{ instance = try JSON.decoder.decode(ReadBoxesByQuery.self, from: data); return instance }
        if className == "ReadLockerById"{ instance = try JSON.decoder.decode(ReadLockerById.self, from: data); return instance }
        if className == "CreateLocker"{ instance = try JSON.decoder.decode(CreateLocker.self, from: data); return instance }
        if className == "UpdateLocker"{ instance = try JSON.decoder.decode(UpdateLocker.self, from: data); return instance }
        if className == "DeleteLocker"{ instance = try JSON.decoder.decode(DeleteLocker.self, from: data); return instance }
        if className == "CreateLockers"{ instance = try JSON.decoder.decode(CreateLockers.self, from: data); return instance }
        if className == "ReadLockersByIds"{ instance = try JSON.decoder.decode(ReadLockersByIds.self, from: data); return instance }
        if className == "UpdateLockers"{ instance = try JSON.decoder.decode(UpdateLockers.self, from: data); return instance }
        if className == "DeleteLockers"{ instance = try JSON.decoder.decode(DeleteLockers.self, from: data); return instance }
        if className == "ReadLockersByQuery"{ instance = try JSON.decoder.decode(ReadLockersByQuery.self, from: data); return instance }
        if className == "ReadNodeById"{ instance = try JSON.decoder.decode(ReadNodeById.self, from: data); return instance }
        if className == "CreateNode"{ instance = try JSON.decoder.decode(CreateNode.self, from: data); return instance }
        if className == "UpdateNode"{ instance = try JSON.decoder.decode(UpdateNode.self, from: data); return instance }
        if className == "DeleteNode"{ instance = try JSON.decoder.decode(DeleteNode.self, from: data); return instance }
        if className == "CreateNodes"{ instance = try JSON.decoder.decode(CreateNodes.self, from: data); return instance }
        if className == "ReadNodesByIds"{ instance = try JSON.decoder.decode(ReadNodesByIds.self, from: data); return instance }
        if className == "UpdateNodes"{ instance = try JSON.decoder.decode(UpdateNodes.self, from: data); return instance }
        if className == "DeleteNodes"{ instance = try JSON.decoder.decode(DeleteNodes.self, from: data); return instance }
        if className == "ReadNodesByQuery"{ instance = try JSON.decoder.decode(ReadNodesByQuery.self, from: data); return instance }
        if className == "ReadTagById"{ instance = try JSON.decoder.decode(ReadTagById.self, from: data); return instance }
        if className == "CreateTag"{ instance = try JSON.decoder.decode(CreateTag.self, from: data); return instance }
        if className == "UpdateTag"{ instance = try JSON.decoder.decode(UpdateTag.self, from: data); return instance }
        if className == "DeleteTag"{ instance = try JSON.decoder.decode(DeleteTag.self, from: data); return instance }
        if className == "CreateTags"{ instance = try JSON.decoder.decode(CreateTags.self, from: data); return instance }
        if className == "ReadTagsByIds"{ instance = try JSON.decoder.decode(ReadTagsByIds.self, from: data); return instance }
        if className == "UpdateTags"{ instance = try JSON.decoder.decode(UpdateTags.self, from: data); return instance }
        if className == "DeleteTags"{ instance = try JSON.decoder.decode(DeleteTags.self, from: data); return instance }
        if className == "ReadTagsByQuery"{ instance = try JSON.decoder.decode(ReadTagsByQuery.self, from: data); return instance }
        if className == "ReadUserById"{ instance = try JSON.decoder.decode(ReadUserById.self, from: data); return instance }
        if className == "CreateUser"{ instance = try JSON.decoder.decode(CreateUser.self, from: data); return instance }
        if className == "UpdateUser"{ instance = try JSON.decoder.decode(UpdateUser.self, from: data); return instance }
        if className == "DeleteUser"{ instance = try JSON.decoder.decode(DeleteUser.self, from: data); return instance }
        if className == "CreateUsers"{ instance = try JSON.decoder.decode(CreateUsers.self, from: data); return instance }
        if className == "ReadUsersByIds"{ instance = try JSON.decoder.decode(ReadUsersByIds.self, from: data); return instance }
        if className == "UpdateUsers"{ instance = try JSON.decoder.decode(UpdateUsers.self, from: data); return instance }
        if className == "DeleteUsers"{ instance = try JSON.decoder.decode(DeleteUsers.self, from: data); return instance }
        if className == "ReadUsersByQuery"{ instance = try JSON.decoder.decode(ReadUsersByQuery.self, from: data); return instance }
        throw DynamicDeserializerError.classNotFound
    }
}