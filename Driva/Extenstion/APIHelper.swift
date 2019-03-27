



import UIKit
import Alamofire


class APIHelper: NSObject {
    static let shared = APIHelper()
    private override init() { }
    
    private let headers = [
        "Content-Type" : "application/x-www-form-urlencoded",
        "OuthKey" : "authorization"
    ]
    typealias ComletionBlock = (AnyObject?) -> Void
    func callAPIPost(_ parameter:[String:Any], sUrl:String, completion:@escaping ComletionBlock) -> Void {
        Alamofire.request(sUrl, method: .post, parameters: parameter, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {(response) in
                completion(response.result.value as AnyObject)
        })
    }
    typealias ComletionRawBlock = (AnyObject?) -> Void
    func callAPIRawPost(_ parameter:[String:Any], sUrl:String, completion:@escaping ComletionRawBlock) -> Void {
        Alamofire.request(sUrl, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) in
            completion(response.result.value as AnyObject)
        })
    }
    typealias CompletionGetBlock = (AnyObject) -> Void
    func callAPIGet(_ url:String!, completion:@escaping CompletionGetBlock) -> Void {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            completion(response.result.value as AnyObject)
        }
    }
    typealias CompletionDeleteBlock = (AnyObject?) -> Void
    func callAPIDelete(_ parameter:[String:Any], sUrl:String, completion:@escaping CompletionDeleteBlock) -> Void {
        Alamofire.request(sUrl, method: .delete, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            completion(response.result.value as AnyObject)
        }
    }
    typealias CompletionUploadBlock = (AnyObject?) -> Void
    func callAPIForUpload(_ parameters:[String:Any], sUrl:String, imgData:Data, imageKey:String, completion:@escaping CompletionUploadBlock) -> Void {
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: imageKey,fileName: "profileImage.png", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        },usingThreshold: UInt64.init(), to: sUrl, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //                    print(response.result.value!)
                    completion(response.result.value as AnyObject)
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }

}
