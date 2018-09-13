//
//  SplashTourViewController.swift
//  machApp
//
//  Created by Lukas Burns on 12/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class SplashTourPageViewController: UIPageViewController {

    var timer: Timer!
    var currentPage: SplashMessageViewController?
    let messages: [String] = ["Compra en e-commerce internacionales",
                              "Paga a tus contactos sin digipass ni coordenadas",
                              "Recarga y retira con tu banco",
                              "Gratis y sin comisiones"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
        self.dataSource = self
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        appearance.currentPageIndicatorTintColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    internal func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(forward), userInfo: nil, repeats: true)
    }
    
    internal func stopTimer() {
        self.timer.invalidate()
    }

}

extension SplashTourPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? SplashMessageViewController {
            var index = viewController.index
            index -= 1
            return contentViewController(at: index)
        }
        return contentViewController(at: 0)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? SplashMessageViewController {
            var index = viewController.index
            index += 1
            return contentViewController(at: index)
        }
        return contentViewController(at: 0)
    }

    func contentViewController(at index: Int) -> SplashMessageViewController? {
        var index = index
        if index < 0, let i = currentPage?.index {
            index = i + 1
        }
        if index >= messages.count {
            index = 0
        }
        let message = messages[index]
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier:
            "SplashMessageViewController") as? SplashMessageViewController {
            currentPage = pageContentViewController
            currentPage?.index = index
            currentPage?.message = message
            return pageContentViewController
        }
        currentPage = nil
        return nil
    }

    @objc func forward() {
        var index = currentPage?.index ?? 0
        index += 1
        if index == self.messages.count {
            index = 0
        }
        if let nextViewController = contentViewController(at: index) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.messages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPage?.index ?? 0
    }

}
