import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var optionLabel: UILabel!
    
    func configCellWith(name: String) {
        optionLabel.text = name
    }
}
