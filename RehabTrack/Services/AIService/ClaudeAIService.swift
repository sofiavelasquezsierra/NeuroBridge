import Foundation

// MARK: - Errors

enum AIServiceError: Error, LocalizedError {
    case networkError(underlying: Error)
    case apiError(statusCode: Int, message: String)
    case invalidResponse(detail: String)

    var errorDescription: String? {
        switch self {
        case .networkError(let e):       return "Network error: \(e.localizedDescription)"
        case .apiError(let code, let m): return "Claude API error \(code): \(m)"
        case .invalidResponse(let d):    return "Could not parse AI response: \(d)"
        }
    }
}

// MARK: - ClaudeAIService

final class ClaudeAIService: AIService {

    private let apiKey: String
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let imbalanceThreshold = 0.20

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateRecommendations(for patient: Patient, recentSessions: [EMGSession]) async throws -> AIRecommendation {
        let userMessage = buildUserMessage(patient: patient, sessions: recentSessions)
        let responseData = try await callAPI(userMessage: userMessage)
        return try parseRecommendation(from: responseData, patient: patient)
    }

    // MARK: - Prompt Construction

    private func buildUserMessage(patient: Patient, sessions: [EMGSession]) -> String {
        let sorted = sessions.sorted { $0.startTime < $1.startTime }
        let byMuscle = Dictionary(grouping: sorted, by: \.muscleGroup)

        var lines: [String] = []

        // Patient context
        lines.append("## Patient Profile")
        lines.append("- Injury: \(patient.injuryDescription)")
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: patient.injuryDate, to: Date()).weekOfYear ?? 0
        lines.append("- Weeks post-injury: \(weeks)")
        lines.append("- Target muscles: \(patient.targetMuscles.map(\.displayName).joined(separator: ", "))")
        lines.append("- Total EMG sessions recorded: \(sessions.count)")

        // Per-muscle data
        lines.append("\n## EMG Activation Data by Muscle")
        for muscle in MuscleGroup.allCases {
            let muscleSessions = byMuscle[muscle] ?? []
            guard !muscleSessions.isEmpty else { continue }

            let sortedMuscle = muscleSessions.sorted { $0.startTime < $1.startTime }
            let avgAmp = muscleSessions.map(\.averageAmplitude).reduce(0, +) / Double(muscleSessions.count)
            let peakAmp = muscleSessions.map(\.peakAmplitude).max() ?? 0
            let recentFatigue = sortedMuscle.suffix(5).map(\.fatigueIndex).reduce(0, +) / Double(min(sortedMuscle.count, 5))

            let trend: String
            if sortedMuscle.count >= 4 {
                let recent = sortedMuscle.suffix(3).map(\.averageAmplitude)
                let older = sortedMuscle.dropLast(3).suffix(3).map(\.averageAmplitude)
                let recentAvg = recent.reduce(0, +) / Double(recent.count)
                let olderAvg = older.reduce(0, +) / Double(older.count)
                let pct = ((recentAvg - olderAvg) / max(olderAvg, 1)) * 100
                trend = pct >= 0
                    ? String(format: "improving (+%.1f%%)", pct)
                    : String(format: "declining (%.1f%%)", pct)
            } else {
                trend = "insufficient data for trend"
            }

            lines.append("\n**\(muscle.displayName)** (\(muscleSessions.count) sessions)")
            lines.append("  - Average amplitude: \(String(format: "%.1f µV", avgAmp))")
            lines.append("  - Peak amplitude: \(String(format: "%.1f µV", peakAmp))")
            lines.append("  - Recent fatigue index: \(String(format: "%.2f", recentFatigue)) (1.0 = no fatigue, <0.8 = fatiguing quickly)")
            lines.append("  - Activation trend: \(trend)")
        }

        // Muscle imbalance detection
        let ampByMuscle: [MuscleGroup: Double] = byMuscle.mapValues { s in
            s.map(\.averageAmplitude).reduce(0, +) / Double(s.count)
        }

        var imbalances: [(weaker: MuscleGroup, stronger: MuscleGroup, deficit: Int)] = []
        var checked = Set<String>()
        for muscle in ampByMuscle.keys {
            guard let opponent = muscle.antagonist,
                  let a = ampByMuscle[muscle],
                  let b = ampByMuscle[opponent] else { continue }
            let key = [muscle.rawValue, opponent.rawValue].sorted().joined()
            guard !checked.contains(key) else { continue }
            checked.insert(key)

            let stronger = a >= b ? muscle : opponent
            let weaker   = a >= b ? opponent : muscle
            let deficit  = (max(a, b) - min(a, b)) / max(max(a, b), 1)
            if deficit >= Self.imbalanceThreshold {
                imbalances.append((weaker, stronger, Int(deficit * 100)))
            }
        }

        if !imbalances.isEmpty {
            lines.append("\n## Detected Muscle Imbalances")
            for i in imbalances {
                lines.append("- **\(i.weaker.displayName)** is \(i.deficit)% weaker than \(i.stronger.displayName) — corrective work needed")
            }
        } else {
            lines.append("\n## Muscle Balance")
            lines.append("- No significant imbalances detected between antagonist pairs")
        }

        lines.append("\n## Task")
        lines.append("Recommend 2–4 specific exercises for this patient. Prioritize:")
        lines.append("1. Corrective exercises for any detected imbalances")
        lines.append("2. Muscle-specific training based on activation trends and fatigue")
        lines.append("3. Appropriate intensity given \(weeks) weeks post-injury")

