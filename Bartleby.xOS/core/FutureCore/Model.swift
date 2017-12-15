//
//  Model.swift
//  BartlebyCore
//
//  Created by Benoit Pereira da silva on 08/12/2017.
//  Copyright © 2017 MusicWork. All rights reserved.
//

import Foundation
open  class Model:Object,Codable{


    // MARK: - Initializable

    required public override init() {
        super.init()
    }

    // MARK: - Codable

    public enum ModelCodingKeys: String,CodingKey{
        case id
    }


    public required init(from decoder: Decoder) throws{
        super.init()
    }

    open func encode(to encoder: Encoder) throws {
    }



}

