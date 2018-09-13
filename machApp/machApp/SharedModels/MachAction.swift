//
//  MachAction.swift
//  machApp
//
//  Created by lukas burns on 8/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

//
//  MachMessage.swift
//  machApp
//
//  Created by lukas burns on 8/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Unbox
import SwiftyJSON

enum Command: String {
    case logout = "logout"
}

public struct MachAction: MachParameterProtocol {
    var command: Command?
    var params: [MachParameter] = []
}

extension MachAction: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.command = Command(rawValue: try unboxer.unbox(key: Constants.MachAction.command))
        self.params = try unboxer.unbox(key: Constants.MachAction.params)
    }

    public static func create(from dictionary: JSON) throws -> MachAction {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: MachAction = try unbox(dictionary: dictionaryObject)
        return response
    }
}
