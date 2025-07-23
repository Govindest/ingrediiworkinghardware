import Foundation

final class OpenAIService {
  static let shared = OpenAIService()
  private init() {}

  private let apiKey = "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"
  private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

  func fetchRecipes(
    from pantry: [String],
    useExpiringOnly: Bool,
    completion: @escaping (Result<[Recipe], Error>) -> Void
  ) {
    let items = pantry.joined(separator: ", ")
    let clause = useExpiringOnly
      ? "Only use items that will expire soon."
      : "You may use any pantry item."

    let prompt = """
      You are a cooking assistant. Given my pantry: \(items). \(clause)
      Return up to three recipes as a pure JSON array. Each element:
      { "title":String, "ingredients":[String], "calories":Int }
      """

    let body: [String:Any] = [
      "model":"gpt-3.5-turbo",
      "messages":[
        ["role":"system","content":"You are helpful."],
        ["role":"user","content":prompt]
      ]
    ]

    var req = URLRequest(url: endpoint)
    req.httpMethod = "POST"
    req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try? JSONSerialization.data(withJSONObject: body)

    URLSession.shared.dataTask(with: req) { data, _, error in
      if let e = error { return completion(.failure(e)) }
      guard let d = data else {
        return completion(.failure(NSError(domain:"",code:-1)))
      }

      do {
        struct Chat: Decodable {
          struct Choice: Decodable { struct Msg: Decodable { let content:String }; let message:Msg }
          let choices:[Choice]
        }
        let chat = try JSONDecoder().decode(Chat.self, from: d)
        var text = chat.choices.first?.message.content ?? ""
        if text.hasPrefix("```") {
          text = text.components(separatedBy:"```")[1]
        }
        let recs = try JSONDecoder()
          .decode([Recipe].self, from: Data(text.utf8))
        completion(.success(recs))
      } catch {
        completion(.failure(error))
      }
    }
    .resume()
  }

  func generateRecipes(
    from pantry: [String],
    onlyExpiring: Bool
  ) async throws -> [Recipe] {
    try await withCheckedThrowingContinuation { cont in
      fetchRecipes(from: pantry, useExpiringOnly: onlyExpiring) {
        switch $0 {
        case .success(let r): cont.resume(returning: r)
        case .failure(let e): cont.resume(throwing: e)
        }
      }
    }
  }
}
