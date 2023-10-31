#if !os(macOS)

import Foundation

#if os(Linux) || os(FreeBSD) || os(OpenBSD)
 // urandom is preferred for cryptography on these platforms
fileprivate let kSecRandomPath = "/dev/urandom";
#endif

// this is an inaccurate port of SecRandomCopyBytes.

public class SecRandomRef {
    public let kSecRandomFD = open(kSecRandomPath, O_RDONLY)

    @inlinable static func != (lhs: SecRandomRef, rhs: SecRandomRef) -> Bool {
        return lhs.kSecRandomFD != lhs.kSecRandomFD
    }

}

public let kSecRandomDefault = SecRandomRef()
public let errSecParam = -50
public let errSecSuccess = 0

public func SecRandomCopyBytes(_ rnd: SecRandomRef, _ count: size_t, _ bytes: UnsafeMutableRawPointer) -> Int 
{
    var resid = count
    var offset = 0

    if (rnd != kSecRandomDefault){
        print("(rnd != kSecRandomDefault) failed")
        return errSecParam;
    }
    
    if (rnd.kSecRandomFD < 0){
        print("(rnd.kSecRandomFD < 0) failed")
        return -1;
    }

    repeat {
        let bytes_read = read(rnd.kSecRandomFD, bytes + offset, resid) 
        
        guard bytes_read != -1 else {
            if errno == EINTR {
                continue
            }
            print("(bytes_read != -1) failed : \(String(describing: strerror(errno)))")
            return -1
        }
        
        offset += bytes_read
        resid -= bytes_read
    } while resid > 0

	return errSecSuccess;
}

#endif