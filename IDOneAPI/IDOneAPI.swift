//
//  IDOneAPI.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/03/02.
//

import Foundation


open class IDOneAPI {
    
    static let shared: IDOneAPI = IDOneAPI()
    
    private let session: URLSession = URLSession.shared
    
    //일반적으로 사용하는 post Function
    private func post(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios.idone.ai", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    //회원가입에 사용되는 Upload Function
    private func upload(url: URL, body: [String:String], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        //가입할대 필요한거
        //xml 파일저장 후 불러오는 과정이 필요함.
        let xmlUrl = URL(fileURLWithPath: IDOneConstants.File.File_PATH)
        var xmlData = Data()
        
        do {
            xmlData = try Data(contentsOf: xmlUrl)
        }catch{
            print("error : \(error)")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios.idone.ai", forHTTPHeaderField: "User-Agent")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        
        for (key, value) in body {
          httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        httpBody.append(convertFileData(fieldName: "xml",
                                        fileName: "iDOne.xml",
                                        mimeType: "application/xml",
                                        fileData: xmlData,
                                        using: boundary))

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data

//        print(String(data: httpBody as Data, encoding: .utf8)!)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    
    }
    
    
    //MARK:- 디바이스 아이디 발급
    func get_DeviceId() -> String{
        if IDOneKeychain.load("device_id") == nil {
    
            var randomStr = ""
            
            for _ in 0..<18 {
                
                randomStr += String(arc4random() % 10)
            }
            
            let deviceID = "iDOne-\(randomStr)-\(dateString(date: Foundation.Date()))"
            
            _ = IDOneKeychain.save("device_id", data: deviceID.data(using: .utf8)!)
            
            return deviceID
            
        }else{
            
            let strData = IDOneKeychain.load("device_id") ?? Data()
            let deviceId = String(data: strData, encoding: .utf8) ?? "DeviceID NOT ISSUED"
            
            return deviceId
            
        }
    }
    
    
    
    //MARK:- 토큰발행
    func token_Issuance(completionHandler: @escaping(Result<IDOneToken, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = ["device_id" : get_DeviceId()]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.TOKEN_ISSUANCE)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneToken.self, from: data!)
                    completionHandler(.success(result))
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }

    }
    
    //MARK:- 아이디 중복검사
    func check_ID(userId: String, token: String, country_code: String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id": userId,
            "device_id" : get_DeviceId(),
            "token": token,
            "country_code":country_code
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.TOKEN_ISSUANCE)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
        
        
    }
    
