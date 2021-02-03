import UIKit

class NoteView: UIView {
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    
    var noteAnimationDelegate:NoteAnimationDelegate?
    var newsItem:NewsItemModel?
    
    class func instanceFromNib() -> NoteView {
        return UINib(nibName: "NoteView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NoteView
    }
    
    //MARK: - IBActions

    @IBAction private func cancelButtonIsPressed(_ sender: UIButton) {
        hideNote()
    }
    
    @IBAction private func doneButtonIsPressed(_ sender: UIButton) {
        hideNote()
        saveText()
    }
    
    //MARK: - Flow functions
    
    func fillInTextView(with note: String) {
        textView.text = note
    }
    
    private func hideNote() {
        guard let delegate = noteAnimationDelegate else {
            return
        }
        delegate.animateNote(isActive: true)
        textView.resignFirstResponder()
    }
    
    private func saveText() {
        guard let newsItem = newsItem else {
            return
        }
        if let text = textView.text, !text.isEmpty {
            FavoritesManager.shared.updateObject(newsItem, with: text)
        } else {
            FavoritesManager.shared.updateObject(newsItem, with: "")
        }
    }
    
}

//MARK: - UITextViewDelegate

extension NoteView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
}
