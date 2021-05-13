//
//  IDOneAuthType.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/05/12.
//

import Foundation
internal class IDOneAuthType:IDOneResult {
    let response:typeResponse? = nil
}
internal class typeResponse:Decodable{
    var id_card:String? = nil
    var email_auth:String? = nil
    var phone_auth:String? = nil
    var finger_auth:String? = nil
    var face_auth:String? = nil
}
