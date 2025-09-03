import SwiftUI

class CountriesViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var nextPageURL: String? = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10"
    
    private let headers = [
        "x-rapidapi-key": "af89b7b859msh76f4aa94196b1c7p16ea9djsnb51a2f8c0353",
        "x-rapidapi-host": "wft-geo-db.p.rapidapi.com"
    ]
    
    private var isFetchingNextPage = false
    
    func fetchCountries() {
        guard !isLoading, let urlString = nextPageURL, let url = URL(string: urlString) else { return }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async { self?.isLoading = false }
            
            if let error = error {
                DispatchQueue.main.async { self?.errorMessage = "Network error: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data else { return }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw API response:\n\(raw)")
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonObject["message"] as? String {
                    DispatchQueue.main.async {
                        self?.errorMessage = "API error: \(message)"
                    }
                    return
                }
                
                let decoded = try JSONDecoder().decode(CountriesResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.countries.append(contentsOf: decoded.data)
                    
                    if let nextLink = decoded.links.first(where: { $0.rel == "next" }) {
                        let href = nextLink.href
                        self?.nextPageURL = href.hasPrefix("http")
                        ? href
                        : "https://wft-geo-db.p.rapidapi.com" + href
                    } else {
                        self?.nextPageURL = nil
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchNextPageWithDelay() {
        guard !isLoading, !isFetchingNextPage, nextPageURL != nil else { return }
        isFetchingNextPage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.fetchCountries()
            self.isFetchingNextPage = false
        }
    }
    
    func retry() {
        fetchCountries()
    }
}
