import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    let okayButton = UIButton()
    
    //MARK: - Main functions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpOnboardingViews()
    }
    
    //MARK: - IBActions
    
    @IBAction private func buttonAction(_ sender: UIButton) {
        guard sender.tag < OnboardingManager.shared.onboardingImages.count else {
            OnboardingManager.shared.setNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width*CGFloat(sender.tag), y: 0), animated: true)
    }
    
    //MARK: - Flow functions
    
    private func setUpOnboardingViews() {
        let arrayItemsNumber = OnboardingManager.shared.onboardingImages.count
        for x in 0..<arrayItemsNumber {
            let pageView = UIView()
            setUpView(pageView, with: x)
        }
        scrollView.contentSize = CGSize(width: holderView.frame.size.width*(CGFloat(arrayItemsNumber)), height: 0)
    }
    
    private func setUpView(_ view: UIView, with number: Int) {
        addView(view, number: number)
        addImageView(on: view, number: number)
        addButton(on: view, buttonNumber: number)
    }
    
    private func addView(_ view: UIView, number: Int) {
        view.frame = CGRect(x: CGFloat(number) * holderView.frame.size.width,
                            y: 0,
                            width: holderView.frame.size.width,
                            height: holderView.frame.size.height)
        view.clipsToBounds = true
        scrollView.addSubview(view)
    }
    
    private func addImageView(on view: UIView, number: Int) {
        let imageView = UIImageView()
        configImageView(imageView, number: number)
        view.addSubview(imageView)
        configImageViewConstraints(imageView, addOn: view)
    }
    
    private func configImageView(_ imageView: UIImageView, number: Int) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = OnboardingManager.shared.onboardingImages[number]
    }
    
    private func configImageViewConstraints(_ imageView: UIImageView, addOn view: UIView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let aspectRatioConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 16/9, constant: 0)
        aspectRatioConstraint.isActive = true
    }
    
    private func addButton(on view: UIView, buttonNumber: Int) {
        let button = UIButton()
        button.frame = CGRect(x: view.frame.size.width/4,
                              y: view.frame.size.height - view.frame.size.height/8,
                              width: view.frame.size.width/2,
                              height: view.frame.size.height/16)
        configButton(button, buttonNumber: buttonNumber)
        setUpButton(in: button, with: buttonNumber)
        view.addSubview(button)
    }
    
    private func configButton(_ button: UIButton, buttonNumber: Int) {
        configButtoinUI(in: button)
        setUpButtonShadow(in: button)
        setUpButtonText(in: button, buttonNumber: buttonNumber)
    }
    
    private func configButtoinUI(in button: UIButton) {
        button.backgroundColor = UIColor(red: 48/255, green: 63/255, blue: 159/255, alpha: 1)
        button.layer.cornerRadius = 10
    }
    
    private func setUpButtonShadow(in button: UIButton) {
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 1
    }
    
    private func setUpButtonText(in button: UIButton, buttonNumber: Int) {
        button.setTitle("Next", for: .normal)
        if buttonNumber == OnboardingManager.shared.onboardingImages.count - 1 {
            button.setTitle("Go to app", for: .normal)
        }
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
    }
    
    private func setUpButton(in button: UIButton, with buttonNumber: Int) {
        button.tag = buttonNumber + 1
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

}
