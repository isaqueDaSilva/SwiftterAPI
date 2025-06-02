//
//  FileSystemHandler.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import NIOCore
import NIOFileSystem

/// A handler that is responsible to reunes the main methods to interact with file system of the server.
enum FileSystemHandler {
    private static let fileSystem = FileSystem.shared
    
    /// Write a file at the file system.
    /// - Parameters:
    ///   - buffer: A buffer that stores the bytes of the file,
    ///   - path: The file path to store the file at the file system.
    static func write(_ buffer: ByteBuffer, at path: String) async throws {
        _ = try await fileSystem.withFileHandle(
            forWritingAt: .init(path),
            options: .newFile(replaceExisting: true)
        ) { file in
            try await file.write(contentsOf: buffer, toAbsoluteOffset: 0)
        }
    }
    
    /// Gets an file stored at a path in file system.
    /// - Parameter path: The path that the file is stored.
    /// - Returns: Returns a buffer that contains the bytes of the file.
    static func retrive(at path: String) async throws -> ByteBuffer {
        let buffer = try await ByteBuffer(
            contentsOf: .init(path),
            maximumSizeAllowed: .megabytes(1)
        )
        
        return buffer
    }
    
    
    /// Deletes a file that is stored at a path.
    /// - Parameter path: The path that the file is stored.
    /// - Returns: Retuns a boolean value indicating if the process occur with success or not.
    static func delete(at path: String) async throws -> Bool {
        let numberOfDeletedFiles = try await fileSystem.removeItem(at: .init(path))
        
        return numberOfDeletedFiles == 1
    }
}