    //MARK:- 회원가입
    func register_Member(userId:String, token:String, apnsId:String, countryCode:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:[String: String] = [
            "device_id":get_DeviceId(),
            "login_id":userId,
            "token":token,
            "push":apnsId,
            "country_code":countryCode,
            
        ]
        
        do {
            
            try upload(url: URL(string: IDOneConstants.Server.UPLOAD_BLOCKCHAIN)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 이더리움 상태 확인
    func get_Info(completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id" : get_DeviceId()
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_INFO)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 로그인
    func login(userId:String, token:String, apnsId:String, countryCode:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
            "push": apnsId,
            "country_code": countryCode,
            "token": token
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.LOGIN)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- xml 이메일 데이터 추가
    func setEmail(userId:String, email:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
            "enc_data": [
                "authType": "Email",
                "email": email
            ]
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.SET_ENC_DATA)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- xml 핸드폰번호 데이터 추가
    func setPhone(userId:String, phone:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
            "enc_data": [
                "authType": "Phone",
                "phoneNumber": phone
            ]
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.SET_ENC_DATA)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- xml 신분증 데이터 추가
    func setIDCard(idCard: [String:String], userId:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        var getIdCard:[String:String] = idCard
        var licenseType = ""
        
        if getIdCard["type"] == "National ID Card" {
            licenseType = "National ID Card"
        }else if getIdCard["type"] == "Driver License"{
            licenseType = "Driver License"
        }else if getIdCard["type"] == "PASSPORT"{
            licenseType = "PASSPORT"
        }else if getIdCard["type"] == "Driver License (US)"{
            licenseType = "Driver License (US)"
        }
        
        getIdCard.removeValue(forKey: "type")
        
        var data:[String:String] = ["key":"","value":""]
        var appendData:[[String:String]] = []
        for (key, value) in getIdCard {
            data.updateValue(key, forKey: "key")
            data.updateValue(value, forKey: "value")
            appendData.append(data)
        }
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
            "enc_data": [
                "authType": "IdCard",
                "licenseType":licenseType,
                "licenseTypeInfos":appendData,
                "phoneNumber": "null",
                "email": "null"
            ]
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.SET_ENC_DATA)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- xml 데이터 수정 확인 (이더리움 스테이터스)
    func get_modify_status(userId:String, phone:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_MODIFY_STATUS)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 초기화
    func user_reset(userId:String, phone:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": userId,
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.USER_RESET)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- DID LIST
    func did_list(userId:String, phone:String, completionHandler: @escaping(Result<IDOneDID, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id": userId,
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_LICENSE_TYPE)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneDID.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- SMS, Email 인증 요청
    func auth_request(type:AuthRequestEnum, input:String, countryCode:String, completionHandler: @escaping(Result<IDOneAuth, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "info" : input,
            "type" : type.rawValue,
            "country_code" : countryCode
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.AUTH_REQUEST)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneAuth.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- SMS, Email 인증 결과
    func auth_verify(type:AuthRequestEnum, cipertext:String, code:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "cipertext" : cipertext,
            "code" : code,
            "type" : type.rawValue
        ]
        
        do {
            
            try post(url: URL(string: IDOneConstants.Server.AUTH_VERIFY)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 복구용 암호화 데이터 전달
    func get_restore_data(loginId: String, countryCode:String, completionHandler: @escaping(Result<IDOneRestore, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id" : loginId,
            "country_code" : countryCode,
            "tag" : "BioAuth"
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_RESTORE_DATA)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneRestore.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 복구 완료 / 디바이스 아이디 수정
    func user_restore(loginId: String, deviceId:String, token:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id" : loginId,
            "device_id" : deviceId,
            "token" : token
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.USER_RESTORE)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 인증별 유무 확인
    func get_authentication_info(loginId: String, deviceId:String, token:String, completionHandler: @escaping(Result<IDOneAuthType, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id" : loginId
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_AUTHENTICATION_INFO)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneAuthType.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 유저 정보 가져오기
    func get_user_info(loginId: String, tag:UserInfoEnum, token:String, completionHandler: @escaping(Result<IDOneUserInfo, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": loginId,
            "token": token,
            "tag": tag.rawValue
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_USER_INFO)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneUserInfo.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 유저 정보 가져오기(Type선택)
    func get_user_info(loginId: String, tag:UserInfoEnum, type:String, token:String, completionHandler: @escaping(Result<IDOneUserInfo, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "device_id": get_DeviceId(),
            "login_id": loginId,
            "token": token,
            "tag": tag.rawValue,
            "type":type
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_USER_INFO)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneUserInfo.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 중수준 인증 데이터 가져오기
    func get_medium_auth(loginId: String, token:String, completionHandler: @escaping(Result<MediumData, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id": loginId,
            "token": token
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_MEDIUM_AUTH)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(MediumData.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 고수준 인증 데이터 가져오기
    func get_high_auth(loginId: String, token:String, completionHandler: @escaping(Result<HighData, Error>) -> Void ) {
        
        let bodyData:NSMutableDictionary = [
            "login_id": loginId,
            "token": token
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.GET_MEDIUM_AUTH)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(HighData.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
    
    //MARK:- 중∙고수준 인증 서버전송
    func set_auth(loginId: String, token:String, responseId:String, completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        
        let now = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let signTimeStr = dateformatter.string(from: now)
        
        let bodyData:NSMutableDictionary = [
            "login_id": loginId,
            "token": token,
            "response_id": responseId,
            "data":[
                "data1":signTimeStr
            ]
        ]

        do {
            
            try post(url: URL(string: IDOneConstants.Server.SET_MEDIUM_AUTH)!, body: bodyData, completionHandler: {
                data, response, error in

                do{
                    let result = try JSONDecoder().decode(IDOneResult.self, from: data!)
                    
                    completionHandler(.success(result))
                    
                    
                }catch(let error){
                    completionHandler(.failure(error))
                }

            })
        }catch(let error){
            completionHandler(.failure(error))
        }
    }
}

//추가적으로 사용하는 함수들.
extension IDOneAPI {
    
    //DeviceId 발급에 필요한 날짜를 추출할때에 사용하는 formatter
    private func dateString(date: Foundation.Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        df.timeZone = TimeZone.current
        
        return df.string(from: date)
    }
    
    //upload 에 사용되는 Function(1)
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    //upload 에 사용되는 Function(2)
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}

//upload 에 사용되는 Function(3)
extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
