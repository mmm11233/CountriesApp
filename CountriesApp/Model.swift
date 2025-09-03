import Foundation

struct Country: Codable, Identifiable, Equatable {
    let code: String
    let currencyCodes: [String]
    let name: String
    let wikiDataId: String
    
    var id: String { code }
}

struct CountriesResponse: Codable {
    let data: [Country]
    let links: [Link]
    let metadata: Metadata
}

struct Link: Codable {
    let rel: String
    let href: String
}

struct Metadata: Codable {
    let currentOffset: Int
    let totalCount: Int
}
