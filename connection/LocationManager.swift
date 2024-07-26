import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var viewController: UIViewController?

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }

    func startTracking() {
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            showAlert(with: "すれ違ったLocation", message: "現在地: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
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
