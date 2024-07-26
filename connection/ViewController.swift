import UIKit

class ViewController: UIViewController {
    var bluetoothManager: BluetoothManager!
    var locationManager: LocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // BluetoothManagerの初期化
        bluetoothManager = BluetoothManager(viewController: self)
        
        // LocationManagerの初期化
        locationManager = LocationManager(viewController: self)
        locationManager.startTracking()
    }
}
