import SwiftUI

// MARK: - Models
struct Player: Identifiable {
    let id = UUID()
    let name: String
    var score: Int
    let avatarURL: String?
}

struct User {
    var name: String
    var avatarURL: String?
    var points: Int
    var streak: Int
    var hasCompletedToday: Bool = false
}

// MARK: - Theme constants
fileprivate struct Theme {
    static let cardRadius: CGFloat = 14
    static let cardShadow = Color.black.opacity(0.08)
    // fallback accent
    static let fallbackAccent = LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    // CTA (obvious) gradient
    static let ctaGradient = LinearGradient(colors: [Color.purple, Color.pink], startPoint: .leading, endPoint: .trailing)
    static let gold = Color.yellow
    static let lightGold = Color(red: 1.0, green: 0.9, blue: 0.4)
    static let bronze = Color.orange
}

// MARK: - Main View
struct ProfileView: View {
    @State private var user = User(name: "Jay Lin", avatarURL: nil, points: 120, streak: 5)
    @State private var players = [
        Player(name: "Alice Johnson", score: 250, avatarURL: nil),
        Player(name: "Bob Lee", score: 200, avatarURL: nil),
        Player(name: "Charlie Kim", score: 180, avatarURL: nil),
        Player(name: "Diana Park", score: 150, avatarURL: nil),
        Player(name: "Eve Stone", score: 120, avatarURL: nil)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderCard(user: $user)
                        .padding(.horizontal)

                    LeaderboardCard(players: $players)
                        .padding(.horizontal)

                    Spacer(minLength: 16)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                }
            }
        }
    }
}

// MARK: - Header Card (Profile)
struct HeaderCard: View {
    @Binding var user: User
    @State private var animatePulse = false

    var body: some View {
        HStack(spacing: 16) {
            AvatarView(name: user.name, imageURL: user.avatarURL)
                .frame(width: 96, height: 96)
                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1.5))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 10) {

                Text(user.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    StatPill(title: "Points", value: "\(user.points)")
                    StreakRing(days: user.streak)
                        .frame(width: 48, height: 48)
                }

                Button(action: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        user.points += 10
                        user.streak += 1
                        animatePulse.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            animatePulse.toggle()
                        }
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.subheadline)
                        Text("Complete Today's Task")
                            .font(.subheadline).bold()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Theme.ctaGradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 6)
                    .scaleEffect(animatePulse ? 1.04 : 1.0)
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .fill(LinearGradient(colors: [Color.green.opacity(0.95), Color.blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .shadow(color: Theme.cardShadow, radius: 12, x: 0, y: 8)
    }
}

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    @Binding var players: [Player]

    var body: some View {
        // compute max score for bar scaling
        let maxScore = (players.map { $0.score }.max() ?? 1)

        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Leaderboard")
                        .font(.headline)
                    Text("Top players")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Sort button (sorts descending)
                Button(action: {
                    players.sort { $0.score > $1.score }
                }) {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                        .font(.caption)
                }
            }
            .padding(.horizontal)

            LazyVStack(spacing: 12) {
                ForEach(players.indices, id: \.self) { idx in
                    LeaderRow(rank: idx + 1, player: players[idx], maxScore: maxScore)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: Theme.cardRadius).fill(Color(.systemBackground)))
        .shadow(color: Theme.cardShadow, radius: 8, x: 0, y: 6)
    }
}

// MARK: - Leader Row (with bar chart)
struct LeaderRow: View {
    let rank: Int
    let player: Player
    let maxScore: Int

    private var barColor: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing)
        case 2:
            return LinearGradient(colors: [Color(white: 0.95), Color.yellow.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
        case 3:
            return LinearGradient(colors: [Color.yellow.opacity(0.85), Color.orange.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(
                colors: [
                    Color(.systemGray3),   // brighter gray
                    Color(.systemGray4)    // slightly darker gray
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                RankBadge(rank: rank)
                    .frame(width: 48, height: 48)

                AvatarView(name: player.name, imageURL: player.avatarURL)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.subheadline).bold()
                        .lineLimit(1)
                    HStack {
                        // small score text
                        Text("\(player.score) pts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }

                Spacer()

                if rank <= 3 {
                    Image(systemName: "rosette")
                        .font(.title3)
                        .foregroundColor(rank == 1 ? Theme.gold : (rank == 2 ? Theme.lightGold : Theme.bronze))
                        .frame(width: 36, height: 36)
                } else {
                    Text("\(player.score)")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }

            // Bar chart row (visual score)
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let fraction = maxScore > 0 ? CGFloat(player.score) / CGFloat(maxScore) : 0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(barColor)
                        .frame(width: max(16, totalWidth * fraction), height: 12) // minimum visible width
                        .animation(.easeOut(duration: 0.45), value: player.score)
                }
            }
            .frame(height: 16)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }
}

// MARK: - Rank Badge
struct RankBadge: View {
    let rank: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(badgeBackground)
            Text("#\(rank)")
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }

    private var badgeBackground: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom)
        case 2:
            return LinearGradient(
                colors: [
                    Color.yellow.opacity(0.9),   // bright yellow
                    Color.orange.opacity(0.7)    // soft orange
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case 3:
            return LinearGradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(
                colors: [
                    Color(.systemGray3),   // brighter gray
                    Color(.systemGray4)    // slightly darker gray
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Avatar (AsyncImage with initials fallback)
struct AvatarView: View {
    let name: String
    let imageURL: String?

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map { String($0) }
        return letters.joined().uppercased()
    }

    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack { Color(.systemGray5); ProgressView() }
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        initialsCircle
                    @unknown default:
                        initialsCircle
                    }
                }
            } else {
                initialsCircle
            }
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 0.5))
    }

    private var initialsCircle: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Text(initials.isEmpty ? "U" : initials)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Small UI Pieces
struct StatPill: View {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline).bold()
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Streak Ring (simple circular indicator)
struct StreakRing: View {
    var days: Int
    var goal: Int = 7 // example weekly goal

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(days) / Double(goal), 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AngularGradient(gradient: Gradient(colors: [Color.green, Color.blue]), center: .center), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)
            Text("\(days)d")
                .font(.caption).bold()
        }
    }
}

// MARK: - Previews
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .preferredColorScheme(.light)
            ProfileView()
                .preferredColorScheme(.dark)
        }
    }
}
