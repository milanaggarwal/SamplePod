import SwiftUI

/// Subclass of `UIHostingController` for when you want to embed a `SwiftUI View` in a view controller with a hidden nav bar
public class HiddenNavigationBarHostingViewController<Content>: UIHostingController<Content> where Content: View {
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
