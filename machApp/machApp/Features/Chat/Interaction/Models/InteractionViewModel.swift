//
//  ReactionViewModel.swift
//  machApp
//
//  Created by lukas burns on 10/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class InteractionViewModel: NSObject {
    let interaction: Interaction
    
    var message: String { return self.interaction.message ?? "" }
    
    var imageUrl: URL? {
        guard let imageName = self.interaction.imageUri else { return nil }
        guard let url = AssetManager.getUrlFor(resource: imageName) else { return nil}
        return url
    }
    
    init(interaction: Interaction) {
        self.interaction = interaction
    }
}
