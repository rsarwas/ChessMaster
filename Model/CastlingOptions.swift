//
//  CastlingOptions.swift
//  ChessMaster
//
//  Created by Regan Sarwas on 11/26/15.
//  Copyright © 2015 Regan Sarwas. All rights reserved.
//

public struct CastlingOptions : OptionSetType {
    public let rawValue : Int
    public init(rawValue:Int)
    {
        self.rawValue = rawValue
    }

    static let None  = CastlingOptions(rawValue:0)
    static let WhiteKingSide  = CastlingOptions(rawValue:1)
    static let WhiteQueenSide  = CastlingOptions(rawValue:2)
    static let BlackKingSide = CastlingOptions(rawValue:4)
    static let BlackQueenSide = CastlingOptions(rawValue:8)
    static let All:CastlingOptions = [.WhiteKingSide, .WhiteQueenSide, .BlackKingSide, .BlackQueenSide]
    static let BothWhite:CastlingOptions = [.WhiteKingSide, .WhiteQueenSide]
    static let BothBlack:CastlingOptions = [.BlackKingSide, .BlackQueenSide]
}