//
//  IDOneBioAuth.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/05/10.
//

import Foundation

internal class IDOneBioAuth:IDOneResult {
    let response:response? = nil
}

internal class response:Decodable{
    var bioAuth:[BioAuth]? = nil
}

internal class BioAuth:Decodable{
    let name: String?
    let fingerPosition: String?
    let fingerValue: String?
    let faceValue: String?
}
