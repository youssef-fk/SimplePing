//
//  main.swift
//  SimplePingPackageDescription
//
//  Created by macbook on 24.02.2018.
//

import Foundation

class Main: NSObject {
    var forceIPv4 = false
    var forceIPv6 = false
    var pinger: Ping?
    var timer: Timer?
    
    override init() { }
    
    func runWithHostName(_ hostName: String) {
        let pinger = SimplePing(hostName: hostName)
        self.pinger = pinger
        
        if self.forceIPv4 && !self.forceIPv6 {
            pinger.addressStyle = .icmpv4
        } else if self.forceIPv6 && !self.forceIPv4 {
            pinger.addressStyle = .icmpv6
        } else {
            pinger.addressStyle = .any
        }
        
        pinger.delegate = self
        pinger.start()
        
        repeat {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
        } while self.pinger != nil
    }
    
    @objc func sendPing() {
        self.pinger?.sendPingWithData(nil)
    }
}

extension Main: PingDelegate {
    func pinger(_ pinger: Ping, didStartWithAddress address: Data) {
        print("pinging \(hostStringWithData(address))")
        self.sendPing()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)
    }
    
    func pinger(_ pinger: Ping, didFailWithError error: Error) {
        print("failed: \(error.localizedDescription)")
        
        self.timer?.invalidate()
        self.timer = nil
        self.pinger = nil
    }
    
    func pinger(_ pinger: Ping, didSendPacket packet: Data, sequence: UInt16) {
        print("#\(sequence) sent, size \(packet.count)")
    }
    
    func pinger(_ pinger: Ping, didFailToSendPacket packet: Data, sequence: UInt16, error: Error) {
        print("#\(sequence) send failed: \(error.localizedDescription)")
    }
    
    func pinger(_ pinger: Ping, didReceivePingResponsePacket packet: Data, sequence: UInt16, from: String) {
        print("#\(sequence) received from \(from), size \(packet.count)")
    }
    
    func pinger(_ pinger: Ping, didReceiveUnexpectedPacket packet: Data, from: String) {
        print("unexpected packet from \(from), size \(packet.count)")
    }
}

func printUsage() {
    print("usage: %s [-4] [-6] host\n", getprogname())
}

let main = Main()
while case let option = getopt(CommandLine.argc, CommandLine.unsafeArgv, "46"), option != -1 {
    let opt = UnicodeScalar(CUnsignedChar(option))
    switch opt {
    case "4":
        main.forceIPv4 = true
    case "6":
        main.forceIPv6 = true
    default:
        printUsage()
        exit(1)
    }
}
if CommandLine.arguments.count < 2 {
    printUsage()
    exit(1)
}
if CommandLine.arguments.last!.count < 5 {
    printUsage()
    exit(1)
}
main.runWithHostName(CommandLine.arguments.last!)
