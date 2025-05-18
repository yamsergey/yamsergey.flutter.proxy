import Foundation

class YSFPPProxy {
    let host: String?
    let port: String?
    let user: String?
    let password: String?
    let type: YSFPPProxyType
    
    init(host: String?, port: String?, user: String?, password: String?, type: YSFPPProxyType) {
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.type = type
    }
    
    private func toString(_ value: String?) -> String {
        return value ?? ""
    }
    
    private var typeString: String {
        switch type {
        case .https: return "https"
        case .http: return "http"
        case .none: return "none"
        }
    }
    
    var description: String {
        return "{\"host\": \"\(toString(host))\", \"port\": \"\(toString(port))\", \"user\": \"\(toString(user))\", \"password\": \"\(toString(password))\", \"type\": \"\(typeString)\"}"
    }
}
