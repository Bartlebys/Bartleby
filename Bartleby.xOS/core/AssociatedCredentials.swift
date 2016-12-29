//
//  AssociatedCredentials.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import Locksmith
#endif


public struct AssociatedCredentials:Mappable {

    var email:String=""
    var phone:String=""
    var password:String=""

    var associations:[AssociatedIdentification]=[AssociatedIdentification]()

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        self.email <- ( map["email"] )
        self.phone <- ( map["phone"] )
        self.password <- ( map["password"] )
        self.associations <- ( map["associations"] )
    }

    func saveData()throws->(){
        let json=self.toJSONString()!
        try Locksmith.saveData(data: ["data":json], forUserAccount:"bartleby")
    }

    mutating func loadData() {
        if let data=Locksmith.loadDataForUserAccount(userAccount: "bartleby"){
            if let json=data["data"] as? [String:Any]{
                let map=Map(mappingType: MappingType.fromJSON, JSON: json)
                self.mapping(map: map)
            }
        }
    }


}

