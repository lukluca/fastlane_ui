//
//  CommandExecuting.swift
//  Fastlane-UI
//
//  Created by softwave on 05/09/23.
//

import Foundation

protocol CommandExecuting: RawRepresentable where RawValue == String {
}

enum CommandError: Error {
    case commandNotFound(name: String)
    case fileNotFound(name: String)
}

extension CommandExecuting {
    func run(commandName: String, arguments: [String] = []) throws -> String {
        try run(resolve(commandName), with: arguments)
    }

    private func resolve(_ command: String) throws -> String {
        guard var bashCommand = try? run(rawValue , with: ["-l", "-c", "which \(command)"]) else {
            throw CommandError.commandNotFound(name: command)
        }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return bashCommand
    }

    private func run(_ command: String, with arguments: [String] = []) throws -> String {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()
        process.waitUntilExit()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        print(output)
        return output
    }
    
    func prepareBundleScript(commands: [String]) throws {
        let join = commands.joined(separator: " ; ")
        let bundle = Bundle.main
        guard let scriptURL = bundle.scriptURL else {
            throw CommandError.fileNotFound(name: bundle.scriptFileName)
        }
        
        let str = "#!\(rawValue)\n\nosascript -e 'tell app \"Terminal\"\ndo script \"\(join)\"\nend tell'"
        try str.write(to: scriptURL, atomically: true, encoding: String.Encoding.utf8)
    }
    
    func runBundleScript() throws -> String {
        let bundle = Bundle.main
        guard let scriptURL = bundle.scriptURL else {
            throw CommandError.fileNotFound(name: bundle.scriptFileName)
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: rawValue)
        process.arguments = ["-c", "source \(scriptURL.path)"]
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        print(output)
        return output
    }
}

extension Bundle {
    var scriptFileName: String {
        "script"
    }
    
    var scriptURL: URL? {
        url(forResource: scriptFileName, withExtension: "sh")
    }
}
