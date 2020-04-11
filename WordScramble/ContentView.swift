//
//  ContentView.swift
//  WordScramble
//
//  Created by Jason Franklin on 11.04.20.
//  Copyright © 2020 Jason Franklin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var currentScore = 0

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }

                Text("Your current score is: \(currentScore)")
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame, label: { Text("New Game") }))
            .onAppear(perform: startGame)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }

        guard isOriginal(word: answer) else {
            triggerAlert(withTitle: "Alread Used", andMessage: "You've already used that word.")
            return
        }

        guard isNotRootWord(word: answer) else {
            triggerAlert(withTitle: "Root Word!", andMessage: "You can't use the root word.")
            return
        }

        guard isPossible(word: answer) else {
            triggerAlert(withTitle: "Not Possible", andMessage: "You can't construct that word with the letter available.")
            return
        }

        guard isReal(word: answer) else {
            triggerAlert(withTitle: "Not Real", andMessage: "I'm sorry, that is not a real word.")
            return
        }

        currentScore += answer.count
        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    private func startGame() {
        guard let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let fileContents = try? String(contentsOf: fileURL) else {
                fatalError("Unable to load start.txt in main Bundle")
        }

        let words = fileContents.components(separatedBy: "\n")
        rootWord = words.randomElement() ?? "silkworm"

        usedWords = []
        newWord = ""
        currentScore = 0
    }

    private func isOriginal(word: String) -> Bool {
        guard !usedWords.contains(word) else { return false }
        return true
    }

    private func isNotRootWord(word: String) -> Bool {
        guard word != rootWord else { return false }
        return true
    }

    private func isPossible(word: String) -> Bool {
        var tmpWord = rootWord

        for letter in word {
            if let pos = tmpWord.firstIndex(of: letter) {
                tmpWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }

    private func triggerAlert(withTitle title: String, andMessage message: String) {
        alertTitle = title
        alertMessage = message

        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
