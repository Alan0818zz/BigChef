//
//  RecipeCoordinator.swift
//  ChefHelper
//
//  Created by 陳泓齊 on 2025/5/4.
//

import SwiftUI

@MainActor
final class RecipeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private unowned let nav: UINavigationController
    
    func start() {
        fatalError("Use start(with:) instead.")
    }
    
    //MARK: - Init
    init(nav: UINavigationController) {
        self.nav = nav
    }
    
    //MARK: - Start
    func start(with response: SuggestRecipeResponse) {
        Task { @MainActor in
            print("📦 RecipeCoordinator - start \(response.dish_name)")
            let vm = RecipeViewModel(response: response)
            print("📦 RecipeCoordinator - pushing RecipeView1")
            
            // ① 設定 callback
            vm.onCookRequested = { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    let camera = CameraCoordinator(nav: self.nav)
                    self.childCoordinators.append(camera)
                    camera.onFinish = { [weak self, weak camera] in
                        guard let self, let camera else { return }
                        Task { @MainActor in
                            self.childCoordinators.removeAll { $0 === camera }
                        }
                    }
                    await camera.start(with: response.recipe) // push camera with all steps
                }
            }
            
            print("📦 RecipeCoordinator - pushing RecipeView")
            let page = UIHostingController(rootView: RecipeView(viewModel: vm))
            nav.pushViewController(page, animated: true)
        }
    }
}
