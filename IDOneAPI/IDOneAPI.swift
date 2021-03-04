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
    
    private func post(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ios.idone.ai", forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
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
    
    func dateString(date: Foundation.Date) -> String {
        
       
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        df.timeZone = TimeZone.current
        
        return df.string(from: date)
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
    func register_Member(completionHandler: @escaping(Result<IDOneResult, Error>) -> Void ) {
        //가입할대 필요한거
        //xml 파일저장 후 불러오는 과정이 필요함.
        let xmlUrl = URL(fileURLWithPath: IDOneConstants.Server.TOKEN_ISSUANCE)
        var xmlData = Data()
        do {
            xmlData = try Data(contentsOf: xmlUrl)
        }catch{
            print("error : \(error)")
        }
        
        let request = URLRequest(multipartFormData: { (formData) in
                                                      //2. Example with Data of a file
                                                          formData.append(file: xmlData, name: "xml", fileName: "iDOne.xml", mimeType: "application/xml")
                                                      //3. Example of key/value pair
                                                          formData.append(value: "John Doe", name: "fullName")
                                                    },
                                 url: URL(string: IDOneConstants.Server.TOKEN_ISSUANCE)!,
                                 method: .post,
                                 headers: [:])
        
        let bodyData:NSMutableDictionary = [
            "login_id": userId,
            "device_id" : get_DeviceId(),
            "token": token,
            "push": ""
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
    
}
