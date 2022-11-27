//
//  ErrorStateView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI

struct ErrorStateView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Constants.spacing) {
            Text(Constants.userFriendlyMessage)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            Button(Constants.buttonTitle, action: onRetry)
        }
    }
}

extension ErrorStateView {
    enum Constants {
        static let spacing: CGFloat = 10
        static let userFriendlyMessage: String = "Oh no! An Error Occurred!"
        static let buttonTitle: String = "Retry"
    }
}

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorStateView {}
    }
}
