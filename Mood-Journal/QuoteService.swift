import Foundation

class QuoteService {
    static let shared = QuoteService()

    private init() {}

    func fetchRandomQuote(completion: @escaping (Quote?) -> Void) {
        let urlString = "https://api.quotable.io/random"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching quote: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data returned")
                completion(nil)
                return
            }

            do {
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                completion(quote)
            } catch {
                print("Error decoding quote: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }
}
