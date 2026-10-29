import SwiftUI
import UIKit

/// Card-sized placeholder for every state where there is no cheapest price to show.
struct StateCard<Actions: View>: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    @ViewBuilder var actions: Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            actions
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension StateCard where Actions == EmptyView {
    init(title: LocalizedStringKey, message: LocalizedStringKey, systemImage: String) {
        self.init(title: title, message: message, systemImage: systemImage) { EmptyView() }
    }
}

struct LoadingCard: View {
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(title).font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

struct LocationDeniedCard: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        StateCard(
            title: "Posizione disattivata",
            message: "Attiva la posizione per vedere i distributori più economici vicino a te.",
            systemImage: "location.slash"
        ) {
            Button("Apri Impostazioni") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
    }
}

struct StaleBannerView: View {
    let banner: StaleBanner

    var body: some View {
        Label {
            Text(banner.offline ? "Dati di \(banner.days) giorni fa · offline" : "Dati di \(banner.days) giorni fa")
        } icon: {
            Image(systemName: banner.offline ? "wifi.slash" : "clock.badge.exclamationmark")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.stale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.stale.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 24) {
        StaleBannerView(banner: StaleBanner(days: 3, offline: true))
        LoadingCard(title: "Cerco la tua posizione…")
        LocationDeniedCard()
        StateCard(title: "Nessun distributore", message: "Prova un altro carburante.", systemImage: "fuelpump.slash")
    }
    .padding()
}