        return lines.joined(separator: "\n")
    }

    // MARK: - API Call

    private func callAPI(userMessage: String) async throws -> Data {
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,              forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 4096,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIServiceError.networkError(underlying: error)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(underlying: error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse(detail: "No HTTP response")
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            throw AIServiceError.apiError(statusCode: http.statusCode, message: body)
        }

        return data
    }

    // MARK: - Response Parsing

    private func parseRecommendation(from data: Data, patient: Patient) throws -> AIRecommendation {
        let apiResponse: APIResponse
        do {
            apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        } catch {
            throw AIServiceError.invalidResponse(detail: "Could not decode API envelope: \(error)")
        }

        // Find the text block — thinking blocks may precede it
        guard let textBlock = apiResponse.content.first(where: { $0.type == "text" }),
              let text = textBlock.text else {
            throw AIServiceError.invalidResponse(detail: "No text block in response")
        }

        let jsonString = extractJSON(from: text)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIServiceError.invalidResponse(detail: "Could not encode JSON string")
        }

        let rec: RecommendationJSON
        do {
            rec = try JSONDecoder().decode(RecommendationJSON.self, from: jsonData)
        } catch {
            throw AIServiceError.invalidResponse(detail: "Could not decode recommendation JSON: \(error)\n\nRaw: \(jsonString.prefix(300))")
        }

        let exercises = rec.suggestedExercises.map { ex -> SuggestedExercise in
            let muscles = ex.targetMuscles.compactMap { MuscleGroup(rawValue: $0) }
            return SuggestedExercise(
                name: ex.name,
                description: ex.description,
                targetMuscles: muscles.isEmpty ? patient.targetMuscles : muscles,
                reps: ex.reps,
                sets: ex.sets,
                frequencyPerWeek: ex.frequencyPerWeek,
                rationale: ex.rationale
            )
        }

        return AIRecommendation(
            patient: patient,
            reasoning: rec.reasoning,
            suggestedExercises: exercises
        )
    }

    /// Strips markdown code fences if Claude wraps the JSON in them.
    private func extractJSON(from text: String) -> String {
        // ```json\n...\n```
        if let start = text.range(of: "```json\n")?.upperBound ?? text.range(of: "```\n")?.upperBound,
           let end = text[start...].range(of: "\n```")?.lowerBound {
            return String(text[start..<end])
        }
        // Bare JSON object
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text
    }

    // MARK: - System Prompt

    private let systemPrompt = """
    You are an AI rehabilitation exercise coach embedded in a physical therapy iOS application. \
    You analyze EMG (electromyography) muscle activation data to generate personalized, evidence-based \
    exercise recommendations for patients recovering from upper-limb injuries.

    Clinical context:
    - EMG average amplitude (µV) reflects muscle activation strength. Lower than normal indicates weakness or inhibition.
    - The fatigue index is the ratio of second-half to first-half amplitude in a session. Values below 0.8 indicate the muscle fatigues rapidly.
    - A declining activation trend may indicate overtraining, insufficient recovery, or neuromuscular inhibition.
    - Muscle imbalances between antagonist pairs (e.g. biceps vs triceps) increase injury risk and impair function.

    Training goal guidelines:
    - Hypertrophy / strength building: 8–12 reps, 3–4 sets, 3–4x per week (for muscles with good trend and endurance)
    - Muscular endurance: 15–25 reps, 2–3 sets, 4–5x per week (for muscles with poor fatigue index)
    - Active recovery / neuromuscular re-education: 10–15 reps, 2 sets, 3x per week (for declining activation)
    - Corrective / unilateral isolation: match the above based on the weaker muscle's data

    You must respond with ONLY valid JSON — no markdown fences, no preamble, no explanation outside the JSON:
    {
      "reasoning": "Thorough clinical explanation of your analysis and the rationale behind each recommendation. Providers read this to understand your logic.",
      "suggestedExercises": [
        {
          "name": "Exercise name",
          "description": "Detailed description: equipment, starting position, tempo, range of motion cues",
          "targetMuscles": ["biceps"],
          "reps": 12,
          "sets": 3,
          "frequencyPerWeek": 4,
          "rationale": "Specific reason this exercise addresses this patient's EMG findings"
        }
      ]
    }

    Strict rules:
    - targetMuscles values must only come from this list: biceps, triceps, deltoid, forearmFlexors, forearmExtensors, wristFlexors, wristExtensors
    - reps, sets, and frequencyPerWeek must be integers
    - Recommend 2–4 exercises total
    - For imbalances, always include a corrective exercise targeting the weaker muscle
    - Scale intensity conservatively for patients under 6 weeks post-injury
    """
}

// MARK: - Decodable Types (private)

private struct APIResponse: Decodable {
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}

private struct RecommendationJSON: Decodable {
    let reasoning: String
    let suggestedExercises: [ExerciseJSON]

    struct ExerciseJSON: Decodable {
        let name: String
        let description: String
        let targetMuscles: [String]
        let reps: Int
        let sets: Int
        let frequencyPerWeek: Int
        let rationale: String

        // Handles both Int and Double in case the model returns 10.0 instead of 10
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name          = try c.decode(String.self,   forKey: .name)
            description   = try c.decode(String.self,   forKey: .description)
            targetMuscles = try c.decode([String].self, forKey: .targetMuscles)
            rationale     = try c.decode(String.self,   forKey: .rationale)
            reps            = Self.decodeInt(c, key: .reps)
            sets            = Self.decodeInt(c, key: .sets)
            frequencyPerWeek = Self.decodeInt(c, key: .frequencyPerWeek)
        }

        private static func decodeInt(_ c: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Int {
            if let v = try? c.decode(Int.self,    forKey: key) { return v }
            if let v = try? c.decode(Double.self, forKey: key) { return Int(v) }
            return 0
        }

        enum CodingKeys: String, CodingKey {
            case name, description, targetMuscles, reps, sets, frequencyPerWeek, rationale
        }
    }
}
