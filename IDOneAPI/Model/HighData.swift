//
//  HighData.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/05/17.
//

import Foundation
internal class HighData: Decodable {
    let result_code: Int?
    let msg: String?
    var response :HighResponseData?
}


internal class HighResponseData: Decodable {
    let enc_data: HighENC_DATA?
    let id: String?
}

internal class HighENC_DATA:Decodable {
    let BioAuth:[HighBioAuthData]?
}

internal class HighBioAuthData:Decodable {
    let fingerPosition:String?
    let fingerValue: String?
    let faceValue: String?
    let name: String?
}
