import Foundation


func sanitizeInput(_ text: String) -> String {
    // Allowed:
    // - letters
    // - numbers
    // - spaces
    // - dash, pipe, newline (for tab content)

    let allowed = CharacterSet(
        charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-|/\\\n"
    )

    return text.unicodeScalars
        .filter { allowed.contains($0) }
        .map(String.init)
        .joined()
}

func repadAllLines(in text: String, toWidth width: Int) -> String {
    return text
        .split(separator: "\n", omittingEmptySubsequences: false)
        .map { repadLine(String($0), toWidth: width) }
        .joined(separator: "\n")
}



func repadLine(_ line: String, toWidth width: Int) -> String {
    guard let pipeIndex = line.firstIndex(of: "|") else {
        return line   // no pipe → leave untouched
    }

    let prefix = line[..<pipeIndex]        // "e"
    let afterPipeStart = line.index(after: pipeIndex)
    let content = line[afterPipeStart...]  // "----3-5--"

    let currentCount = content.count

    if currentCount >= width {
        return line   // already long enough → do nothing
    }

    let needed = width - currentCount
    let padding = String(repeating: "-", count: needed)

    return "\(prefix)|\(content)\(padding)"
}

