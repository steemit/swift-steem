/// Cryptographically secure random number generation.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

#if !os(Linux)
    import Security
#else
    import Glibc
#endif

/// A cryptographically secure number random generator.
internal struct Random {
    /// Get random bytes.
    /// - Parameter count: How many bytes to generate.
    static func bytes(count: Int) -> Data {
        var rv = Data(count: count)
        #if os(Linux)
            guard let file = fopen("/dev/urandom", "r") else {
                fatalError("Unable to open /dev/urandom for reading.")
            }
            defer { fclose(file) }
            let bytesRead = rv.withUnsafeMutableBytes {
                fread($0, 1, count, file)
            }
            guard bytesRead == count else {
                fatalError("Unable to read from /dev/urandom.")
            }
        #else
            let result = rv.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, count, $0)
            }
            guard result == errSecSuccess else {
                fatalError("Unable to generate random data.")
            }
        #endif
        return rv
    }
}
