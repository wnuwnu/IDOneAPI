//
//  IDOneResult.swift
//  IDOneAPI
//
//  Created by iDOne-iOS on 2021/03/02.
//

import Foundation
internal class IDOneResult:Decodable{
    //사용하는넘들
    //아이디 중복검사
    //회원가입
    //이더리움 상태 확인
    //로그인
    //xml 데이터 수정 확인
    //sms, email 인증 결과
    //복구완료
    //수정확인
    let result_code: Int?
    let msg: String?
}


