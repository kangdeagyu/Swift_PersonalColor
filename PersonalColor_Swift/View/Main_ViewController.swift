//
//  ViewController.swift
//  PersonalColor_Swift
//
//  Created by 이종욱 on 2023/09/19.
//

import UIKit
import KakaoSDKUser
class Main_ViewController: UIViewController {
    
    
    // MARK: - 전역변수
    // 버튼 상태관리
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    
    var loginStatus : Bool = false
    var registerStatus : Bool = false
    var kakaoStatus : Bool = false
    var naverStatus : Bool = false
    //--------------------------------
    // 텍스트필드 상태관리
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPW: UITextField!
    var idStatus : Bool = false
    var pwStatus : Bool = false
    
    // 버튼상태관리
    @IBOutlet weak var btnOtherBtn: UIButton!
    @IBOutlet weak var btnLogin2: UIButton!
    var logBtn : Bool = false
    var otherBtn : Bool = false
    //-----------------------------------
    // 로그인성공여부 가져오기
    var successLogin : [LoginUser] = []
    var okfail : Bool = false

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 초기 화면켜질 때, 텍스트필드와 버튼들 가려지기
        tfID.isHidden = true
        tfPW.isHidden = true
        btnLogin2.isHidden = true
        btnOtherBtn.isHidden = true
        
        
        // 키보드 올림 내림함수
        setKeyBoadEvent()
        
//        // SQLite DB  앱 켜질 시 DB생성
//        let database_Handler = DataBase_Handler_Wook()
//        database_Handler.createDB()
        

    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // shared preferences id 제거하기
        UserDefaults.standard.removeObject(forKey: "id")
        // 텍스트필드 초기화
        tfID.text = ""
        tfPW.text = ""
    }
    
    
    // MARK: - Buttons function
    
    // 카카오 로그인 버튼
    @IBAction func btn_kakao(_ sender: UIButton) {
        
        UserApi.shared.loginWithKakaoAccount(prompts:[.Login]) {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                _ = oauthToken
                // 로그인성공시 이메일,닉네임,토큰가져오기
                UserApi.shared.me { [self] user, error in
                    if let error = error {
                        print(error)
                    } else {
                        // 이메일, 토큰, 닉네임 제대로 들어오는지 확인
                        guard let token = oauthToken?.accessToken,
                              let email = user?.kakaoAccount?.email,
                              let name = user?.kakaoAccount?.profile?.nickname else{
                            print("token/email/name is nil")
                            return
                        }
                        // 이메일, 토큰, 닉네임확인하기
                        print("-----------------------------------",email)
                        print(token)
                        print(name)
                        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "TabBarView")
                        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                        self.present(vcName!, animated: true, completion: nil)
                        // 일단 메인으로 가자...
                        // 세그이동시 오류 (화면뜨기전에 전환오류)
                        //self.performSegue(withIdentifier: "gogoMain", sender: self)
                        // present로 다음화면 띄우기 identifier : "abc" = 다음 탭바컨트롤러 이름
                        //                            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "abc") else {return}
                        //                            self.present(nextVC, animated: true)
                        //서버에 이메일/토큰/이름 보내주기
                    }
                }
            }
        }
    }
    
    // 다른 방법으로 로그인 버튼
    @IBAction func otherBTNs(_ sender: UIButton) {
        btnChange()
    }
    
    
    // 네이버 로그인 버튼
    @IBAction func btnNaver(_ sender: UIButton) {
        // 메인페이지로 넘어가기
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "TabBarView")
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    
    
    // 로그인 버튼 -> 텍스트필드 뜨기
    @IBAction func btnLogin(_ sender: UIButton) {
        btnChange()
        
    }
    
    // 회원가입버튼 Segue로 대신함
    @IBAction func btnRegister(_ sender: Any) {
    }
    
    // 로그인 로직 버튼
    @IBAction func btnLog(_ sender: UIButton) {
        //var loginOkFail =
        _ = loginCheck()
    }
    
    
    // MARK: - functions
    
    // 로그인 버튼 클릭 시 , 버튼 사라지고 ID, PW 입력 text field 생성
    func btnChange() {
        //
        loginButton.isHidden = !loginStatus
        loginStatus = !loginStatus
        
        registerButton.isHidden = !registerStatus
        registerStatus = !registerStatus
        
        kakaoButton.isHidden = !kakaoStatus
        kakaoStatus = !kakaoStatus
        
        naverButton.isHidden = !naverStatus
        naverStatus = !naverStatus
        
        //
        
        
        tfID.isHidden = idStatus
        tfPW.isHidden = idStatus
        btnLogin2.isHidden = logBtn
        btnOtherBtn.isHidden = otherBtn
        
        
        idStatus = !idStatus
        pwStatus = !pwStatus
        logBtn = !logBtn
        otherBtn = !otherBtn
        
    }
    
    // 로그인체크
    func loginCheck()->Bool{
        successLogin.removeAll()
        let login = LoginCheck()
        // extension 과 protocol이 연결
        login.delegate = self
        login.downloadItems(id: (tfID.text?.trimmingCharacters(in: .whitespaces))!, pw: (tfPW.text?.trimmingCharacters(in: .whitespaces))!)
        return okfail
    }
    
 
    
    // MARK: - keyboard controll
    // 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // viewDidLoad에 setKeyBoadEvent 함수 실행
    func setKeyBoadEvent(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil  )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisAppear(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil  )
    }
    // 화면 올리기
    @objc func keyboardWillAppear(_ sender : NotificationCenter){
        // 메모리에 상주하면서 관찰하는 observer
        
        
        // 화면의 y값을 0 에서 -250 으로 바꾸기
        self.view.frame.origin.y = -250
    }
    // 화면 내리기
    @objc func keyboardWillDisAppear(_ sender : NotificationCenter){
        // 메모리에 상주하면서 관찰하는 observer
        
        
        // 화면의 y값을 0으로 바꾸기
        self.view.frame.origin.y = 0
    }
    
    
}//Main_ViewController
// MARK: - extension

