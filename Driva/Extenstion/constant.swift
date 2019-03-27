//
//  constant.swift
//  truckConvc
//
//  Created by mediatrenz on 03/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import Foundation
import UIKit

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

//let kServer : String = "http://demo11.mediatrenz.com/"
//let KServerPath : String = "driva/Api/"

let kServer : String = "https://drivaonline.com/"
let KServerPath : String = "App_Api/v1/"

//////Login Process
let K_Login : String = "user_login.php?"
let K_Rigister : String = "register.php?"
let K_Forget  : String  =  "forgot_pass.php?"

struct NearLoginUrlStruct {
    var URL_LOGIN = kServer + KServerPath +  K_Login
    var URL_RIGISTER = kServer + KServerPath + K_Rigister
    var URL_FORGET = kServer + KServerPath + K_Forget
}

///HomePage Api
let K_TexiType: String = "select_taxi_type.php"
struct HomePageApi {
    var URL_TexiTypeApi = kServer + KServerPath + K_TexiType
}
let K_VerifyAccount = "verify_account.php?"
let K_ResendOTP = "resend_otp.php?"
let K_CalculateTaxiFare = "calculate_taxy_fare.php?"
let K_EditImageApi = "edit_image.php?"
let K_UserEditProfileApi = "user_profile_edit.php?"
let K_ChangePasswordApi = "change_pass.php?"
let K_PrivacyPolicyApi = "privacy/privacy.html"
let K_TermsConditionsApi = "privacy/user_terms.html"
let K_ContactUSApi = "contact_us.php?"
let K_GetCashWalletBalanceApi = "get_cash_wallet_balance.php?"
let K_GetCashWalletHistoryApi = "get_cash_wallet_history.php?"
let K_RechargeWalletApi = "payment_submit.php?"
let K_HubtelWalletApi = "hubtel_payment_submit.php?"
let K_HubtelPaymentCheckApi = "hubtel_payment_status_check.php?"
let K_BookRideApi = "book_ride1.php?"
let K_payRideApi = "pay.php?"
let K_MyBookingApi = "my_booking.php?"
let K_BookingDetailsApi = "booking_details.php?"
let K_DriverLocationApi = "get_ride_location.php?"
let K_PushDeviceRegistrationApi = "push_device_registration1.php?"
let K_CheckBookingStatusApi = "check_booking_status.php?"
let K_CancelRideApi = "cancel_ride.php?"
let K_UserBookingStatusApi = "user_booking_status.php?"
let K_DeleteTokenApi = "push_delete_device_reg.php?"
let K_AllotNewDriverApi = "allot_new_driver.php?"

// Constant message
let K_SomethingWentWrong = "Something went wrong."
let K_NoInternet = "Network lost. Please check your internet connection."
let K_Opps = "Oops!"


// Constant keys
let K_UserInfo = "user_info"
let K_UserID = "user_id"
let K_UserImage = "user_img"


