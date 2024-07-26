import CoreBluetooth
import MultipeerConnectivity
import UIKit

class BluetoothManager: NSObject, CBPeripheralManagerDelegate, CBCentralManagerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    var mcNearbyServiceBrowser: MCNearbyServiceBrowser!
    var viewController: UIViewController?

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController

        // CoreBluetoothの初期化
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)

        // MultipeerConnectivityの初期化
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self

        // サービスの初期化
        initializeServices()
    }

    func initializeServices() {
        self.mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "example-service")
        self.mcAdvertiserAssistant.delegate = self
        self.mcNearbyServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "example-service")
        self.mcNearbyServiceBrowser.delegate = self

        // サービスの開始
        startServices()
    }

    func startServices() {
        self.mcAdvertiserAssistant.startAdvertisingPeer()
        self.mcNearbyServiceBrowser.startBrowsingForPeers()
    }

    func stopServices() {
        self.mcAdvertiserAssistant.stopAdvertisingPeer()
        self.mcNearbyServiceBrowser.stopBrowsingForPeers()
    }

    // CBPeripheralManagerDelegateのメソッド
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            let advertisementData = [CBAdvertisementDataLocalNameKey: "ExampleDevice"]
            peripheralManager.startAdvertising(advertisementData)
        default:
            break
        }
    }

    // CBCentralManagerDelegateのメソッド
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    // MCSessionDelegateのメソッド
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            showAlert(with: "すれ違った", message: "\(peerID.displayName) とすれ違いました")

            // 数字の1を送信
            sendData(data: 1)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // 数字のデータをデコードして表示
        let receivedNumber = data.withUnsafeBytes { $0.load(as: Int.self) }
        showAlert(with: "メッセージを受信", message: "受信した番号: \(receivedNumber)")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // ストリーム受信時の処理
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // リソース受信開始時の処理
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // リソース受信完了時の処理
    }

    // データ送信メソッド
    func sendData(data: Int) {
        if mcSession.connectedPeers.count > 0 {
            var dataToSend = data
            let data = Data(bytes: &dataToSend, count: MemoryLayout.size(ofValue: dataToSend))
            do {
                try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                print("Error sending data: \(error.localizedDescription)")
            }
        }
    }

    // MCNearbyServiceAdvertiserDelegateのメソッド
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Failed to start advertising: \(error.localizedDescription)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mcSession)
    }

    // MCNearbyServiceBrowserDelegateのメソッド
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Failed to start browsing: \(error.localizedDescription)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }

    // アラート表示メソッド
    private func showAlert(with title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
        }
    }
}
