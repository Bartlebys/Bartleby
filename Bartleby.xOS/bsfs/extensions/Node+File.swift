//
//  Node+File.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/11/2016.
//
//

import Foundation


enum NodeExtractionError:Error{
    case message(_:String)
}


public extension Node{


    /// Extracts the information from a file at a given path.
    ///
    /// - Parameters:
    ///   - relativePath: the relative path
    ///   - folderPath: the box or referent folder path
    public func extractInformationsFromFile(at relativePath:String,within folderPath:String)throws->(){
        let fm=FileManager.default
        let p=folderPath+relativePath
        if fm.fileExists(atPath:p){
            self.relativePath=relativePath
            let attributes:[FileAttributeKey : Any]=try fm.attributesOfItem(atPath: p)
            if let size=attributes[FileAttributeKey.size] as? Int{
                self.size=size
            }
            if let type=attributes[FileAttributeKey.type] as? FileAttributeType{
                if type==FileAttributeType.typeRegular{
                    self.nature = .file
                }
                if type==FileAttributeType.typeSymbolicLink{
                    self.nature = .alias
                    self.proxyPath = try? self._resolveAlias(at: p)
                }
                if type==FileAttributeType.typeDirectory{
                    self.nature = .folder
                }
            }
            if let creationDate=attributes[FileAttributeKey.creationDate] as? Date{
                self.creationDate=creationDate
            }
            if let modificationDate=attributes[FileAttributeKey.modificationDate] as? Date{
                self.modificationDate=modificationDate
            }
        }else{
            throw NodeExtractionError.message("Unexisting file at: \(p)")
        }
    }


    func _resolveAlias(at path:String) throws -> String {
        let pathURL=URL(fileURLWithPath: path)
        let original = try URL(resolvingAliasFileAt: pathURL, options:[])
        return original.path
    }

}
