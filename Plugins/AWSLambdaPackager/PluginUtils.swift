// //===----------------------------------------------------------------------===//
// //
// // This source file is part of the SwiftAWSLambdaRuntime open source project
// //
// // Copyright (c) 2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// // Licensed under Apache License v2.0
// //
// // See LICENSE.txt for license information
// // See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
// //
// // SPDX-License-Identifier: Apache-2.0
// //
// //===----------------------------------------------------------------------===//

// import Dispatch
// import Foundation
// import PackagePlugin
// import Synchronization

// @available(macOS 15.0, *)
// struct Utils {
//     @discardableResult
//     static func execute(
//         executable: URL,
//         arguments: [String],
//         customWorkingDirectory: URL? = .none,
//         logLevel: ProcessLogLevel
//     ) throws -> String {
//         if logLevel >= .debug {
//             print("\(executable.absoluteString) \(arguments.joined(separator: " "))")
//         }

//         let fd = dup(1)
//         let stdout = fdopen(fd, "rw")
//         defer { fclose(stdout) }

//         // We need to use an unsafe transfer here to get the fd into our Sendable closure.
//         // This transfer is fine, because we write to the variable from a single SerialDispatchQueue here.
//         // We wait until the process is run below process.waitUntilExit().
//         // This means no further writes to output will happen.
//         // This makes it save for us to read the output
//         struct UnsafeTransfer<Value>: @unchecked Sendable {
//             let value: Value
//         }

//         let outputMutex = Mutex("")
//         let outputSync = DispatchGroup()
//         let outputQueue = DispatchQueue(label: "AWSLambdaPackager.output")
//         let unsafeTransfer = UnsafeTransfer(value: stdout)
//         let outputHandler = { @Sendable (data: Data?) in
//             dispatchPrecondition(condition: .onQueue(outputQueue))

//             outputSync.enter()
//             defer { outputSync.leave() }

//             guard
//                 let _output = data.flatMap({
//                     String(data: $0, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(["\n"]))
//                 }), !_output.isEmpty
//             else {
//                 return
//             }

//             outputMutex.withLock { output in
//                 output += _output + "\n"
//             }

//             switch logLevel {
//             case .silent:
//                 break
//             case .debug(let outputIndent), .output(let outputIndent):
//                 print(String(repeating: " ", count: outputIndent), terminator: "")
//                 print(_output)
//                 fflush(unsafeTransfer.value)
//             }
//         }

//         let pipe = Pipe()
//         pipe.fileHandleForReading.readabilityHandler = { fileHandle in
//             outputQueue.async { outputHandler(fileHandle.availableData) }
//         }

//         let process = Process()
//         process.standardOutput = pipe
//         process.standardError = pipe
//         process.executableURL = URL(fileURLWithPath: executable.description)
//         process.arguments = arguments
//         if let workingDirectory = customWorkingDirectory {
//             process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory.path())
//         }
//         process.terminationHandler = { _ in
//             outputQueue.async {
//                 outputHandler(try? pipe.fileHandleForReading.readToEnd())
//             }
//         }

//         try process.run()
//         process.waitUntilExit()

//         // wait for output to be full processed
//         outputSync.wait()

//         let output = outputMutex.withLock { $0 }

//         if process.terminationStatus != 0 {
//             // print output on failure and if not already printed
//             if logLevel < .output {
//                 print(output)
//                 fflush(stdout)
//             }
//             throw ProcessError.processFailed([executable.path()] + arguments, process.terminationStatus)
//         }

//         return output
//     }

//     enum ProcessError: Error, CustomStringConvertible {
//         case processFailed([String], Int32)

//         var description: String {
//             switch self {
//             case .processFailed(let arguments, let code):
//                 return "\(arguments.joined(separator: " ")) failed with code \(code)"
//             }
//         }
//     }

//     enum ProcessLogLevel: Comparable {
//         case silent
//         case output(outputIndent: Int)
//         case debug(outputIndent: Int)

//         var naturalOrder: Int {
//             switch self {
//             case .silent:
//                 return 0
//             case .output:
//                 return 1
//             case .debug:
//                 return 2
//             }
//         }

//         static var output: Self {
//             .output(outputIndent: 2)
//         }

//         static var debug: Self {
//             .debug(outputIndent: 2)
//         }

//         static func < (lhs: ProcessLogLevel, rhs: ProcessLogLevel) -> Bool {
//             lhs.naturalOrder < rhs.naturalOrder
//         }
//     }
// }
