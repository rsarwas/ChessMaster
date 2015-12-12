//
//  Board_IO.swift
//  ChessMaster
//
//  Created by Regan Sarwas on 11/3/15.
//  Copyright © 2015 Regan Sarwas. All rights reserved.
//

// MARK: CustomStringConvertible

// Forsyth–Edwards Notation (FEN) is a standard notation for describing a board position in Chess
// https://en.wikipedia.org/wiki/Forsyth–Edwards_Notation
// It is an ASCII character string composed of 6 required parts separated by a space
// for additional details see section 16.1 at http://www.thechessdrum.net/PGN_Reference.txt

extension Board: CustomStringConvertible, CustomDebugStringConvertible {

    init?(fromFEN fen: String) {

        func parseFenPiecePlacement(s: String) -> [Location:Piece]? {
            let ranks = s.split("/")
            if ranks.count != 8 {
                print("FEN line '\(s)' does not have 8 ranks")
                return nil
            }
            var board = Dictionary<Location,Piece>()
            for index in 0...7 {
                if let rank_list = parseFenRank(ranks[index]) {
                    let rank = 8 - index
                    for (i,file) in [File.A, .B, .C, .D, .E, .F, .G, .H].enumerate() {
                        board[Location(file: file, rank:Rank(integerLiteral:rank))] = rank_list[i]
                    }
                } else {
                    return nil
                }
            }
            return board
        }

        func parseFenActiveColor(s: String) -> Color? {
            if s == "w" { return .White }
            if s == "b" { return .Black }
            print("FEN Active Color '\(s)' is not 'w' or 'b'")
            return nil
        }

        func parseFenCastlingOptions(str: String) -> CastlingOptions? {
            var s = str
            var castlingOptions = CastlingOptions.None
            if s == "-" { return castlingOptions }
            if s.hasPrefix("K") {
                castlingOptions.insert(.WhiteKingSide)
                s.removeAtIndex(s.startIndex)
            }
            if s.hasPrefix("Q") {
                castlingOptions.insert(.WhiteQueenSide)
                s.removeAtIndex(s.startIndex)
            }
            if s.hasPrefix("k") {
                castlingOptions.insert(.BlackKingSide)
                s.removeAtIndex(s.startIndex)
            }
            if s.hasPrefix("q") {
                castlingOptions.insert(.BlackQueenSide)
                s.removeAtIndex(s.startIndex)
            }
            if s.characters.count == 0 {
                return castlingOptions
            } else {
                print("FEN Castle Availability '\(str)' has unexpected characters or order")
            }
            return nil
        }

        func parseFenEnPassantTargetSquare(s:String) -> (Bool, Location?) {
            if s == "-" { return (true, nil) }
            if let location = s.fenLocation {
                if location.rank == 3 || location.rank == 6 {
                    return (true, location)
                } else {
                    print("FEN enPassant target square '\(s)' is not on rank 3 or 6")
                }
            } else {
                print("FEN enPassant target square '\(s)' is not a valid board position")
            }
            return (false, nil)
        }

        func parseFenHalfMoveClock(s:String) -> Int? {
            if let count = Int(s) {
                if 0 <= count {
                    return count
                } else {
                    print("FEN Halfmove Clock '\(s)' is not non-negative")
                }
            } else {
                print("FEN Halfmove Clock '\(s)' is not an integer")
            }
            return nil
        }

        func parseFenFullMoveNumber(s:String) -> Int? {
            if let count = Int(s) {
                if 0 < count {
                    return count
                } else {
                    print("FEN Fullmove Number '\(s)' is not positive")
                }
            } else {
                print("FEN Fullmove Number '\(s)' is not an integer")
            }
            return nil
        }

        func parseFenRank(str:String) -> [Piece?]? {
            let s = expandBlanks(str)
            if s.characters.count == 8 {
                //FIXME: Check for unrecognized pieces
                return s.characters.map { $0 == "-" ? nil : $0.fenPiece }
            } else {
                print("FEN FenRank '\(str)' does not have 8 squares")
            }
            return nil
        }

        func expandBlanks(str:String) -> String {
            var s = ""
            for c in str.characters {
                switch c {
                case "8": s += "--------"
                case "7": s += "-------"
                case "6": s += "------"
                case "5": s += "-----"
                case "4": s += "----"
                case "3": s += "---"
                case "2": s += "--"
                case "1": s += "-"
                default: s += String(c)
                }
            }
            return s
        }

        let parts = fen.split(" ")
        if parts.count != 6 {
            print("FEN line '\(fen)' does not have 6 parts")
            return nil
        }
        if let piecePlacement = parseFenPiecePlacement(parts[0]) {
            if let activeColor = parseFenActiveColor(parts[1]) {
                if let castlingOptions = parseFenCastlingOptions(parts[2]) {
                    let (ok, enPassant) = parseFenEnPassantTargetSquare(parts[3])
                    if ok {
                        if let halfMoveClock = parseFenHalfMoveClock(parts[4]) {
                            if let fullMoveNumber = parseFenFullMoveNumber(parts[5]) {
                                self.init(pieces: piecePlacement,
                                    activeColor: activeColor,
                                    castlingOptions: castlingOptions,
                                    enPassantTargetSquare: enPassant,
                                    halfMoveClock: halfMoveClock,
                                    fullMoveNumber: fullMoveNumber)
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

    var description: String {
        get {
            return fen
        }
    }
    
    var debugDescription: String {
        get {
            return fen
        }
    }

    var fenBoardDescription: String {
        var lines :[String] = []
        for rank in Rank.allValues.reverse() {
            var line = ""
            var emptyCount = 0
            for file in File.allValues {
                if let piece = pieceAt(Location(file:file, rank:rank)) {
                    if 0 < emptyCount {
                        line += "\(emptyCount)"
                        emptyCount = 0
                    }
                    line += "\(piece.fen)"
                } else {
                    emptyCount += 1
                }
            }
            if emptyCount > 0 {
                line += "\(emptyCount)"
            }
            lines.append(line)
        }
        return lines.joinWithSeparator("/")
    }

    var fen: String {
        get {            
            let fenBoard = fenBoardDescription
            let enPassant = enPassantTargetSquare == nil ? "-" : "\(enPassantTargetSquare!)"
            let color = activeColor == .White ? "w" : "b"
            let castle =
                (castlingOptions.contains(.WhiteKingSide) ? "K" : "") +
                (castlingOptions.contains(.WhiteQueenSide) ? "Q" : "") +
                (castlingOptions.contains(.BlackQueenSide) ? "k" : "") +
                (castlingOptions.contains(.BlackQueenSide) ? "q" : "") +
                (castlingOptions == .None ? "-" : "")
            return "\(fenBoard) \(color) \(castle) \(enPassant) \(halfMoveClock) \(fullMoveNumber)"
        }
    }

    //MARK: - Private string parsing functions

}

extension String {
    var fen: Board? {
        return Board()
    }
}