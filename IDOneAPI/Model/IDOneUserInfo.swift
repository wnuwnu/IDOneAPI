//
//  IDOneUserInfo.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/05/17.
//

import Foundation

internal class IDOneUserInfo:IDOneResult{
    //response
    let response:UserInfoResponse? = nil
}
// BioAuth, IdCard, UserInfo, UserID
internal class UserInfoResponse:Decodable{
    var UserID: String? = nil
    var BioAuth:[UserInfoBioAuth]? = nil
    var IdCard:[UserInfoIdCard]? = nil
    var UserInfo:UserInfoData? = nil
}

//UserInfo
internal class UserInfoData:Decodable{
    let userName: String?
    let userBirth: String?
    let userSex: String?
    let phoneNumber: String?
    let countryCode: String?
    let signTime: String?
    let email: String?
}

//BioAuth
internal class UserInfoBioAuth:Decodable{
    let name: String?
    let fingerPosition: String?
    let fingerValue: String?
    let faceValue: String?
}

//IdCard
internal class UserInfoIdCard:Decodable{
    let type: String?
    
    let rRnNumber: String?
    let name: String?
    let issuer: String?
    let image: String?
    let dLnNumber: String?
    let birth: String?
    let sex: String?
    
    let documentType: String?
    let documentSubType: String?
    let countryCode: String?
    let lastName: String?
    let firstName: String?
    let passportNumber: String?
    let nationality: String?
    let dateOfBirth: String?
    
    let expirationDate: String?
    let personalNumber: String?

    let number: String?
    let birth_date: String?
    let expiry_date: String?
    let last_name: String?
    let first_name: String?
    let gender: String?

}