extension Main_ViewController : LoginModelProtocol{
    func itemDownloaded(items : [LoginUser]) {
        self.successLogin = items
        // 회원탈퇴여부 판단하지않고 로그인체크할시
        // 로그인 성공가능여부 값 받아와서 공백 제거 후, bool값에 넣어주기  회원탈퇴여부 판단하지않고 로그인체크할시
//        if let firstRS = successLogin.first?.rs {
//            let trimmedRS = firstRS.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//            print("trimmed rs: \(trimmedRS)")
//
//            if trimmedRS == "OK" {
//                okfail = true
//                print("okfail: \(okfail)")
//            } else {
//                okfail = false
//                print("okfail: \(okfail)")
//            }
//        } else {
//            // successLogin 배열이 비어 있는 경우 또는 첫 번째 요소가 없는 경우 처리
//            okfail = false
//            print("okfail: \(okfail)")
//        }
        
        // 회원탈퇴여부와 로그인가능여부 판단
        if (successLogin[0].rs == 1 && successLogin[0].ustatus == 0){
            okfail = true
        }else{
            okfail = false
        }
        
        
        if okfail{
            // 메인페이지로 넘어가기
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "TabBarView")
            vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(vcName!, animated: true, completion: nil)
            if let text = tfID.text?.trimmingCharacters(in: .whitespaces) {
                UserDefaults.standard.set(text, forKey: "id")
                print("input")
            } else {
                // 텍스트가 nil 또는 공백 문자로 구성되어 있을 경우에 대한 처리
                UserDefaults.standard.removeObject(forKey: "id")
                print("fail")
            }
        }else{
            print("로그인실패")
            if successLogin[0].ustatus == 1{
                let resultAlert = UIAlertController(title: "ERROR", message: "탈퇴된 회원입니다.", preferredStyle: .actionSheet)
                
                let onAction = UIAlertAction(title: "OK", style: .cancel)
                resultAlert.addAction(onAction)
                
                present(resultAlert, animated: true)
            }

        }
        
        
    }
    
    
}

