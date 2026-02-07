//
//  LeaderboardEntry.swift
//  FindItKIET
//
//  Model for leaderboard data
//

import Foundation

struct LeaderboardEntry: Identifiable, Decodable {
    let id: String
    let name: String
    let email: String
    let itemCount: Int
    let rank: Int
}

struct LeaderboardResponse: Decodable {
    let month: String
    let leaderboard: [LeaderboardEntry]
}
