//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Ashish Bansal on 04/10/18.
//  Copyright © 2018 Ashish Bansal. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {
    
    private var concentrationViewController: ConcentrationViewController?
    
    private var emojiThemeCollection = ["Food":"🧀🌮🍕🍔🍗🍪🍩🍰",
                                        "Faces":"😀☺️😇😍🤪🤓🤩😡",
                                        "Animals":"🐶🐽🐸🐒🐤🦉🐝🦆",
                                        "Sports":"⚽️🏀🏈🎾⚾️🏐🏉🎱",
                                        "Transports":"🚗🚚🚲🚜🛵🚠🚂✈️",
                                        "Flags":"🏁🇧🇷🇨🇦🇨🇳🇮🇳🇯🇵🇱🇷🚩"]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let cvc = segue.destination as? ConcentrationViewController {
                if let themeName = (sender as? UIButton)?.currentTitle, let theme = emojiThemeCollection[themeName] {
                    cvc.theme = theme
                    concentrationViewController = cvc
                }
            }
        }
    }
    
    @IBAction func chooseTheme(_ sender: UIButton) {
        if let cvc = splitViewController?.viewControllers.last as? ConcentrationViewController {
            if let theme = emojiThemeCollection[sender.currentTitle ?? ""] {
                cvc.theme = theme
                print("Detail view of aplit view controller updated")
            }
        }
        else if let cvc = concentrationViewController {
            if let theme = emojiThemeCollection[sender.currentTitle ?? ""] {
                cvc.theme = theme
                navigationController?.pushViewController(cvc, animated: true)
                print("Nav view controller pushed")
            }
        }
        else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
            print("Segue performed")
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentrationViewController {
            if cvc.theme != nil {
                return false
            }
        }
        return true
    }
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }    
}
