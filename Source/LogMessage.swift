//
//  LogMessage.swift
//
//  Copyright (c) 2015-present Nike, Inc. (https://www.nike.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A LogMessage is a detailed log entry with a name and a dictionary of associated attributes.
public protocol LogMessage {
    /// Name of this message.
    var name: String { get }

    /// Attributes associated with this message.
    var attributes: [String: Any] { get }
}

public extension LogMessage {
    /// Convert a LogMessage to a JSON string for output. This can be useful for some logging systems where messages are structured.
    ///
    /// - Parameter context: Optional context information for the  log message.
    func asJsonString(context: LogMessageContext? = nil, includeSession: Bool = false, includeUser: Bool = false) -> String {
        
        var attributesJson: String = ""
        for (key, value) in attributes {
            if let convertableValue = value as? CustomStringConvertible {
                let stringValue = String(describing: convertableValue)
                if attributesJson.isEmpty {
                    attributesJson += ", \"attributes\": { "
                }
                else {
                    attributesJson += ", "
                }
                attributesJson += """
    "\(key)": "\(stringValue)"
    """
            }
            else {
                print("Ignoring key (\(key)); not a CustomStringConvertible!")
            }
        }
        if attributesJson.isEmpty == false {
            attributesJson += "}"
        }
        
        if let contextData = context {
            var subsystem: String = ""
            if let subsystemName = contextData.subsystem {
                subsystem = ", \"subsystem\": \"\(subsystemName)\""
            }
            
            var category: String = ""
            if let categoryName = contextData.category {
                category = ", \"category\": \"\(categoryName)\""
            }
            
            var session: String = ""
            if includeSession == true {
                if let sessionName = contextData.session {
                    session = ", \"session\": \"\(sessionName)\""
                }
            }
            
            var user: String = ""
            if includeUser == true {
                if let userValue = contextData.user {
                    user = ", \"user\": \"\(userValue)\""
                }
            }
            
            var context: String = ""
            context = """
            , "context": { "level": "\(String(describing: contextData.logLevel))", "file": "\(contextData.file)", "function": "\(contextData.function)", "line": \(contextData.line) \(subsystem) \(category) \(session) \(user) }
            """
            
            return """
            { "message": "\(name)" \(attributesJson) \(context) }
            """
        }
        else {
                return """
            { "name": "\(name)"\(attributesJson) }
            """
        }
    }
}
