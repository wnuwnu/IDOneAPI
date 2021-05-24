//
//  MediumData.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/05/17.
//

import Foundation

internal class MediumData: Decodable{
    let result_code: Int?
    let msg: String?
    var response :MediumResponseData?
}

internal class MediumResponseData: Decodable {
    let enc_data: String?
    let id: String?
}

