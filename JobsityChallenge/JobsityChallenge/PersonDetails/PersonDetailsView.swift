//
//  PersonDetailsView.swift
//  JobsityChallenge
//
//  Created by João Pedro de Amorim on 27/11/22.
//

import SwiftUI
import OSLog

struct PersonDetailsView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.state {
        case .success(let data):
            List {
                renderPersonSection()
                renderShowSection(for: data)
            }
            .listStyle(.insetGrouped)
        case .loading:
            ProgressView()
        case .error:
            ErrorStateView(onRetry: { viewModel.fetchData() })
        }
    }

    @ViewBuilder private func renderPersonSection() -> some View {
        Section {
            VStack(spacing: Constants.elementSpacing) {
                PosterImage(url: viewModel.person.posterImageURL)
                    .frame(width: Constants.posterImageDimensions.width, height: Constants.posterImageDimensions.height)
                    .padding(.vertical, Constants.posterImagePadding)
                Text(viewModel.person.name)
                    .font(.title)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder private func renderShowSection(for shows: [TileModel]) -> some View {
        Section("Shows") {
            ForEach(shows) { show in
                TileView(model: show, onTap: viewModel.onTapShow)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

extension PersonDetailsView {
    class ViewModel: ObservableObject {
        @Published private(set) var state: State = .loading

        let onTapShow: (TileModel) -> Void
        let person: TileModel

        private let service: PersonDetailsServiceProtocol

        init(
            person: TileModel,
            service: PersonDetailsServiceProtocol = PersonDetailsService(),
            onTapShow: @escaping (TileModel) -> Void
        ) {
            self.person = person
            self.service = service
            self.onTapShow = onTapShow
            fetchData()
        }

        func fetchData() {
            state = .loading

            Task {
                do {
                    let data = try await service.getShows(for: String(person.id))
                    handleSuccess(with: data)
                } catch {
                    handleError(error: error)
                }
            }
        }

        private func handleSuccess(with data: [TileModel]) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.state = .success(data)
            }
        }

        private func handleError(error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                os_log(.debug, "PersonDetailsView error occurred Error(\(String(describing: error)))")
                self.state = .error
            }
        }
    }
}

extension PersonDetailsView {
    enum Constants {
        static let elementSpacing: CGFloat = 20
        static let posterImageDimensions: CGSize = .init(width: 110, height: 130)
        static let posterImagePadding: CGFloat = 30
    }
}

extension PersonDetailsView.ViewModel {
    enum State {
        case loading
        case error
        case success([TileModel])
    }
}
