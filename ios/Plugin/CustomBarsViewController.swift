import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

// MARK: - CustomTopBarViewController
class CustomTopBarViewController: ContainerViewController {
    private lazy var instructionsBannerTopOffsetConstraint = {
        return instructionsBannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
    }()
    private lazy var centerOffset: CGFloat = calculateCenterOffset(with: view.bounds.size)
    private lazy var instructionsBannerCenterOffsetConstraint = {
        return instructionsBannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
    }()
    
    // You can Include one of the existing Views to display route-specific info
    lazy var instructionsBannerView: InstructionsBannerView = {
        let banner = InstructionsBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        banner.layer.cornerRadius = 25
        banner.layer.opacity = 0.75
        banner.separatorView.isHidden = true
        return banner
    }()
    
    override func viewDidLoad() {
        view.addSubview(instructionsBannerView)
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateConstraints()
    }
    
    private func setupConstraints() {
        instructionsBannerCenterOffsetConstraint.isActive = true
        instructionsBannerTopOffsetConstraint.isActive = true
    }
    
    private func updateConstraints() {
        instructionsBannerCenterOffsetConstraint.constant = centerOffset
    }
    
    // MARK: - Device rotation
    private func calculateCenterOffset(with size: CGSize) -> CGFloat {
        return (size.height < size.width ? -size.width / 5 : 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        centerOffset = calculateCenterOffset(with: size)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateConstraints()
    }
    
    // MARK: - NavigationServiceDelegate implementation
    public func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // pass updated data to sub-views which also implement `NavigationServiceDelegate`
        instructionsBannerView.updateDistance(for: progress.currentLegProgress.currentStepProgress)
    }
    
    public func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        instructionsBannerView.update(for: instruction)
    }
    
    public func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        instructionsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
    }
}

// MARK: - CustomBottomBarViewController
class CustomBottomBarViewController: ContainerViewController, CustomBottomBannerViewDelegate {
    
    weak var navigationViewController: NavigationViewController?
    
    // Or you can implement your own UI elements
    lazy var bannerView: CustomBottomBannerView = {
        let banner = CustomBottomBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.delegate = self
        return banner
    }()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(bannerView)
        
        let safeArea = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            bannerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            bannerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }
    
    private func setupConstraints() {
        if let superview = view.superview?.superview {
            view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    // MARK: - NavigationServiceDelegate implementation
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // Update your controls manually
        bannerView.progress = Float(progress.fractionTraveled)
        bannerView.eta = "~\(Int(round(progress.durationRemaining / 60))) min"
    }
    
    // MARK: - CustomBottomBannerViewDelegate implementation
    func customBottomBannerDidCancel(_ banner: CustomBottomBannerView) {
        navigationViewController?.dismiss(animated: true,
                                          completion: nil)
    }
}
