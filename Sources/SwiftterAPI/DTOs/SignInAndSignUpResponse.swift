//
//  SignInAndSignUpResponse.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//


import Vapor

typealias SignUpResponse = SignInAndSignUpResponse
typealias SignInResponse = SignInAndSignUpResponse

struct SignInAndSignUpResponse: Content {
    let accessToken: String
    let refreshToken: Data
    let serverPublicKey: Data
    let userProfile: Profile
}
