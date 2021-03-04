//
//  Define.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/03/02.
//

import Foundation
internal struct IDOneConstants {
    
    struct Server {
     
        static let API = "https://api.idonelabs.com"
        static let API_API = API + "/api"
        static let TOKEN_ISSUANCE = API_API + "/get_access_token"       //토큰발행
        static let CHECK_ID = API_API + "/id_check"                     //아이디 중복체크
        static let UPLOAD_BLOCKCHAIN = API_API + "/upload_blockchain"   //회원가입
        static let GET_LOGIN_DATA = API_API + "/get_login_data"         //로그인전 데이터 가져오기
        static let LOGIN = API_API + "/login"                           //로그인
        static let MEDIUM_AUTH =  API_API + "/medium_auth"              //중수준 인증요청
        static let GET_MEDIUM_AUTH =  API_API + "/get_medium_auth"      //중수준 데이터 가져오기
        static let SET_MEDIUM_AUTH = API_API + "/set_medium_auth"       //중수준 인증데이터 서버전송
        static let FINISH_MEDIUM_AUTH = API_API + "/finish_medium_auth" //중수준 인증요청 결과
        static let GET_INFO = API_API + "/get_info"                     //이더리움 등록여부
        static let GET_USER_INFO = API_API + "/get_user_info"           //로그인별 데이터 가져오기
        static let USER_RESET = API_API + "/user_reset"                 //탈퇴
        
        static let AUTH_REQUEST = API_API + "/auth_request"                      //SMS인증 요청
        static let AUTH_VERIFY = API_API + "/auth_verify"        //SMS인증 확인
        static let GET_AUTHENTICATION_INFO = API_API + "/get_authentication_info" //인증별 유무 확인
        static let SET_ENC_DATA = API_API + "/set_enc_data" //xml 데이터 추가
        static let GET_MODIFY_STATUS = API_API + "/get_modify_status" //xml 데이터 수정 확인
        static let GET_LICENSE_TYPE = API_API + "/get_license_type" // DID 리스트
        static let GET_RESTORE_DATA = API_API + "/get_restore_data" //국가코드 전달(복구용)
        static let USER_RESTORE = API_API + "/user_restore" //복구 완료 / 디바이스 아이디 수정
        
    }
    
    struct File {
        static let FILE_NAME = "iDOne.xml"
        static let DIRECTORI_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        static let File_PATH = IDOneConstants.File.DIRECTORI_PATH[0].appendingFormat("/" + IDOneConstants.File.FILE_NAME)
    }
    
}
