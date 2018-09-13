//
//  AskForPermissionView.swift
//  machApp
//
//  Created by lukas burns on 3/20/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Lottie
import Foundation
import UIKit

protocol PermissionViewDelegate: class {

    func permissionAccepted(permission: Permission)

    func permissionRejected(permission: Permission)
}

class PermissionView: UIView {

    var permission: Permission?
    weak var delegate: PermissionViewDelegate?

    @IBOutlet weak var permissionImage: UIImageView!

    @IBOutlet weak var perimissionTitleLabel: UILabel!

    @IBOutlet weak var acceptButton: UIButton!

    @IBOutlet weak var permissionDescriptionLabel: UILabel!

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var imageWrapper: UIView!

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    class func instanceFromNib(for permission: Permission) -> PermissionView? {
        let view = UINib(nibName: "PermissionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PermissionView
        view?.permission = permission
        view?.setup()
        return view
    }

    func setup() {
        guard let permission = permission else {
            return
        }
        switch permission {
        case .contacts:
            self.permissionImage.image = #imageLiteral(resourceName: "ic_request_contacts")
            self.perimissionTitleLabel.text = "Necesitamos permiso para acceder a tu lista de contactos"
            self.permissionDescriptionLabel.text = "MACH utiliza tu lista de contactos para hacer pagos y cobros de forma rápida entre tus amigos.\n Esta información no la compartimos con nadie."
            self.acceptButton.layer.cornerRadius = self.acceptButton.frame.height / 2
        case .pushNotifications:
            break
        case .locationServices:
            self.perimissionTitleLabel.text = "Conéctate a usuarios cercanos"
            self.permissionDescriptionLabel.text = "Puedes conectarte a otros usuarios MACH que estén físicamente cerca tuyo activando esta función.\n Es necesario activarla en ambos dispositivos para poder establecer el vínculo."
            self.topConstraint.constant = 100
            self.bottomConstraint.constant = 100
            self.leadingConstraint.constant = 30
            self.trailingConstraint.constant = 30
            self.containerView.layer.cornerRadius = 14.0
            self.permissionImage.animationImages = [#imageLiteral(resourceName: "image_near_1"), #imageLiteral(resourceName: "image_near_2"), #imageLiteral(resourceName: "image_near_3"), #imageLiteral(resourceName: "image_near_4")]
            self.permissionImage.animationRepeatCount = 0
            self.permissionImage.animationDuration = 4
            self.permissionImage.startAnimating()
            self.acceptButton.layer.cornerRadius = self.acceptButton.frame.height / 2
            self.acceptButton.clipsToBounds = true
//            let animationView = LOTAnimationView(name: "search_animation")
//            animationView.contentMode = .scaleAspectFit
//            animationView.frame = imageWrapper.bounds
//            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            imageWrapper.addSubview(animationView)
//            permissionImage.isHidden = true
//            animationView.loopAnimation = true
//            animationView.play()
        }
    }

    @IBAction func permissionAcceptedAction(_ sender: UIButton) {
        self.delegate?.permissionAccepted(permission: self.permission!)
    }

    @IBAction func permissionCanceledAction(_ sender: Any) {
        self.delegate?.permissionRejected(permission: self.permission!)
    }
}
